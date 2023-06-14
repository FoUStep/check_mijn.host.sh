# check_mijn.host.sh
A Nagios plugin based on Shell to check the expiry of a domain hosted at mijn.host.

| @14th June 2023 | Version |
|---------------:|----------|
| Tested on      |  Debian 11 |
| Nagios Core    |  4.4.13 |

[![GitHub release](https://img.shields.io/github/release/FoUStep/check_mijn.host.sh.svg)](https://GitHub.com/FoUStep/check_mijn.host.sh/releases/)

<sub>It still has to be tested with multiple domains, I'm sure this needs rework.</sub>
```
# check_paloalto.pl 
Usage:
./check_mijn.host.sh <domain> <apikey> (requires dateutils and curl)

<domain> = example.com
<apikey> = long-string-given-by-support
```
