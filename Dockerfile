# Use an official Ubuntu base image
FROM ubuntu:22.04

# Avoid warnings by switching to noninteractive for the build process
ENV DEBIAN_FRONTEND=noninteractive

ENV USER=root

# Updates packages
RUN apt-get update

# Install XFCE, VNC server, dbus-x11, and xfonts-base, wget, Xvfb, Xte, jq
RUN apt-get install -y \
    xfce4 \
    xfce4-goodies \
    xfwm4 \
    tigervnc-standalone-server \
    tigervnc-xorg-extension \
    dbus-x11 \
    xfonts-base \
    wget \
    curl \
    xautomation \
    cabextract \
    jq

# update ca certificates
RUN apt-get install ca-certificates -y

# Install novnc
RUN apt-get -y install novnc python3-websockify
COPY patch_novnc.sh patch_novnc.sh
RUN chmod +x patch_novnc.sh && ./patch_novnc.sh && rm patch_novnc.sh
RUN cp /usr/share/novnc/vnc.html /usr/share/novnc/index.html

# Install client
RUN wget -O /tmp/client.deb https://github.com/meshtastic/network-management-client/releases/download/v0.3.1/Meshtastic.Network.Management.Client_0.3.1_amd64.deb
RUN apt install /tmp/client.deb -y

# clean up installers
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Setup VNC server
RUN mkdir /root/.vnc \
    && echo "Meshtastic" | vncpasswd -f > /root/.vnc/passwd \
    && chmod 600 /root/.vnc/passwd

# Create an .Xauthority file
RUN touch /root/.Xauthority

# Set the working directory in the container
WORKDIR /app

# Copy a script to start the VNC server
COPY start-vnc.sh start-vnc.sh
RUN chmod +x start-vnc.sh
COPY xstartup.sh /root/.vnc/xstartup
RUN chmod +x /root/.vnc/xstartup

HEALTHCHECK --interval=5s \
  CMD pgrep -f "WebKitWebProcess" || exit 1

ENTRYPOINT ["/app/start-vnc.sh"]
