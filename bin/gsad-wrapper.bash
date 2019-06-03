#!/bin/bash

set -o pipefail

__GSAD_PID=""
__LOGS_PID=""

function launch() {
	gsad --foreground "$@" &
	__GSAD_PID="$!"
}

function watch_logs() {
	while ! test -r "/usr/local/var/log/gvm/gsad.log";
	do
		sleep 1
	done

	tail -f "/usr/local/var/log/gvm/gsad.log" &
	__LOGS_PID="$!"
}

function handle_interrupt() {
	for pid in "$__GSAD_PID" "$__LOGS_PID";
	do
		kill "$pid"
	done

	exit 0
}

trap handle_interrupt INT TERM

launch "$@" && watch_logs || >&2 echo "Something failed; bailing... Last few lines of /usr/local/var/log/gvm/gsad.log: $(tail /usr/local/var/log/gvm/gsad.log)"

for pid in "$__GSAD_PID" "$__LOGS_PID";
do
	wait "$pid"
done
