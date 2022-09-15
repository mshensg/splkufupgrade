#!/bin/bash

VERSION=9.0.0.1-9e907cedecb1

MANIFEST_FILE=$SPLUNK_HOME/splunkforwarder-$VERSION-linux-2.6-x86_64-manifest
UPGRADE_FILE=$SPLUNK_HOME/etc/apps/fwd_upgrade/bin/splunkforwarder-$VERSION-Linux-x86_64.tgz

PARENT_DIR="$(dirname "$SPLUNK_HOME")"

if [ ! -f "$MANIFEST_FILE" ]; then
    echo "$(date) $MANIFEST_FILE does not exist, starting upgrade...." >> $SPLUNK_HOME/var/log/splunk/forwarderupgrade.log
    if [ ! -f "$UPGRADE_FILE" ]; then
        echo "$(date) $UPGRADE_FILE does not exist, exiting..." >> $SPLUNK_HOME/var/log/splunk/forwarderupgrade.log
    else
    	echo "$(date) adding upgrade job to system with $SPLUNK_HOME/etc/apps/fwd_upgrade/bin/install_upgrade.sh $SPLUNK_HOME" >> $SPLUNK_HOME/var/log/splunk/forwarderupgrade.log
        echo /bin/bash "$SPLUNK_HOME/etc/apps/fwd_upgrade/bin/install_upgrade.sh" "$SPLUNK_HOME" "$VERSION" > "$SPLUNK_HOME/etc/apps/fwd_upgrade/bin/job.list"
	OUTPUT=$(/bin/at now + 1 minute < "$SPLUNK_HOME/etc/apps/fwd_upgrade/bin/job.list")
	echo "$(date) job added with output: $OUTPUT" >> $SPLUNK_HOME/var/log/splunk/forwarderupgrade.log
        echo "$(date) job added to system with $(atq)" >> $SPLUNK_HOME/var/log/splunk/forwarderupgrade.log
    fi
else
    echo "$(date) $MANIFEST_FILE exists, exiting..." >> $SPLUNK_HOME/var/log/splunk/forwarderupgrade.log
fi
