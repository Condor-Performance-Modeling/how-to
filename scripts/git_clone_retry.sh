#!/bin/bash

set -e

#Contact: Stan Iwan
#         Sofomo
#         2024.04.09

clone_repository_with_retries() {
    local repo_url="$1"
    local custom_folder_name="$2"
    local clone_options="$3"       # Additional options for git clone
    local max_retries=4
    local retry_wait_seconds=60
    local attempt=1

    local target_folder="$custom_folder_name"
    if [ -z "$target_folder" ]; then
        target_folder=$(basename "$repo_url" .git)
    fi

    if [ -d "$target_folder" ]; then
        local backup_folder="${target_folder}_old"
        echo "Repository directory '$target_folder' already exists. Renaming to '$backup_folder'."
        mv "$target_folder" "$backup_folder"
    fi

    while [ $attempt -le $max_retries ]; do
        echo "Attempt $attempt to clone $repo_url"
        
        if [[ -n "$custom_folder_name" ]]; then
            git clone $clone_options "$repo_url" "$custom_folder_name"
        else
            git clone $clone_options "$repo_url"
        fi

        if [ $? -eq 0 ]; then
            echo "Successfully cloned $repo_url"
            return 0
        else
            echo "Failed to clone repository. Cleaning up partial results..."
            local folder_to_remove="$custom_folder_name"
            if [ -z "$folder_to_remove" ]; then
                folder_to_remove=$(basename "$repo_url" .git)
            fi
            [ -d "$folder_to_remove" ] && rm -rf "$folder_to_remove"

            echo "Retrying in $retry_wait_seconds seconds..."
            ((attempt++))
            sleep $retry_wait_seconds
        fi
    done

    echo "Failed to clone repository after $max_retries attempts. Please check your network connection or the repository URL and try again."
    return 1
}

