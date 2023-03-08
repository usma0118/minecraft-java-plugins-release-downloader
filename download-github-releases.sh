#!/usr/bin/env bash

# Define the GitHub URLs to download from
if [ -z "$URLS" ]; then
    echo "Error: URLS environment variable is empty or not set"
    exit 1
fi
urls=$URLS

# Define the logging functions
log_info() {
    echo -e "\033[32m[INFO] $1\033[0m"
}

log_error() {
    echo -e "\033[31m[ERROR] $1\033[0m" >&2
}

log_verbose() {
    if [ "$verbose" = "true" ]; then
        echo -e "\033[34m[VERBOSE] $1\033[0m"
    fi
}

# Define the command line options
while getopts "v" opt; do
    case $opt in
        v)
            verbose="true"
            ;;
        \?)
            log_error "Invalid option: -$OPTARG"
            exit 1
            ;;
    esac
done

# Loop through each URL and download the latest version if it's not already downloaded
IFS=',' read -ra URLS_ARRAY <<< "$urls"
for url in "${URLS_ARRAY[@]}"; do
    # Extract the owner and repository name from the URL
    owner=$(echo "$url" | cut -d '/' -f 4)
    repo=$(echo "$url" | cut -d '/' -f 5)

    # Print the owner and repository name for debugging
    log_verbose "Owner: $owner"
    log_verbose "Repository: $repo"

    # Get the latest release version from the GitHub API
    release=$(curl --silent "https://api.github.com/repos/$owner/$repo/releases/latest" | jq -r '.tag_name')

    # Print the latest release version for debugging
    log_verbose "Latest release: $release"

    # Calculate the SHA-256 checksum of the release
    checksum=$(curl --silent "https://api.github.com/repos/$owner/$repo/releases/latest" | jq -r '.assets[0].browser_download_url' | xargs curl -Ls | shasum -a 256 | awk '{print $1}')

    # Print the checksum for debugging
    log_verbose "Checksum: $checksum"

    # Define the filename to save the release as
    filename="$repo-$release.zip"

    # Check if the file already exists and has the correct checksum
    if [ -f "$filename" ] && [ "$(shasum -a 256 "$filename" | awk '{print $1}')" = "$checksum" ]; then
        log_info "$filename is up to date"
    else
        # Download the release
        log_info "Downloading $filename..."
        curl -Ls "https://api.github.com/repos/$owner/$repo/releases/latest" | jq -r '.assets[0].browser_download_url' | xargs curl -Ls -o "$filename"

        # Verify the downloaded file's checksum
        if [ "$(shasum -a 256 "$filename" | awk '{print $1}')" != "$checksum" ]; then
            log_error "Checksum verification failed for $filename"
            rm "$filename"
            exit 1
        fi

        # Print a success message
        log_info "Downloaded $filename successfully"
    fi
done
