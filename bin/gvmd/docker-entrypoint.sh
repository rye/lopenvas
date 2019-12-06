#!/bin/bash

set -o pipefail

LOG_FILE="/usr/local/var/log/openvas/openvasmd.log"

__LOGS_PID=""

function watch_logs() {
	mkdir -pv "/usr/local/var/log/openvas/" \
		&& touch "$LOG_FILE"

	tail -f "$LOG_FILE" &

	__LOGS_PID="$!"
}

function handle_interrupt() {
	for pid in "$__LOGS_PID";
	do
		kill "$pid"
	done

	exit 0
}

function setup() {
	mkdir -pv "/usr/local/var/lib/gvm/gvmd/gnupg"
	mkdir -pv "/usr/local/var/log/openvas/" && touch "/usr/local/var/log/openvas/$LOG_FILE"

	gvmd-pg --migrate
}

trap handle_interrupt INT TERM

setup && watch_logs & gvmd-pg --foreground --max-ips-per-target=65536 "$@" || >&2 echo "Something failed; bailing... Last few lines of /usr/local/var/log/openvas/openvasmd.log: $(tail /usr/local/var/log/openvas/openvasmd.log)"
