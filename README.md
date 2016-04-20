# docker-vixie-cron

Source of docker image [`redmatter/cron`](https://hub.docker.com/r/redmatter/cron/) designed to run scheduled tasks
using the classic vixie-cron (debian flavour).

## How to use it

The simplest way to make use of this image is to create a new image based on `redmatter/cron`, as shown in the example
inside the [`test`](test) folder.

You can either let the container run scheduled tasks as `root` user or you can add / modify another user. You can use
`cron-user` script within the base image to add this user and the specify the username in RUN_USER environment variable.

### Variables:

#### `RUN_USER`

User for which crontab is to be added for; due to the way it is setup, choose a user other than any of the predefined users. The user chosen must be part of the `crontab` group. If a new user need to be added for this purpose, please use the `cron-user add -u User [-g Group]` command.

#### `PRESERVE_ENV_VARS`
Since cron will execute the task in an isolated environment, any special environment variables set via `ENV` directive in your Dockerfile or from `docker run` `-e` option will not be available to your script. In order to get around that, you can specify a list of variable names separated by space.

### Files:

#### `crontab.txt`
You can add your crontab in this file; make sure any scripts and command referred in it are present in the container,
either in the image or its volumes.
