#!/bin/bash

# Azure Deployment Script for Dalpo AI Chat
# This script builds and deploys the application to Azure with authentication enabled

set -e  # Exit on any error

echo "🚀 Starting Azure deployment build for Dalpo AI Chat..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

# Configuration
AZURE_WEBAPP_NAME="webapp-dalpo-ai-docs-qa-custom"
ACR_NAME="crdalpoaidocsqazhxbjt"
IMAGE_NAME="dalpo-ai-chat"
IMAGE_TAG="latest"

# Check if required tools are installed
echo "🔍 Checking prerequisites..."

if ! command -v node &> /dev/null; then
    print_error "Node.js is not installed. Please install Node.js first."
    exit 1
fi

if ! command -v npm &> /dev/null; then
    print_error "npm is not installed. Please install npm first."
    exit 1
fi

if ! command -v python3 &> /dev/null; then
    print_error "Python 3 is not installed. Please install Python 3 first."
    exit 1
fi

if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed. Please install Docker first."
    exit 1
fi

if ! command -v az &> /dev/null; then
    print_error "Azure CLI is not installed. Please install Azure CLI first."
    exit 1
fi

print_status "All prerequisites are available"

# Check Azure login
echo "🔐 Checking Azure authentication..."
if ! az account show &> /dev/null; then
    print_warning "Not logged into Azure. Please login..."
    az login
fi

print_status "Azure authentication verified"

# Create/update .env file for Azure deployment
echo "📝 Creating Azure environment configuration..."

cat > .env << 'EOF'
# Azure Deployment Configuration - AUTH ENABLED
AUTH_ENABLED=true

# UI Configuration with Dalpo Branding
UI_TITLE=Dalpo AI Chat
UI_LOGO=assets/logo-dalpo-colored.svg
UI_CHAT_LOGO=assets/logo-dalpo-colored.svg
UI_CHAT_TITLE=Dalpo AI Chat
UI_CHAT_DESCRIPTION=Zadaj pytanie dotyczące polityk i procedur firmy

# Azure OpenAI Configuration
AZURE_OPENAI_ENDPOINT=https://aoai-dalpo-ai-docs-qa-zhxbjt.openai.azure.com/
AZURE_OPENAI_MODEL=gpt-4o-mini
AZURE_OPENAI_MODEL_NAME=gpt-4o-mini
AZURE_OPENAI_API_VERSION=2024-06-01
AZURE_OPENAI_STREAM=true
AZURE_OPENAI_EMBEDDING_ENDPOINT=https://aoai-dalpo-ai-docs-qa-zhxbjt.openai.azure.com/
AZURE_OPENAI_EMBEDDING_MODEL=text-embedding-3-small
AZURE_OPENAI_EMBEDDING_API_VERSION=2024-06-01

# Data Source Configuration
DATASOURCE_TYPE=AzureCognitiveSearch

# Azure Cognitive Search Configuration
AZURE_SEARCH_SERVICE=srch-dalpo-ai-docs-qa
AZURE_SEARCH_INDEX=rag-1750672537069
AZURE_SEARCH_USE_SEMANTIC_SEARCH=true
AZURE_SEARCH_SEMANTIC_SEARCH_CONFIG=my-semantic-config
AZURE_SEARCH_TOP_K=5
AZURE_SEARCH_ENABLE_IN_DOMAIN=true
AZURE_SEARCH_CONTENT_COLUMNS=content
AZURE_SEARCH_FILENAME_COLUMN=filename
AZURE_SEARCH_TITLE_COLUMN=title
AZURE_SEARCH_URL_COLUMN=url
AZURE_SEARCH_VECTOR_COLUMNS=contentVector
AZURE_SEARCH_QUERY_TYPE=vectorSimpleHybrid
AZURE_SEARCH_PERMITTED_GROUPS_COLUMN=

# Cosmos DB Configuration
AZURE_COSMOSDB_DATABASE=dalpoaidocsqa
AZURE_COSMOSDB_ACCOUNT=cosmos-dalpo-ai-docs-qa-zhxbjt
AZURE_COSMOSDB_CONVERSATIONS_CONTAINER=conversations

# Authentication Configuration
AZURE_USE_AUTHENTICATION=true
AZURE_ENFORCE_ACCESS_CONTROL=false
AZURE_ENABLE_GLOBAL_DOCUMENT_ACCESS=true
ENABLE_ORYX_BUILD=true
SCM_DO_BUILD_DURING_DEPLOYMENT=1
EOF

print_status "Azure environment file created"

# Build Frontend
echo "🎨 Building frontend..."
cd frontend

print_status "Installing frontend dependencies..."
npm install

print_status "Building frontend for production..."
npm run build

cd ..
print_status "Frontend build completed"

# Build Docker Image with Linux platform for Azure
echo "🐳 Building Docker image for Azure deployment..."

print_status "Building Docker image with Linux AMD64 platform..."
docker buildx build --platform linux/amd64 -t ${ACR_NAME}.azurecr.io/${IMAGE_NAME}:${IMAGE_TAG} .

print_status "Docker image build completed"

# Authenticate with Azure Container Registry
echo "🔐 Authenticating with Azure Container Registry..."
az acr login --name ${ACR_NAME}

print_status "ACR authentication successful"

# Push Docker Image to ACR
echo "📤 Pushing Docker image to Azure Container Registry..."
docker push ${ACR_NAME}.azurecr.io/${IMAGE_NAME}:${IMAGE_TAG}

print_status "Docker image pushed successfully"

# Deploy Environment Variables to Azure Web App
echo "⚙️ Deploying environment variables to Azure Web App..."

# Read .env file and set app settings
while IFS='=' read -r key value; do
    # Skip comments and empty lines
    if [[ $key =~ ^[[:space:]]*# ]] || [[ -z $key ]]; then
        continue
    fi
    
    # Remove any quotes from value
    value=$(echo "$value" | sed 's/^"\(.*\)"$/\1/')
    
    print_info "Setting $key"
    az webapp config appsettings set \
        --name ${AZURE_WEBAPP_NAME} \
        --resource-group rg-dalpo-ai-docs-qa \
        --settings "$key=$value" \
        --output none
done < .env

print_status "Environment variables deployed"

# Set additional Azure-specific configurations
echo "🔧 Setting Azure-specific configurations..."

# Set container image
az webapp config container set \
    --name ${AZURE_WEBAPP_NAME} \
    --resource-group rg-dalpo-ai-docs-qa \
    --docker-custom-image-name ${ACR_NAME}.azurecr.io/${IMAGE_NAME}:${IMAGE_TAG} \
    --docker-registry-server-url https://${ACR_NAME}.azurecr.io \
    --output none

print_status "Container image configured"

# Restart the web app to apply changes
echo "🔄 Restarting Azure Web App..."
az webapp restart \
    --name ${AZURE_WEBAPP_NAME} \
    --resource-group rg-dalpo-ai-docs-qa \
    --output none

print_status "Web App restarted"

# Wait for deployment to complete
echo "⏳ Waiting for deployment to complete..."
sleep 30

# Test deployment
echo "🧪 Testing deployment..."
WEBAPP_URL="https://${AZURE_WEBAPP_NAME}.azurewebsites.net"

if curl -s --max-time 30 "$WEBAPP_URL" | grep -q "Dalpo AI Chat"; then
    print_status "Deployment test successful"
else
    print_warning "Deployment test inconclusive - please check manually"
fi

echo ""
echo "🎉 Azure deployment completed successfully!"
echo ""
echo "📋 Deployment Summary:"
echo "- Web App: ${AZURE_WEBAPP_NAME}"
echo "- Container Image: ${ACR_NAME}.azurecr.io/${IMAGE_NAME}:${IMAGE_TAG}"
echo "- Authentication: ENABLED"
echo "- UI Branding: Dalpo AI Chat with Polish interface"
echo ""
echo "🌐 Application URL: ${WEBAPP_URL}"
echo ""
echo "🔧 Useful commands:"
echo "- View app logs: az webapp log tail --name ${AZURE_WEBAPP_NAME} --resource-group rg-dalpo-ai-docs-qa"
echo "- Check app settings: az webapp config appsettings list --name ${AZURE_WEBAPP_NAME} --resource-group rg-dalpo-ai-docs-qa"
echo "- Restart app: az webapp restart --name ${AZURE_WEBAPP_NAME} --resource-group rg-dalpo-ai-docs-qa"
echo ""
print_warning "Remember: Authentication is ENABLED for Azure deployment"
print_info "Identity provider should be configured separately in Azure Portal if not already done"
