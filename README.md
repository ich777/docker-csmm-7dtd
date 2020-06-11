# CSMM for 7DtD Server in Docker optimized for Unraid
This Docker will install and download CSMM for 7DtD (Catalysms Server Monitor & Manager).

It's a powerfull Server Manager with Server automation, Discord notifications, High ping kicker, Country ban, Player tracking, Ingame commands, Economy system, Discord integration, Support ticket system, Server analytics,... for 7DtD.

>**NOTE:** The Docker is based on: https://github.com/CatalysmsServerManager/7-days-to-die-server-manager

## Env params
| Name | Value | Example |
| --- | --- | --- |
| HOSTNAME | The hostname from where you connect (must be in this exact format: 'https://www.server.org' without quotes, no path or locations allowed only subdomains and with no trailing '/').) | https://www.server.org |
| STEAM_API_KEY | Steam API Key goes here (you can get it from: https://steamcommunity.com/dev/apikey) | *secret* |
| BOTTOKEN | Your Discord Bot Token (you can get it from here: https://discordapp.com/developers/applications) | *secret* |
| CLIENTSECRET | Your Discord Client Secret (you can get it from here: https://discordapp.com/developers/applications) | *secret* |
| CLIENTID | Your Discord Client ID (you can get it from here: https://discordapp.com/developers/applications) | *secret* |
| DB_BKP_INTERV | Specify the database backup interval in seconds (saved to the ../Database/7dtd.sql) | 90 |
| CSMM_LOGLEVEL | Log level valid are: 'blank', 'error', 'warn', 'info', 'debug', 'verbose', 'silly' | info |
| FORCE_UPDATE | Set to 'true' to force an update | *blank* |
| CSMM_DL_URL | Set to 'true' if you want to update the server manually (otherwise leave blank) | https://github.com/CatalysmsServerManager/7-day... |
| UID | User Identifier | 99 |
| GID | Group Identifier | 100 |

## Run example
```
docker run --name CSMM -d \
    -p 1337:1337 -p 3306:3306 \
    --env 'HOSTNAME=https://www.server.org' \
    --env 'STEAM_API_KEY=placeyourkeyhere' \
    --env 'DB_BKP_INTERV=90' \
    --env 'CSMM_LOGLEVEL=info' \
    --env 'CSMM_DL_URL=https://github.com/CatalysmsServerManager/7-days-to-die-server-manager/archive/master.zip' \
    --env 'UID=99' \
    --env 'GID=100' \
    --volume /mnt/user/appdata/csmm:/csmm-7dtd \
    ich777/csmm-7dtd
```

This Docker was mainly edited for better use with Unraid, if you don't use Unraid you should definitely try it!

#### Support Thread: https://forums.unraid.net/topic/79530-support-ich777-gameserver-dockers/