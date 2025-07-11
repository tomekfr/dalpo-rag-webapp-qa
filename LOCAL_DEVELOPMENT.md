# Dalpo RAG Web App - Local Development Setup

This document explains how to run the Dalpo RAG (Retrieval-Augmented Generation) web application locally on your macOS, replicating the environment from the Azure deployment `webapp-dalpo-ai-docs-qa-custom`.

## 📋 Prerequisites

- **Docker Desktop** (recommended for exact environment match)
- **Python 3.11+** (alternative to Docker)
- **Node.js 20+** (if you need to rebuild frontend)

## 🚀 Quick Start (Docker - Recommended)

The easiest way to run the application exactly as it runs in Azure:

```bash
# Make sure Docker Desktop is running
./run-local.sh
```

This will:
- Build the Docker image using the same Dockerfile as Azure
- Start the application on http://localhost:8000
- Load all Azure configuration from the `.env` file

## 🐍 Alternative: Python Development Mode

For faster development cycles with hot reloading:

```bash
./run-python.sh
```

This will:
- Create a Python virtual environment
- Install dependencies
- Start the application with auto-reload on http://localhost:8000

## ⚙️ Configuration

The application is configured to connect to the same Azure resources as the production deployment:

### Azure Services Connected:
- **Azure OpenAI**: `openai-dalpo-ai-docs-qa.openai.azure.com`
- **Azure Cosmos DB**: `db-webapp-dalpo-ai-docs-qa`
- **Azure Cognitive Search**: `srch-dalpo-ai-docs-qa`

### Environment Variables

All configuration is stored in `.env` file, which contains the exact same settings as the Azure deployment:

- `AZURE_OPENAI_*` - OpenAI GPT-4o-mini and embeddings configuration
- `AZURE_COSMOSDB_*` - Cosmos DB for conversation history
- `AZURE_SEARCH_*` - Cognitive Search for RAG functionality
- `DATASOURCE_TYPE=AzureCognitiveSearch` - Primary data source

## 🔧 Manual Setup

If you prefer manual setup:

### Docker Approach:
```bash
# Build the image
docker-compose build

# Start the application
docker-compose up -d

# View logs
docker-compose logs -f

# Stop the application
docker-compose down
```

### Python Approach:
```bash
# Create virtual environment
python3 -m venv venv
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Load environment variables and start
export $(cat .env | grep -v '^#' | xargs)
uvicorn app:app --host 0.0.0.0 --port 8000 --reload
```

## 🌐 Access the Application

Once running, access the application at:
- **Main Application**: http://localhost:8000
- **Health Check**: http://localhost:8000/health (if available)

## 📁 Project Structure

```
├── app.py                 # Main Quart application
├── backend/               # Backend modules
│   ├── settings.py        # Configuration management
│   ├── auth/              # Authentication utilities
│   ├── history/           # Cosmos DB service
│   └── security/          # Security utilities
├── frontend/              # React TypeScript frontend
├── static/                # Built frontend assets
├── infra/                 # Bicep infrastructure templates
├── requirements.txt       # Python dependencies
├── WebApp.Dockerfile      # Production Docker image
├── docker-compose.yml     # Local development setup
└── .env                   # Environment configuration
```

## 🔍 Troubleshooting

### Common Issues:

1. **Docker not starting**:
   - Ensure Docker Desktop is running
   - Check available disk space and memory

2. **Port 8000 already in use**:
   ```bash
   # Find what's using the port
   lsof -i :8000
   # Or change the port in docker-compose.yml
   ```

3. **Azure connection issues**:
   - Verify your network can reach Azure services
   - Check if any corporate VPN/firewall is blocking connections

4. **Environment variables not loading**:
   - Ensure `.env` file exists and is properly formatted
   - Check for syntax errors in environment variables

### Logs and Debugging:

```bash
# Docker logs
docker-compose logs -f dalpo-webapp

# Python logs (in development mode)
# Logs will appear in the terminal where you ran the script
```

## 🔒 Security Notes

- The `.env` file contains production Azure credentials
- Keep this file secure and never commit it to version control
- All connections to Azure services use HTTPS
- The application uses the same authentication as production

## 🛠️ Development

### Frontend Development:
```bash
cd frontend
npm install
npm run dev    # Development server
npm run build  # Production build
```

### Backend Development:
- Use `./run-python.sh` for hot reloading
- Backend code is in the `backend/` directory
- Main application logic is in `app.py`

## 📚 Additional Resources

- [Azure OpenAI Documentation](https://docs.microsoft.com/en-us/azure/cognitive-services/openai/)
- [Azure Cognitive Search Documentation](https://docs.microsoft.com/en-us/azure/search/)
- [Quart Framework Documentation](https://quart.palletsprojects.com/)
