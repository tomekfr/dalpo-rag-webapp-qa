#!/bin/bash

# Development setup script for Dalpo RAG Web App
# This script helps you run the application locally using Docker

set -e

echo "🚀 Starting Dalpo RAG Web App locally..."

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker Desktop and try again."
    exit 1
fi

# Check if .env file exists
if [ ! -f ".env" ]; then
    echo "❌ .env file not found. Please make sure the environment configuration is set up."
    exit 1
fi

echo "📦 Building Docker image..."
docker-compose build

echo "🔄 Starting the application..."
docker-compose up -d

echo "✅ Application is starting up..."
echo "🌐 The app will be available at: http://localhost:8080"
echo ""
echo "📝 Useful commands:"
echo "   View logs:     docker-compose logs -f"
echo "   Stop app:      docker-compose down"
echo "   Rebuild:       docker-compose build --no-cache"
echo ""
echo "⏳ Waiting for the application to be ready..."

# Wait for the application to be ready
for i in {1..30}; do
    if curl -s http://localhost:8080 > /dev/null 2>&1; then
        echo "🎉 Application is ready! Visit http://localhost:8080"
        break
    fi
    if [ $i -eq 30 ]; then
        echo "⚠️  Application might still be starting up. Check logs with: docker-compose logs"
    fi
    sleep 2
done
