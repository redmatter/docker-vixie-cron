FROM debian:jessie

MAINTAINER Dino.Korah@RedMatter.com

ENV TZ="UTC"

COPY start-cron.sh cron-user.sh /

RUN ( \
        export DEBIAN_FRONTEND=noninteractive; \

        BUILD_DEPS=""; \
        APP_DEPS="bash cron sudo"; \

        # so that each command can be seen clearly in the build output
        set -e -x; \

        # update and upgrade for vulnerability fixes etc.
        apt-get update; \
        apt-get install --no-install-recommends -y $BUILD_DEPS $APP_DEPS ; \

        # remove the ones that come with the package; no need for that
        rm -f /etc/cron.daily/* ; \

        mv /cron-user.sh /usr/bin/cron-user; \
        chmod ugo+x,go-w /start-cron.sh /usr/bin/cron-user ; \

        # remove packages that we don't need
        apt-get remove -y $BUILD_DEPS ; \
        apt-get autoremove -y ; \
        apt-get clean; \
        rm -rf /var/lib/{apt,dpkg,cache,log}/; \
    )

ONBUILD COPY crontab.txt /tmp/

ENTRYPOINT ["sudo", "-E", "/start-cron.sh"]

