FROM alpine:3.9 AS build
MAINTAINER Chris Kankiewicz <Chris@ChrisKankiewicz.com>

# Minecraft version
ARG MC_VERSION=1.14.2
ARG MC_JAR_SHA1=808be3869e2ca6b62378f9f4b33c946621620019

# Set jar file URL
ARG JAR_URL=https://launcher.mojang.com/v1/objects/${MC_JAR_SHA1}/server.jar

# Set default JVM options
ENV _JAVA_OPTIONS '-Xms256M -Xmx1024M'

# Create Minecraft directories
RUN mkdir -pv /opt/minecraft

# Add the ops script
COPY files/ops /usr/local/bin/ops
RUN chmod +x /usr/local/bin/ops

ADD https://github.com/itzg/rcon-cli/releases/download/1.4.7/rcon-cli_1.4.7_linux_amd64.tar.gz /rcon.tar.gz
RUN tar -xzf /rcon.tar.gz -C /usr/local/bin

# Install dependencies, fetch Minecraft server jar file and chown files
RUN apk add --update ca-certificates nss openjdk8-jre-base tzdata wget git

ADD "https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/BuildTools.jar" .

RUN java -jar BuildTools.jar -rev "${MC_VERSION}"

RUN mv CraftBukkit/target/craftbukkit*.jar "/opt/minecraft/craftbukkit.jar"


FROM alpine:3.9

RUN apk --no-cache add openjdk8-jre-base

RUN adduser -DHs /sbin/nologin minecraft

COPY --from=build --chown=minecraft:minecraft /opt/minecraft/craftbukkit.jar /opt/minecraft/
COPY --from=build --chown=minecraft:minecraft /usr/local/bin/rcon-cli /usr/local/bin/

# Expose port
EXPOSE 25565

# Set running user
USER minecraft

# Set the working dir
WORKDIR /etc/minecraft

# Define volumes
VOLUME /etc/minecraft

# Default run command
CMD ["java", "-jar", "/opt/minecraft/craftbukkit.jar", "nogui"]
