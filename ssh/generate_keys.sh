#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Generating SSH keys for Git services...${NC}"

# Create .ssh directory if it doesn't exist
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# Function to generate a key if it doesn't exist
generate_key() {
    local key_name=$1
    local comment=$2
    
    if [ ! -f ~/.ssh/$key_name ]; then
        echo -e "${BLUE}Generating $comment key...${NC}"
        ssh-keygen -t ed25519 -f ~/.ssh/$key_name -C "$comment"
        echo -e "${GREEN}Generated $key_name${NC}"
    else
        echo -e "${GREEN}Key $key_name already exists${NC}"
    fi
}

# Generate keys
generate_key "GitHub" "GitHub"
generate_key "GHC-melker" "Local Git Server"

# Set correct permissions
chmod 600 ~/.ssh/GitHub*
chmod 600 ~/.ssh/GHC-melker*

echo -e "\n${GREEN}Keys generated successfully!${NC}"
echo -e "${BLUE}Add these public keys to their respective services:${NC}"
echo -e "GitHub key (add to GitHub.com):"
cat ~/.ssh/GitHub.pub
echo -e "\nLocal Git Server key (add to your local server):"
cat ~/.ssh/GHC-melker.pub

# Test connections
echo -e "\n${BLUE}Testing connections...${NC}"
echo -e "\nTesting GitHub connection:"
ssh -T git@github.com || true
echo -e "\nTesting Local Git Server connection:"
ssh -T git@localhost -p 2222 || true
