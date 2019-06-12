#!/bin/bash
docker run -it -d -p 25565:25565 -p 8080:8123 -e _JAVA_OPTIONS='-Xms256M -Xmx6000M' -v minecraft-data:/etc/minecraft --name minecraft-server minecraft:bukkit1.14.2
