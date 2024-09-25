#!/bin/bash
# *NOTE* For now these commands will have to be ran manually once you're ssh'ed onto the ec2 instance
# install Java 17
sudo rpm --import https://yum.corretto.aws/corretto.key
sudo curl -L -o /etc/yum.repos.d/corretto.repo https://yum.corretto.aws/corretto.repo
# Java version entirely depends on the version of minecraft out right now.
sudo yum install -y java-21-amazon-corretto-devel.x86_64

# add dedicated user for doing minecraft server work
sudo adduser minecraft

# use root user to set up our server files
sudo su
mkdir /opt/minecraft
mkdir /opt/minecraft/server
cd /opt/minecraft/server
wget https://piston-data.mojang.com/v1/objects/59353fb40c36d304f2035d51e7d6e6baa98dc05c/server.jar
# This is server version 1.21.1, so to install a different server version, you'll need to google it


# set our minecraft user to own the opt/minecraft/ directory
chown -R minecraft:minecraft /opt/minecraft/
chown minecraft:minecraft /opt/minecraft/server/server.jar

# setup configuration for minecraft.service so the server will start when the ec2 instance is running
# FILE = /etc/systemd/system/minecraft.service
vi /etc/systemd/system/minecraft.service  # paste text inside of the block comment(""" """)
# """
[Unit]
Description=Minecraft Server
After=network.target

[Service]
User=minecraft
Nice=5
KillMode=none
SuccessExitStatus=0 1
InaccessibleDirectories=/root /sys /srv /media -/lost+found
NoNewPrivileges=true
WorkingDirectory=/opt/minecraft/server
ReadWriteDirectories=/opt/minecraft/server
ExecStart=/usr/bin/java -Xmx1024M -Xms1024M -jar server.jar nogui
ExecStop=/opt/minecraft/tools/mcrcon/mcrcon -H 127.0.0.1 -P 25575 -p strong-password stop

[Install]
WantedBy=multi-user.target
# """
systemctl enable minecraft
systemctl start minecraft # start minecraft server with daemon
# ^ This may not work if you haven't started it once and changed the eula.txt file (see README)
systemctl status minecraft # check server status/logs
