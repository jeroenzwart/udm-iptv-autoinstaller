# Auto-installer for IPTV on UniFi OS
This script is an auto installer for getting IPTV on Unifi OS. This script requires the tool [udm-iptv](https://github.com/fabianishere/udm-iptv). Many thanks to the contributors to this tool. Through firmware updates (depending on the type of upgrade), your configuration and installation of [udm-iptv](https://github.com/fabianishere/udm-iptv) might or might not persist. With this installer it can be possible to restore your configuration and installation automatically. By example, using Home Assistant.

## Prerequisites
Before running this installer, be sure you have set up up your internet connection and internal LAN. See [Prerequisites](https://github.com/fabianishere/udm-iptv#prerequisites) of [udm-iptv](https://github.com/fabianishere/udm-iptv).

## Usage
Run this command on a host that can make a SSH connection to your Unifi OS.
```bash
sh -c "$(curl -sSf https://raw.githubusercontent.com/jeroenzwart/udm-iptv-autoinstaller/main/installer.sh | sh -s -- -h {HOST} -u {USER} -p {PASSWORD} {CONFIG})"
```
| Tag          | Explantion                               | Example            |
|--------------|------------------------------------------|--------------------|
| *{HOST}*     | The IP or hostname of your Unifi device  | 192.168.1.1        | 
| *{USER}*     | The user set in Unifi Controller for SSH | admin              |
| *{PASSWORD}* | The password set in the Unifi Controller | verysecretpassword |
| *{CONFIG}*   | The configuration file                   | ./KPN.conf         |

So like this;
```bash
sh -c "$(curl -sSf https://raw.githubusercontent.com/jeroenzwart/udm-iptv-autoinstaller/main/installer.sh | sh -s -- -h 192.168.1.1 -u admin -p 's3cr3T!' './MyProvider.conf')"
```

## Configuration
See the KPN.conf file as example.
