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
	mkdir -pv "/usr/local/var/log/openvas/" && touch "$LOG_FILE"

	gvmd --migrate
}

trap handle_interrupt INT TERM

setup && watch_logs & gvmd --foreground --osp-vt-update=/var/run/ospd/ospd.sock --max-ips-per-target=65536 "$@" || >&2 echo "Something failed; bailing... Last few lines of ${LOG_FILE}: $(tail $LOG_FILE)"
