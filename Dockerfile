# Use an official lightweight Python image.
# https://hub.docker.com/_/python
FROM bash:4.4
# Use a lightweight base image
FROM alpine:latest

# Set the working directory
WORKDIR /app

# Install required packages
RUN apk add --no-cache curl jq

# Create a non-privileged user to run the container.
RUN adduser --disabled-password --gecos '' appuser

# Copy the script into the container.
COPY download-github-releases.sh /usr/local/bin/

# Make the script executable.
RUN chmod +x /usr/local/bin/download-github-releases.sh

ENV URLS=[https://github.com/Multiverse/Multiverse-Inventories]

# Set the default command for the container.
CMD ["download-github-releases.sh"]

# Switch to the non-privileged user.
USER appuser