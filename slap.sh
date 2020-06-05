#!/bin/sh
# Specify targets to scan in ranges.conf, edit SLACKTOKEN, and begin SLAPping. 

SCANOPTIONS="-v -p- -Pn -T4"
TARGETFILE="ranges.conf"
DATE=$(date +%Y-%m-%d-%H-%M-%S)
WORKINGDIR="/nmap/diffs"
SLACKTOKEN=""
SLACKCOMMENT=""

while read line; do
	CUSTOMERNAME=`echo ${line} | cut -d: -f1`
	IPRANGES=`echo ${line} | cut -d: -f2`
	echo "Scanning ${CUSTOMERNAME}'s perimeter, detected IP ranges: ${IPRANGES}"
	cd ${WORKINGDIR}
	nmap ${SCANOPTIONS} ${IPRANGES} -oX ${CUSTOMERNAME}-${DATE}.xml > /dev/null

	slack() {
		curl \
		-F file=@${CUSTOMERNAME}-${DATE}-diff \
	       	-F initial_comment="A port has been discovered!" \
		-F channels=#slap \
		-F token=${SLACKTOKEN} \
	       	https://slack.com/api/files.upload
	}

	if [ -e ${CUSTOMERNAME}-prev.xml ]; then
		ndiff ${CUSTOMERNAME}-prev.xml ${CUSTOMERNAME}-${DATE}.xml > ${CUSTOMERNAME}-${DATE}-diff
		[ "$?" -eq "1" ] && sed -i -e 1,3d ${CUSTOMERNAME}-${DATE}-diff && slack
	fi
	ln -sf ${CUSTOMERNAME}-${DATE}.xml ${CUSTOMERNAME}-prev.xml

done < ${TARGETFILE}
curl -X POST -H 'Authorization: Bearer [PASTE SLACK TOKEN HERE]' -H 'Content-type: application/json' --data '{"channel":"slap","text":"Shiver me timbers! No other ports were discovered today."}' https://slack.com/api/chat.postMessage
