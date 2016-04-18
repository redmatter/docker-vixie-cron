FROM redmatter/cron

ENV RUN_USER=testuser
RUN cron-user add -u ${RUN_USER}
ADD test.sh /test.sh

