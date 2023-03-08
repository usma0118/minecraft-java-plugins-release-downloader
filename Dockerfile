FROM bash:4.4

# Install required packages perl-utiils for shasum
RUN apk add --no-cache curl jq perl-utils

# Create a non-privileged user to run the container.
RUN adduser --disabled-password --gecos '' appuser

# Copy the script into the container.
COPY download-github-releases.sh /usr/local/bin/

# Make the script executable.
RUN chmod +x /usr/local/bin/download-github-releases.sh
VOLUME [ "/plugins" ]
ENV URLS="https://github.com/EssentialsX/Essentials,\
https://github.com/EngineHub/WorldEdit,\
https://github.com/lucko/LuckPerms,\
https://github.com/Multiverse/Multiverse-Core"

WORKDIR /tmp
# Set the default command for the container.
CMD ["download-github-releases.sh"]

# Switch to the non-privileged user.
USER appuser