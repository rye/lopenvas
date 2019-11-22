#!/bin/bash

set -o pipefail

__LOGS_PID=""

function watch_logs() {
	mkdir -pv "/usr/local/var/log/openvas/" \
		&& touch "/usr/local/var/log/openvas/openvasmd.log"

	tail -f "/usr/local/var/log/openvas/openvasmd.log" &

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
	mkdir -pv "/usr/local/var/log/openvas/" && touch "/usr/local/var/log/openvas/openvasmd.log"

	if ! grep -q "^DS" /etc/mail/sendmail.cf;
	then
		# A line matching "^DS" was not found; insert one.
		echo "DSsmtp-relay.gmail.com" | tee -a /etc/mail.sendmail.cf
	fi

	if [ -z "$SENDMAIL_RELAY" ];
	then
		if ping -c 1 "$SENDMAIL_RELAY" >/dev/null;
		then
			# Here we have a valid SMTP relay that is responding to ping.
			# So we configure it into the configuration file.

			sed -i.bak "s|^DS.*$|DS${SENDMAIL_RELAY}|g" /etc/mail/sendmail.cf
		else
			>&2 echo "Failed to reach configured SMTP relay."

			exit 1
		fi
	else
		>&2 echo "Sendmail relay not configured."
	fi

	gvmd-pg --migrate
}

trap handle_interrupt INT TERM

setup && watch_logs & gvmd-pg --foreground --max-ips-per-target=65536 "$@" || >&2 echo "Something failed; bailing... Last few lines of /usr/local/var/log/openvas/openvasmd.log: $(tail /usr/local/var/log/openvas/openvasmd.log)"
