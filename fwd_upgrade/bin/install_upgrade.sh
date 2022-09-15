#!/bin/bash

SPLUNK_HOME=$1

VERSION=$2

MANIFEST_FILE=$SPLUNK_HOME/splunkforwarder-$VERSION-linux-2.6-x86_64-manifest
UPGRADE_FILE=$SPLUNK_HOME/etc/apps/fwd_upgrade/bin/splunkforwarder-$VERSION-Linux-x86_64.tgz

PARENT_DIR="$(dirname "$SPLUNK_HOME")"

if [ ! -f "/etc/systemd/system/SplunkForwarder.service" ]; then
    echo "$(date) system managed by initd" >> $SPLUNK_HOME/var/log/splunk/forwarderupgrade.log
    SERVICE_MANAGER=INITD
else
    SERVICE_MANAGER=SYSTEMD
    echo "$(date) system managed by systemd" >> $SPLUNK_HOME/var/log/splunk/forwarderupgrade.log
fi

echo "$(date) stopping Splunk service" >> $SPLUNK_HOME/var/log/splunk/forwarderupgrade.log
if [ "$SERVICE_MANAGER"="SYSTEMD" ]; then
    # Requires systemd-managed with podkit rule installed 
    "$SPLUNK_HOME/bin/splunk" stop
else
    "$SPLUNK_HOME/bin/splunk" stop
fi
CURRENT_VERSION=$("$SPLUNK_HOME/bin/splunk" version)
STATUS=$("$SPLUNK_HOME/bin/splunk" status)
echo "$(date) current version is $CURRENT_VERSION" >> $SPLUNK_HOME/var/log/splunk/forwarderupgrade.log
echo "$(date) current status is $STATUS" >> $SPLUNK_HOME/var/log/splunk/forwarderupgrade.log
echo "$(date) splunk service stopped, extracting $UPGRADE_FILE" >> $SPLUNK_HOME/var/log/splunk/forwarderupgrade.log
echo "$(date) extraction $UPGRADE_FILE into $PARENT_DIR" >> $SPLUNK_HOME/var/log/splunk/forwarderupgrade.log
tar -xf "$UPGRADE_FILE" -C "$PARENT_DIR"
echo "$(date) going to run $SPLUNK_HOME/bin/splunk start --accept-license --answer-yes --no-prompt" >> $SPLUNK_HOME/var/log/splunk/forwarderupgrade.log
if [ "$SERVICE_MANAGER"="SYSTEMD" ]; then
    # Requires systemd-managed with podkit rule installed 
    "$SPLUNK_HOME/bin/splunk" start --accept-license --answer-yes --no-prompt
else
    "$SPLUNK_HOME/bin/splunk" start --accept-license --answer-yes --no-prompt
fi
NEW_VERSION=$("$SPLUNK_HOME/bin/splunk" version)
echo "$(date) new version is $NEW_VERSION" >> $SPLUNK_HOME/var/log/splunk/forwarderupgrade.log
echo "$(date) upgrade completed" >> $SPLUNK_HOME/var/log/splunk/forwarderupgrade.log

