#!/bin/bash

#Contact: Stan Iwan
#         Sofomo
#         2024.04.09

clone_repository_with_retries() {
    local repo_url="$1"
    local custom_folder_name="$2" # This could be omitted if not needed
    local max_retries=4
    local retry_wait_seconds=60
    local attempt=1

    while [ $attempt -le $max_retries ]; do
        echo "Attempt $attempt to clone $repo_url"
        if [[ -n "$custom_folder_name" ]]; then
            git clone "$repo_url" "$custom_folder_name" && echo "Successfully cloned $repo_url into $custom_folder_name" && return 0
        else
            git clone "$repo_url" && echo "Successfully cloned $repo_url" && return 0
        fi

        echo "Failed to clone repository. Retrying in $retry_wait_seconds seconds..."
        ((attempt++))
        sleep $retry_wait_seconds
    done

    echo "Failed to clone repository after $max_retries attempts. Please check your network connection or the repository URL and try again."
    return 1
}

