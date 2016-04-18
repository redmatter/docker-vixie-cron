# docker-vixie-cron

Docker image to run scheduled tasks using the classic vixie-cron (debian flavour).

## How to use it

Have a look inside the [`test`](test) folder for an example.

### Variables:

#### `RUN_USER`

User for which crontab is to be added for; due to the way it is setup, choose a user other than any of the predefined users. The user chosen must be part of the `crontab` group. If a new user need to be added for this purpose, please use the `cron-user add -u User [-g Group]` command.

#### `PRESERVE_ENV_VARS`
Since cron will execute the task in an isolated environment, any special environment variables set via `ENV` directive in your Dockerfile or from `docker run` `-e` option will not be available to your script. In order to get around that, you can specify a list of variable names separated by space.

### Files:

#### `crontab.txt`
You can add your crontab in this file; make sure any scripts and command referred in it are present in the container,
either in the image or its volumes.
