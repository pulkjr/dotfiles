#!/bin/env bash

# Validate if podman is installed. If installed link docker to podman
if command -v podman >/dev/null 2>&1; then
    echo "Podman is installed. Linking docker and docker-compose to podman."
    podman_dir="$(dirname "$(which podman)")"
    if ! command -v docker >/dev/null 2>&1 && [ ! -e "${podman_dir}/docker" ]; then
        ln -s "${podman_dir}/podman" "${podman_dir}/docker"
    else
        echo "docker is already installed or the link already exists."
    fi
fi

read -p "Enter your Git username: " git_username
read -p "Enter your Git email: " git_email

config_dir="$HOME/.config/git"
config_file="$config_dir/config.local"

mkdir -p "$config_dir"

cat > "$config_file" <<EOF
[user]
  name = $git_username
  email = $git_email
EOF

echo "Git user config written to $config_file"

# If this is a mac then run the macOS defaults script
if [[ "$(uname)" == "Darwin" ]]; then
    if [ -f "./macos/defaults.sh" ]; then
        echo "macOS detected. Applying macOS defaults..."
        chmod +x ./macos/defaults.sh
        ./macos/defaults.sh
    else
        echo "defaults.sh not found. Skipping macOS defaults."
    fi
else
    echo "Non-macOS system detected. Skipping macOS defaults."
fi
