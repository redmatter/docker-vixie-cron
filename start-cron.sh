#!/bin/sh

stop_cron_daemon() {
    local cron_pid="$1";
    if [ -n "$cron_pid" ] && kill -0 "$cron_pid" &>/dev/null; then
        kill "$cron_pid";
    else
        exit 0
    fi
}

cron_monitored_files() {
    find /var/spool/cron/crontabs \
        /etc/cron.d \
        /etc/cron.hourly \
        /etc/cron.daily \
        /etc/cron.weekly \
        /etc/cron.monthly \
        -mindepth 1 -not -name .placeholder
}

[ "$DEBUG" = 1 ] && set -x;

: ${RUN_USER:=root}
# make sure RUN_USER exists and is setup correctly
if ! cron-user check "$RUN_USER"; then
    exit 1;
fi

# setup crontab
/usr/bin/crontab -u ${RUN_USER} /crontab.txt;

# setup file permissions expected by crond
chmod go-rwx /var/spool/cron/crontabs/${RUN_USER};
chown ${RUN_USER}:crontab /var/spool/cron/crontabs/${RUN_USER};

# capture environment variables which can be used in scripts
for var in $PRESERVE_ENV_VARS; do
    echo "$var=$(eval echo \$$var)"
done > /etc/environment

# setup a background subshell that would touch crontabs so
# that they are correctly loaded; work aroud for some quirks
# with vixie cron
(
    sleep 5;
    touch $(cron_monitored_files)
)&

# start cron in foreground mode and background it using
# shell semantics so that the PID can be captured
/usr/sbin/cron -f -L15 &
cron_pid=$!

trap "stop_cron_daemon $cron_pid" INT TERM EXIT

wait $cron_pid
