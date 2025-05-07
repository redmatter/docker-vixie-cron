FROM debian:12-slim

ENV TZ="UTC"

# Copy the scripts into the image
COPY start-cron.sh /start-cron.sh
COPY cron-user.sh /usr/bin/cron-user

RUN ( \
        set -eux; \
        export DEBIAN_FRONTEND=noninteractive; \
        apt-get update; \
        apt-get install --no-install-recommends -y bash cron sudo; \
        # remove the ones that come with the package; no need for that
        rm -f /etc/cron.daily/* ; \
        # set correct permissions for the scripts
        chmod ugo+x,go-w /start-cron.sh /usr/bin/cron-user ; \
        # clean up
        apt-get autoremove -y; \
        apt-get clean; \
        rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*; \
    )

# crontab.txt is consumed by the cron daemon's startup script (see start-cron.sh)
ONBUILD COPY crontab.txt /

ENTRYPOINT ["sudo", "-E", "/start-cron.sh"]
