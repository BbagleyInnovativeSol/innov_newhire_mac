# Install homebrew for cli and app installs
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

brew install --cask visual-studio-code

brew install --cask postman

brew install --cask docker-desktop

# AWS CLI
curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
sudo installer -pkg AWSCLIV2.pkg -target /

# Installs latest python version in /opt/homebrew/bin/python3.xx
brew install python

brew install node

brew install mysql # Or brew install postgresql@14

brew install aws-sam-cli

brew install --cask session-manager-plugin

brew tap xwmx/taps

brew install hosts

brew install sevenzip

# Personal 
brew install jq
brew install uv #Rust built python package manager with virtualenv and dependency eanagement
brew install gh

