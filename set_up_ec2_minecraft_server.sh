#!/bin/bash
# *NOTE* For now these commands will have to be ran manually once you're ssh'ed onto the ec2 instance
# install Java 17
sudo rpm --import https://yum.corretto.aws/corretto.key
sudo curl -L -o /etc/yum.repos.d/corretto.repo https://yum.corretto.aws/corretto.repo
# Java version entirely depends on the version of minecraft out right now.
sudo yum install -y java-19-amazon-corretto-devel.x86_64

# add dedicated user for doing minecraft server work
sudo adduser minecraft &&

# use root user to set up our server files
sudo su
mkdir /opt/minecraft/
mkdir /opt/minecraft/server/
cd /opt/minecraft/server
wget https://launcher.mojang.com/v1/objects/a16d67e5807f57fc4e550299cf20226194497dc2/server.jar


# set our minecraft user to own the opt/minecraft/ directory
sudo chown -R minecraft:minecraft /opt/minecraft/

# setup configuration for minecraft.service so the server will start when the ec2 instance is running
# FILE = /etc/systemd/system/minecraft.service
vi /etc/systemd/system/minecraft.service  # place text from [Unit] to EOM, but not including "EOM"
/bin/cat <<EOM >$FILE
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
EOM
chmod 664 $FILE
systemctl daemon-reload
