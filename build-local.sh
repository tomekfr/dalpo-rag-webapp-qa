#!/bin/bash

# Local Development Build Script for Dalpo AI Chat
# This script builds the frontend, backend, and Docker image for localhost development

set -e  # Exit on any error

echo "🚀 Starting local development build for Dalpo AI Chat..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
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

print_status "All prerequisites are available"

# Create/update .env file for local development
echo "📝 Creating local environment configuration..."

cat > .env << 'EOF'
# Local Development Configuration - AUTH DISABLED
AUTH_ENABLED=false

# UI Configuration with Dalpo Branding
UI_TITLE=Dalpo AI Chat
UI_LOGO=assets/logo-dalpo-colored.svg
UI_CHAT_LOGO=assets/logo-dalpo-colored.svg
UI_CHAT_TITLE=Dalpo AI Chat
UI_CHAT_DESCRIPTION=Zadaj pytanie dotyczące polityk i procedur firmy

# Azure OpenAI Configuration (from production)
AZURE_OPENAI_ENDPOINT=https://aoai-dalpo-ai-docs-qa-zhxbjt.openai.azure.com/
AZURE_OPENAI_MODEL=gpt-4o-mini
AZURE_OPENAI_MODEL_NAME=gpt-4o-mini
AZURE_OPENAI_API_VERSION=2024-06-01
AZURE_OPENAI_STREAM=true
AZURE_OPENAI_API_KEY=your_openai_api_key_here
AZURE_OPENAI_EMBEDDING_ENDPOINT=https://aoai-dalpo-ai-docs-qa-zhxbjt.openai.azure.com/
AZURE_OPENAI_EMBEDDING_MODEL=text-embedding-3-small
AZURE_OPENAI_EMBEDDING_API_VERSION=2024-06-01
AZURE_OPENAI_EMBEDDING_API_KEY=your_embedding_api_key_here

# Data Source Configuration
DATASOURCE_TYPE=AzureCognitiveSearch

# Azure Cognitive Search Configuration
AZURE_SEARCH_SERVICE=srch-dalpo-ai-docs-qa
AZURE_SEARCH_INDEX=rag-1750672537069
AZURE_SEARCH_KEY=your_search_key_here
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
AZURE_COSMOSDB_ACCOUNT_KEY=your_cosmos_key_here

# System Configuration
AZURE_USE_AUTHENTICATION=false
AZURE_ENFORCE_ACCESS_CONTROL=false
AZURE_ENABLE_GLOBAL_DOCUMENT_ACCESS=true
ENABLE_ORYX_BUILD=true
SCM_DO_BUILD_DURING_DEPLOYMENT=1

# Local Development Settings
FLASK_ENV=development
FLASK_DEBUG=true
PORT=5000
EOF

print_status "Local environment file created (.env)"
print_warning "Please update the API keys in .env file with your actual Azure credentials"

# Build Frontend
echo "🎨 Building frontend..."
cd frontend

print_status "Installing frontend dependencies..."
npm install

print_status "Building frontend for production..."
npm run build

cd ..
print_status "Frontend build completed"

# Prepare Backend
echo "🐍 Preparing backend..."

if [ ! -f "requirements.txt" ]; then
    print_error "requirements.txt not found!"
    exit 1
fi

print_status "Backend requirements verified"

# Build Docker Image
echo "🐳 Building Docker image for local development..."

# Stop and remove existing containers
print_status "Cleaning up existing containers..."
docker-compose down --remove-orphans 2>/dev/null || true

# Build the Docker image
print_status "Building Docker image..."
docker-compose build --no-cache

print_status "Docker image build completed"

# Start the application
echo "🚀 Starting application..."
docker-compose up -d

print_status "Application started successfully!"

echo ""
echo "🎉 Local development build completed!"
echo ""
echo "📋 Next steps:"
echo "1. Update API keys in .env file"
echo "2. Application is running at: http://localhost:5000"
echo "3. Frontend development server (if needed): cd frontend && npm run dev"
echo ""
echo "🔧 Useful commands:"
echo "- View logs: docker-compose logs -f"
echo "- Stop application: docker-compose down"
echo "- Rebuild: ./build-local.sh"
echo ""
print_warning "Remember: Authentication is DISABLED for local development"
