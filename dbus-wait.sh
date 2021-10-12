#!/usr/bin/env sh

wait_for_dbus() {
	while true; do
		dbus_wait=$(dbus-send --system \
			  --print-reply \
			  --dest=org.freedesktop.DBus \
			  /org/freedesktop/DBus \
			  org.freedesktop.DBus.ListNames)

                if [ "$dbus_wait" -eq 0 ]; then
			break;
		else
			sleep 0.1
		fi
	done

	echo "DBus is now accepting connections"
}
