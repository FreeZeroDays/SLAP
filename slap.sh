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
        slack_report() {
                curl \
                -F file=@${CUSTOMERNAME}-${DATE}-diff \
                -F initial_comment=${MESSAGE} \
                -F channels=#slap \
                -F token=${SLACKTOKEN} \
                https://slack.com/api/files.upload
        }
        no_diff() {
                curl \
                -X POST \
                -H "Authorization: Bearer "${SLACKTOKEN}"" \
                -H 'Content-type: application/json' \
                --data '{"channel":"slap","text":"Shiver me timbers! No other ports were discovered today."}' \
                https://slack.com/api/chat.postMessage
        }
        if [ -e ${CUSTOMERNAME}-prev.xml ]; then
                ndiff ${CUSTOMERNAME}-prev.xml ${CUSTOMERNAME}-${DATE}.xml > ${CUSTOMERNAME}-${DATE}-diff
                if [ "$?" -eq "1" ]; then
			sed -i -e 1,3d ${CUSTOMERNAME}-${DATE}-diff
			IPADDRS=$(cat ${CUSTOMERNAME}-${DATE}-diff | grep -B1 "+Host is up" | egrep -o "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}" | tr '\n' ', ')
			PORTCOUNT=$(cat ${CUSTOMERNAME}-${DATE}-diff | egrep "^\+[0-9]{1,5}/tcp" | wc -l)
			MESSAGE="[${CUSTOMERNAME}]: ${PORTCOUNT} ports were detected across the following IP addresses: ${IPADDRS}"
			slack_report
		elif [ "$?" -eq "0" ]; then
			no_diff
		fi

        fi
        ln -sf ${CUSTOMERNAME}-${DATE}.xml ${CUSTOMERNAME}-prev.xml
done < ${TARGETFILE}
