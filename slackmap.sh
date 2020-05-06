#!/bin/sh
# Specify targets to scan in <HOST>, edit channel (SLAP = SLack + nmAP), and set OAuth Access Token to begin SLAPping. 
# Edits will be made as time goes on - removed -sV and other flags to lower aggression.
TARGETS="<HOST>"
OPTIONS="-v -p- -Pn -T4"
date=$(date +%Y-%m-%d-%H-%M-%S)
cd /nmap/diffs
nmap $OPTIONS $TARGETS -oA scan-$date > /dev/null
slack(){
curl -F file=@diff-$date -F initial_comment="Port Change Detected" -F channels=#slap -F token=<TOKEN> https://slack.com/api/files.upload
}

if [ -e scan-prev.xml ]; then
ndiff scan-prev.xml scan-$date.xml > diff-$date
[ "$?" -eq "1" ] && sed -i -e 1,3d diff-$date && slack
fi
ln -sf scan-$date.xml scan-prev.xml
