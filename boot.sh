#!/bin/bash

exec /usr/bin/runsvdir /etc/service&
RUNSVDIR=$!
echo "Launched runsvdir, PID is $RUNSVDIR"
trap "echo 'Shutting Down' && sv -w10 force-stop /etc/service/* && kill -HUP $RUNSVDIR && wait $RUNSVDIR" SIGTERM SIGHUP SIGINT
wait $RUNSVDIR
