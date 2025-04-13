#!/bin/bash
DEFAULT_USER="matheus"

VSCODE_CLI_FOLDER="/usr/local/vscode-cli"
GLOBAL_DATA_DIR="$VSCODE_CLI_FOLDER/data"
VSCODE_CLI_BIN="$VSCODE_CLI_FOLDER/bin"
VS_CODE_BUILD=${1:-stable}

user_exists() {
    id -u "$1" >/dev/null 2>&1
    code=$?
    return $code
}

install_vscode_cli() {
    if [ ! -d "$VSCODE_CLI_FOLDER" ]; then
        mkdir -p "$VSCODE_CLI_FOLDER"
        mkdir -p "$GLOBAL_DATA_DIR"
    fi

    if [ ! -d "$GLOBAL_DATA_DIR" ]; then
        mkdir -p "$GLOBAL_DATA_DIR"
    fi

    if [ ! -d "$VSCODE_CLI_BIN" ]; then
        mkdir -p "$VSCODE_CLI_BIN"
    fi

    if [ ! -f "$VSCODE_CLI_BIN/code" ]; then
        curl -Lk "https://code.visualstudio.com/sha/download?$VS_CODE_BUILD=stable&os=cli-alpine-x64" | tar -xf -C $VSCODE_CLI_BIN --no-same-owner
        chmod +x "$VSCODE_CLI_BIN/code"
    fi
}

get_google_metadata() {
    local metadata_name = "$1"
    local metadata_url = "http://metadata.google.internal/computeMetadata/v1/instance/attributes/"

    local metadata_value = "$(curl $metadata_url$metadata_name -H "Metadata-Flavor: Google")"

    echo $metadata_value
}

if [ -f "$VSCODE_CLI_BIN/code" ]; then
    echo "VS Code CLI already installed."
else
    install_vscode_cli
fi

echo "Checking user $DEFAULT_USER"
if user_exists $DEFAULT_USER; then
    echo "User exists"
    echo "Skipping creation..."
else
    echo "User not exists"
    echo "Creating user..."
    adduser --disabled-password --gecos "" $DEFAULT_USER
fi

echo "Running as user $(whoami)"
echo "Initializing VS Code Tunnel service"

echo "\"$(get_google_metadata token)\"" > $GLOBAL_DATA_DIR/token.json

su -c "$FILE tunnel --name=$(get_google_metadata tunnel-name) --server-data-dir=$GLOBAL_DATA_DIR --no-sleep --accept-server-license-terms" $DEFAULT_USER