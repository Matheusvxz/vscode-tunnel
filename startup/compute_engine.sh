#!/bin/bash
VSCODE_CLI_FOLDER="/usr/local/vscode-cli"
GLOBAL_DATA_DIR="$VSCODE_CLI_FOLDER/data"
USER_DATA_DIR="~/.vscode/cli/"
VSCODE_CLI_BIN="$VSCODE_CLI_FOLDER/bin"
VSCODE_CLI="$VSCODE_CLI_BIN/code"

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
        curl -Lk "https://code.visualstudio.com/sha/download?build=$VS_CODE_BUILD&os=cli-alpine-x64" | tar -xzv -C $VSCODE_CLI_BIN
        chmod +x "$VSCODE_CLI_BIN/code"
    fi
}

get_google_metadata() {
    local metadata_name="$1"
    local metadata_url="http://metadata.google.internal/computeMetadata/v1/instance/attributes"

    local metadata_value="$(curl "$metadata_url/$metadata_name" -H "Metadata-Flavor: Google" 2>/dev/null)"
    echo $metadata_value
}


if [ -f "$VSCODE_CLI_BIN/code" ]; then
    echo "VS Code CLI already installed."
else
    install_vscode_cli
fi

DEFAULT_USER=$(get_google_metadata user)

echo "Checking user $DEFAULT_USER"
if user_exists $DEFAULT_USER; then
    echo "User exists"
    echo "Skipping creation..."
else
    echo "User not exists"
    echo "Creating user..."
    adduser --disabled-password --gecos "" $DEFAULT_USER
fi

echo "Running as user $DEFAULT_USER"
echo "Initializing VS Code Tunnel service"

su -c "mkdir -p $USER_DATA_DIR" $DEFAULT_USER
token=$(echo "\"$(get_google_metadata token)\"")
su -c "echo $token > $USER_DATA_DIR/token.json" $DEFAULT_USER

export VSCODE_CLI_USE_FILE_KEYCHAIN=1

su -c "cd ~ && $VSCODE_CLI tunnel --name=$(get_google_metadata tunnel-name) --accept-server-license-terms" $DEFAULT_USER
