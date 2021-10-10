#!/bin/sh
# Specify targets to scan in ranges.conf, edit SLACKTOKEN, and begin SLAPping.
SCANOPTIONS="-v -p- -T4"
TARGETFILE="ranges.conf"
DATE=$(date +%Y-%m-%d-%H-%M-%S)
WORKINGDIR="/nmap/diffs"
SLACKTOKEN=""
SLACKCOMMENT=""
while read line; do
        COMPANYNAME=`echo ${line} | cut -d: -f1`
        IPRANGES=`echo ${line} | cut -d: -f2`
        echo "Scanning ${COMPANYNAME}'s perimeter, detected IP ranges: ${IPRANGES}"
        cd ${WORKINGDIR}
        nmap ${SCANOPTIONS} ${IPRANGES} -oX ${COMPANYNAME}-${DATE}.xml > /dev/null
        slack_report() {
                curl \
                -F file=@${COMPANYNAME}-${DATE}-diff \
                -F initial_comment="${MESSAGE}" \
                -F channels=#slap \
                -F token=${SLACKTOKEN} \
                https://slack.com/api/files.upload
        }
        no_diff() {
                curl \
                -X POST \
                -H "Authorization: Bearer "${SLACKTOKEN}"" \
                -H 'Content-type: application/json' \
                --data '{"channel":"slap","text":"'"${MESSAGE}"'"}' \
                https://slack.com/api/chat.postMessage
        }
        if [ -e ${COMPANYNAME}-prev.xml ]; then
                ndiff ${COMPANYNAME}-prev.xml ${COMPANYNAME}-${DATE}.xml > ${COMPANYNAME}-${DATE}-diff
		RESPONSECODE=$?
                if [ ${RESPONSECODE} -eq "1" ]; then
			sed -i -e 1,3d ${COMPANYNAME}-${DATE}-diff
			IPADDRS=$(cat ${COMPANYNAME}-${DATE}-diff | egrep -v "^-" | egrep -o "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}" | sed -E 's/^[^0-9]//' | sed -z 's/\n/ | /g' | tr -d '|$')
			PORTCOUNT=$(cat ${COMPANYNAME}-${DATE}-diff | egrep "^\+[0-9]{1,5}/tcp" | wc -l)
			MESSAGE="[${COMPANYNAME}]: ${PORTCOUNT} port(s) were detected across the following IP addresses: ${IPADDRS}"
			slack_report
		elif [ ${RESPONSECODE} -eq "0" ]; then
			MESSAGE="[${COMPANYNAME}]: Shiver me timbers! No ports were discovered today."
			no_diff
		fi

        fi
        ln -sf ${COMPANYNAME}-${DATE}.xml ${COMPANYNAME}-prev.xml
done < ${TARGETFILE}
