FROM alpine:3.9
MAINTAINER Chris Kankiewicz <Chris@ChrisKankiewicz.com>

# Minecraft version
ARG MC_VERSION=1.14.2

# Set default JVM options
ENV _JAVA_OPTIONS '-Xms256M -Xmx1024M'

# Create Minecraft directories
RUN mkdir -pv /opt/minecraft /etc/minecraft

# Create non-root user
RUN adduser -DHs /sbin/nologin minecraft

# Add the EULA file
COPY files/eula.txt /etc/minecraft/eula.txt

# Add the ops script
COPY files/ops /usr/local/bin/ops
RUN chmod +x /usr/local/bin/ops

# Install dependencies, fetch Minecraft server jar file and chown files
RUN apk add --update ca-certificates nss openjdk8-jre-base tzdata wget git \
    && wget "https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/BuildTools.jar" \
    && java -jar BuildTools.jar -rev "${MC_VERSION}" \
    && mv CraftBukkit/target/craftbukkit*.jar "/opt/minecraft/craftbukkit.jar" \
    && apk del --purge git && rm -rf /var/cache/apk/* \
    && chown -R minecraft:minecraft /etc/minecraft /opt/minecraft

# Define volumes
VOLUME /etc/minecraft

# Expose port
EXPOSE 25565

# Set running user
USER minecraft

# Set the working dir
WORKDIR /etc/minecraft

# Default run command
CMD ["java", "-jar", "/opt/minecraft/craftbukkit.jar", "nogui"]
