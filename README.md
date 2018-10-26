## Docker deployment for Mattermost
This project enables deployment of a Mattermost server using Docker.
## Installation using Docker Compose
# Choose Edition to Install
If you want to install Team Edition, you can skip this section.
To install the enterprise edition, comment out the two following lines in docker-compose.yaml file:
args:
  - edition=enterprise

# Run the Mattermost application. 
Run the Mattermost docker You should configure it with following environment variables :

- MATTERMOST_SITEURL:Site URL
- MATTERMOST_EMAIL_FEEDBACKEMAIL:Notification From Address
- MATTERMOST_EMAIL_FEEDBACKORGANIZATION:Notification Footer Mailing Address
- MATTERMOST_EMAIL_SMTPSERVER:Notification SMTP Server
- MATTERMOST_EMAIL_SMTPPORT:Notification SMTP Server Port
- MATTERMOST_EMAIL_SMTPUSERNAME:SMTP Server Username
- MATTERMOST_EMAIL_SMTPPASSWORD:SMTP Server Password
- MATTERMOST_EMAIL_ENABLESMTPAUTH:Enable SMTP Authentication(true or false)
- MATTERMOST_EMAIL_CONNECTIONSECURITY:Connection Security(None / TLS / STARTTLS)
- MATTERMOST_EMAIL_PUSHNOTIFICATIONSERVER:Enable Push Notifications(true or false)
- MATTERMOST_SQL_MAXOPENCONNS:Maximum Open Connections
- MATTERMOST_SQL_DRIVERNAME:driver name (etc:mysql)
- MM_SQLSETTINGS_DATASOURCE:datasource(ect mattermost:mattermost@tcp(db:3306)/mattermost?charset=utf8mb4,utf8)

# docker-compose file sample
    version: '3'
    networks:
      mattermost:
    volumes:
       mattermost-config:
       mattermost-data:
       mattermost-logs:
       mattermost-plugins:
    services:
      app:
        build:
          context: app
          args:
            - edition=team
            - MATTERMOST_VERSION=5.4.0
        restart: unless-stopped
        networks:
          mattermost:
        volumes:
          - mattermost-config:/mattermost/config:rw
          - mattermost-data:/mattermost/data:rw
          - mattermost-logs:/mattermost/logs:rw
          - mattermost-plugins:/mattermost/plugins:rw
          - /etc/localtime:/etc/localtime:ro
        environment:
          # set config
          - MATTERMOST_SITEURL=http://example.com/mattermost
          - MATTERMOST_EMAIL_FEEDBACKEMAIL=mattermost@example.com
          - MATTERMOST_EMAIL_FEEDBACKORGANIZATION=example
          - MATTERMOST_EMAIL_SMTPSERVER=mattermost.example.com
          - MATTERMOST_EMAIL_SMTPPORT=25
          - MATTERMOST_EMAIL_SMTPUSERNAME=mattermost
          - MATTERMOST_EMAIL_SMTPPASSWORD=mattermost
          - MATTERMOST_EMAIL_ENABLESMTPAUTH=true
          - MATTERMOST_EMAIL_CONNECTIONSECURITY=TLS
          - MATTERMOST_EMAIL_PUSHNOTIFICATIONSERVER=mattermost.example.com
          - MATTERMOST_SQL_MAXOPENCONNS=300
          - MATTERMOST_SQL_DRIVERNAME=mysql
          - MM_SQLSETTINGS_DATASOURCE=mattermost:mattermost@tcp(db:3306)/mattermost?charset=utf8mb4,utf8


# Start Container user docker-compose
     docker-compose up -d

# Stop Container user docker-compose
     docker-compose stop
