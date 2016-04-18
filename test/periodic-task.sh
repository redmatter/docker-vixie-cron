#!/bin/sh

exec >>/tmp/log.txt
exec 2>&1

echo "~~~~~~~~~ $(date) ~~~~~~~~~"
export
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~"

