# Continuous Network Monitoring with SLAP 

SLAP (SLack + nmAP) is an easy way to automate the discovery of your organizations internal or external environment and receive daily notifications about it in Slack. This works well for security teams who want to know *when* a port was exposed to the Internet, rather than find out six months later in a penetration test. This script has also been used by MSPs to alert customers of misconfigurations.

SLAP was inspired by slackmap created by Jerry Gamblin: https://jerrygamblin.com/2016/11/05/continuous-network-monitoring-with-slack-alerting/

## Installation

SLAP is pretty straightforward to install! Only nmap, ndiff, and curl are required to start SLAPping. 

```bash
apt-get install nmap ndiff curl
git clone https://github.com/DeviantSec/SLAP
```

## Usage

Using SLAP is also just as easy. Simply fill in the WORKINGDIR and SLACKTOKEN variables with the appropriate information. 

## Contributing
Please feel free to contribute! If you want to discuss SLAP in depth then reach out to me on Twitter as well @FreeZeroDays

## License
[MIT](https://choosealicense.com/licenses/mit/)
