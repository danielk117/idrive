FROM ubuntu:latest

RUN mkdir -p /home/backup

WORKDIR /work

# Copy entrypoint script
COPY entrypoint.sh .
RUN chmod a+x entrypoint.sh

# Install packages
RUN apt update && \
    apt install -y vim unzip curl libfile-spec-native-perl && \
    apt install -y build-essential sqlite3 perl-doc libdbi-perl libdbd-sqlite3-perl && \
    DEBIAN_FRONTEND=noninteractive apt install -y --no-install-recommends tzdata && \
    rm -rf /var/lib/apt/lists

RUN cpan install common::sense
RUN cpan install Linux::Inotify2

# Timezone (no prompt)
RUN echo "Europe/Berlin" > /etc/timezone
RUN rm -f /etc/localtime
RUN dpkg-reconfigure -f noninteractive tzdata

# Install IDrive
RUN curl -O https://www.idrivedownloads.com/downloads/linux/download-for-linux/LinuxScripts/IDriveForLinux.zip && \
    unzip IDriveForLinux.zip

RUN rm IDriveForLinux.zip

WORKDIR /work/IDriveForLinux/scripts

# Give execution rights
RUN chmod a+x *.pl

# Create the log file to be able to run tail
RUN touch /var/log/idrive.log

# Run the command on container startup
ENTRYPOINT ["/work/entrypoint.sh"]
