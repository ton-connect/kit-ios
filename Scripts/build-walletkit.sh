#!/bin/bash

set -e  # Exit on error

# Get the script's directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Get the project root (parent of Scripts folder)
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Default walletkit folder name (in project root)
WALLETKIT_FOLDER="$PROJECT_ROOT/walletkit"
REPO_URL="https://github.com/ton-connect/kit.git"
BRANCH="main"

# Check if path parameter is provided
if [ -z "$1" ]; then
    echo "No path parameter provided. Using default walletkit folder..."
    
    # Create walletkit folder if it doesn't exist
    if [ ! -d "$WALLETKIT_FOLDER" ]; then
        echo "Creating $WALLETKIT_FOLDER folder..."
        mkdir -p "$WALLETKIT_FOLDER"
    fi
    
    # Check if repo is already cloned
    if [ ! -d "$WALLETKIT_FOLDER/.git" ]; then
        echo "Cloning repository from $REPO_URL..."
        git clone "$REPO_URL" "$WALLETKIT_FOLDER"
        cd "$WALLETKIT_FOLDER"
        git checkout "$BRANCH"
    else
        echo "Repository already cloned. Updating..."
        cd "$WALLETKIT_FOLDER"
        git checkout "$BRANCH"
        git pull origin "$BRANCH"
    fi
    
    # Set the path to current directory (walletkit folder)
    WALLETKIT_PATH="$(pwd)"
else
    echo "Using provided path: $1"
    WALLETKIT_PATH="$1"
    
    # Check if provided path exists
    if [ ! -d "$WALLETKIT_PATH" ]; then
        echo "Error: Provided path does not exist: $WALLETKIT_PATH"
        exit 1
    fi
    
    cd "$WALLETKIT_PATH"
fi

echo "Working directory: $(pwd)"

# Run pnpm build
echo "Running pnpm build..."
if ! command -v pnpm &> /dev/null; then
    echo "Error: pnpm is not installed. Please install it first."
    echo "Run: npm install -g pnpm"
    exit 1
fi

pnpm install
pnpm build --force

# Source file path
WALLETKIT_SOURCE_FILE="$WALLETKIT_PATH/packages/walletkit-ios-bridge/dist/walletkit-ios-bridge.mjs"
WALLETKIT_INJECTION_SOURCE_FILE="$WALLETKIT_PATH/packages/walletkit-ios-bridge/dist/inject.mjs"

# Destination directory (relative to project root)
DEST_DIR="$PROJECT_ROOT/Sources/TONWalletKit/Resources/JS"

# Check if source file exists
if [ ! -f "$WALLETKIT_SOURCE_FILE" ]; then
    echo "Error: Source file not found: $WALLETKIT_SOURCE_FILE"
    exit 1
fi

# Check if source file exists
if [ ! -f "$WALLETKIT_INJECTION_SOURCE_FILE" ]; then
    echo "Error: Source file not found: $WALLETKIT_SOURCE_FILE"
    exit 1
fi

# Create destination directory if it doesn't exist
echo "Creating destination directory if needed..."
mkdir -p "$DEST_DIR"

# Copy the file
echo "Copying $WALLETKIT_SOURCE_FILE to $DEST_DIR..."
cp "$WALLETKIT_SOURCE_FILE" "$DEST_DIR/"

echo "Copying $WALLETKIT_INJECTION_SOURCE_FILE to $DEST_DIR..."
cp "$WALLETKIT_INJECTION_SOURCE_FILE" "$DEST_DIR/"

echo "✅ Done! File copied successfully to $DEST_DIR/walletkit-ios-bridge.mjs"