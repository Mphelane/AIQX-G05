#!/bin/bash

# -------------------------
# Script: deploy-to-azure.sh
# Purpose: Automate deployment of a Node.js web app to Azure
# -------------------------

# Exit on any error
set -e

# Variables
RESOURCE_GROUP="aiqx-rg"
LOCATION="South Africa North"
APP_SERVICE_PLAN="aiqx-app-splan" # App service plan for this app
WEB_APP_NAME="aiqx-node-app"  # Name of the App

# Install Node.js and npm ~ if not already installed
echo "Checking for Node.js and npm..."
if ! command -v node &> /dev/null || ! command -v npm &> /dev/null
then
    echo "...Installing Node.js and npm..."
    curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
    sudo apt-get install -y nodejs
fi

# Install Azure CLI ~if not installed
echo "...Checking for Azure CLI..."
if ! command -v az &> /dev/null
then
    echo "...Installing Azure CLI..."
    curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
fi

# Log in to Azure
echo "...Logging into Azure..."
az account show > /dev/null 2>&1 || az login

# Create Resource Group
echo "Creating resource group: $RESOURCE_GROUP"
az group create --name "$RESOURCE_GROUP" --location "$LOCATION"

# Create App Service Plan
echo "Creating App Service plan: $APP_SERVICE_PLAN"
az appservice plan create --name "$APP_SERVICE_PLAN" --resource-group "$RESOURCE_GROUP" --sku FREE --is-linux

# Create Web App
echo "Creating Web App: $WEB_APP_NAME"
az webapp create --resource-group "$RESOURCE_GROUP" --plan "$APP_SERVICE_PLAN" --name "$WEB_APP_NAME" --runtime "NODE|22-lts"

# Zip the application files
echo "Packaging the app..."
zip -r app.zip . -x "*.git*" "*node_modules*" "*.zip"

# Deploy the application
echo "Deploying the app..."
az webapp deployment source config-zip --resource-group "$RESOURCE_GROUP" --name "$WEB_APP_NAME" --src app.zip

# Output the app URL
APP_URL="https://$WEB_APP_NAME.azurewebsites.net"
echo "Tshepo, your deployment complete!"
echo "And your can access you app at: $APP_URL"
