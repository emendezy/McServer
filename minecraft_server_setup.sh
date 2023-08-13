#!/bin/bash

echo "This must be ran as root to have the minecraft.service file created correctly"
if [ "$EUID" -ne 0 ]; then
    echo "This script requires sudo privileges. Please run with sudo."
    exit 1
fi


echo "installing yum"
sudo rpm --import https://yum.corretto.aws/corretto.key
sudo curl -L -o /etc/yum.repos.d/corretto.repo https://yum.corretto.aws/corretto.repo

echo "installing java"
sudo yum install -y java-19-amazon-corretto-devel.x86_64
echo "create minecraft user"
sudo adduser minecraft

echo "download minecraft.jar and assign permissions"
mkdir /opt/minecraft/
mkdir /opt/minecraft/server/
cd /opt/minecraft/server
wget https://launcher.mojang.com/v1/objects/a16d67e5807f57fc4e550299cf20226194497dc2/server.jar
sudo chown -R minecraft:minecraft /opt/minecraft/
sudo chown minecraft:minecraft /opt/minecraft/server/server.jar

echo "Generate minecraft systemctl service"
minecraft_configs="[Unit]\nDescription=Minecraft Server\nAfter=network.target\n\n[Service]\nUser=minecraft\nNice=5\nKillMode=none\nSuccessExitStatus=0 1\nInaccessibleDirectories=/root /sys /srv /media -/lost+found\nNoNewPrivileges=true\nWorkingDirectory=/opt/minecraft/server\nReadWriteDirectories=/opt/minecraft/server\nExecStart=/usr/bin/java -Xmx1024M -Xms1024M -jar server.jar nogui\nExecStop=/opt/minecraft/tools/mcrcon/mcrcon -H 127.0.0.1 -P 25575 -p strong-password stop\n\n[Install]\nWantedBy=multi-user.target"
sudo touch /etc/systemd/system/minecraft.service
echo "place minecraft.service config file in /etc/systemd/system"
sudo echo -e "$minecraft_configs" > /etc/systemd/system/minecraft.service
echo "enabling minecraft service"
sudo systemctl enable minecraft
echo "starting minecraft service"
sudo systemctl start minecraft
