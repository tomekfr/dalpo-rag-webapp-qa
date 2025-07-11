#!/bin/bash

# Python development setup for Dalpo RAG Web App
# Run the application directly with Python (no Docker)

set -e

echo "🐍 Setting up Python environment for Dalpo RAG Web App..."

# Check if Python 3.11+ is available
python_version=$(python3 --version 2>&1 | cut -d' ' -f2 | cut -d'.' -f1,2)
required_version="3.11"

if [ "$(printf '%s\n' "$required_version" "$python_version" | sort -V | head -n1)" != "$required_version" ]; then
    echo "❌ Python 3.11+ is required. Found: $python_version"
    exit 1
fi

# Check if .env file exists
if [ ! -f ".env" ]; then
    echo "❌ .env file not found. Please make sure the environment configuration is set up."
    exit 1
fi

# Create virtual environment if it doesn't exist
if [ ! -d "venv" ]; then
    echo "📦 Creating Python virtual environment..."
    python3 -m venv venv
fi

# Activate virtual environment
echo "🔄 Activating virtual environment..."
source venv/bin/activate

# Install dependencies
echo "📚 Installing Python dependencies..."
pip install --upgrade pip
pip install -r requirements.txt

# Set environment variables
echo "🔧 Loading environment variables..."
export $(cat .env | grep -v '^#' | xargs)

# Build frontend if needed
if [ ! -f "static/index.html" ]; then
    echo "🏗️  Building frontend..."
    cd frontend
    npm install
    npm run build
    cd ..
fi

echo "🚀 Starting the application..."
echo "🌐 The app will be available at: http://localhost:8080"
echo ""
echo "📝 Use Ctrl+C to stop the application"
echo ""

# Start the application using uvicorn (same as production but with reload)
uvicorn app:app --host 0.0.0.0 --port 8000 --reload
