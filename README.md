# Continuous Network Monitoring with SLAP 

SLAP (SLack + nmAP) is an easy way to automate the discovery of an organizations internal and/or external environment via Slack. This works well for teams who want to know *when* a port was exposed to the Internet, rather than find out six months later in a penetration test or after it's too late.

This script has previously been used by multiple MSPs to alert customers of misconfigurations. 

SLAP was originally inspired by [slackmap](https://jerrygamblin.com/2016/11/05/continuous-network-monitoring-with-slack-alerting/) created by Jerry Gamblin. 

## Installation

SLAP is pretty straightforward to install! Only nmap, ndiff, and curl are required to start SLAPping. 

```bash
apt-get install nmap ndiff curl
git clone https://github.com/DeviantSec/SLAP
```

## Usage

Using SLAP is easy. Simply fill in the WORKINGDIR and SLACKTOKEN variables with the appropriate information. 

## Contributing

Please feel free to contribute! If you want to discuss SLAP in depth then reach out to me on Twitter as well @FreeZeroDays.

## Featured

The Shark Jack module for SLAP was featured in NetworkChuck's [you NEED to learn Port Security](https://www.youtube.com/watch?v=0W4JZIWtjLQ) video. Kind of fun!
