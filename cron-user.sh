#!/bin/sh

show_usage() {
    [ "$#" -gt 0 ] && echo "$@" && echo
    echo "Usage: cron-user [ add -u User [-g Group] ] [ check User ] [ help ]";
    echo ""
    echo "  Subcommands:"
    echo "      add -u User [-g Group]"
    echo "          Add or modify a user to make the user to part of 'crontab' group. If no Group is specified, a group"
    echo "          with the same name as the User is used. The user is also setup to be a sudoer to be able to start"
    echo "          the cron daemon, assuming the specified user will be used in the USER directive in Dockerfile. If"
    echo "          the specified user is root, no changes are made."
    echo "      check User"
    echo "          Check the specified user to be part of 'crontab' group."
    echo "      help"
    echo "          This help message."

    [ "$#" -eq 0 ];
    exit;
}

check_user() {
    local _USER="$1"; shift

    # root has all permissions required
    [ "$_USER" = root ] && return 0;

    if ! id "$_USER" >/dev/null 2>&1; then
        echo "ERROR: User '$_USER' not found"
        return 1;
    fi

    if ! echo " $(id -nG ${_USER}) " | grep -q " crontab "; then
        echo "ERROR: User '$_USER' not in 'crontab' group"
        return 1;
    fi

    return 0;
}

add_user() {
    local _USER="$1"; shift
    local _GROUP="$1"; shift

    # no need to modify root (OR add root; that would be awkward!)
    [ "$_USER" = root ] && return 0;

    : ${_GROUP:=$_USER}

    # We need to create the user and group that is set to be used, in this container
    # _USER is made sure to be part of groups _GROUP and crontab
    if id -u ${_USER} >/dev/null 2>&1; then
        # get _USER's group(s)
        _groups=" $(id -nG ${_USER}) ";
        # not in _GROUP, then add modify user
        (echo "$_groups" | grep -q " ${_GROUP} ") || usermod -aG ${_GROUP} ${_USER};
        # not in crontab group, then add modify user
        (echo "$_groups" | grep -q " crontab ") || usermod -aG crontab ${_USER};
        # sudo would fail for nologin users; set a usable shell for the user
        _shell=$(getent passwd ${_USER} | cut -d: -f7)
        if [ "$_shell" = /usr/sbin/nologin ] || [ "$_shell" = /bin/false ]; then
            chsh -s /bin/sh ${_USER}
        fi
    else
        # if the _USER does not already exist, create afresh
        groupadd ${_GROUP} &&
        useradd -mrg ${_GROUP} -G crontab ${_USER};
    fi;

    # give sudo permission for the user on cron start script
    local sudoer_file=/etc/sudoers.d/cron_${_USER};
    echo "${_USER} ALL=(ALL) NOPASSWD:SETENV: /start-cron.sh" >> ${sudoer_file};
    echo "${_USER} ALL=(ALL) NOPASSWD:SETENV: /bin/bash" >> ${sudoer_file};
    chown root:root ${sudoer_file};
    chmod 440 ${sudoer_file};
}

if [ "$(whoami)" != "root" ]; then
    show_usage $(cat <<MSG
    ERROR: 'cron-user add' should be run as root.\n
        Within a Dockerfile, make sure that the USER directive is not used before \n
        any RUN directive that invokes 'cron-user add'.
MSG
)
fi

cmd="$1"; shift
if [ "$cmd" = "check" ]; then
    if [ -n "$1" ]; then
        check_user "$1"
        exit;
    else
        show_usage;
    fi
elif [ "$cmd" = "help" ]; then
    show_usage
elif [ "$cmd" = "add" ]; then
    while [ -n "$1" ]; do
        case "$1" in
            -u)
                shift; _USER="$1"; shift;
                ;;
            -g)
                shift; _GROUP="$1"; shift;
                ;;
            *)
                echo "Unknown options $@";
                show_usage;
                ;;
        esac
    done

    if [ -z "$_USER" ]; then
        echo ERROR: User not specified
        show_usage;
    fi

    add_user "$_USER" "$_GROUP"
fi
