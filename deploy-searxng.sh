#!/bin/bash

# Deploy SearXNG locally for OpenCode MCP
# Usage: ./deploy-searxng.sh [start|stop|restart]

ACTION=${1:-start}
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SEARXNG_DIR="$SCRIPT_DIR/searxng"
PORT=8080

# Check if port is busy (only on start)
if [ "$ACTION" == "start" ]; then
    if lsof -Pi :$PORT -sTCP:LISTEN -t >/dev/null ; then
        echo "⚠️  Port $PORT is already in use."
        read -p "Do you want to stop the existing process on port $PORT? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            # Try to find if it's a docker container
            CONTAINER_ID=$(docker ps -q --filter "publish=$PORT")
            if [ ! -z "$CONTAINER_ID" ]; then
                echo "Stopping container $CONTAINER_ID..."
                docker stop $CONTAINER_ID
            else
                echo "❌ Cannot stop non-docker process automatically. Please free port $PORT manually."
                exit 1
            fi
        else
            echo "❌ Cannot start SearXNG on port $PORT."
            exit 1
        fi
    fi
fi

cd "$SEARXNG_DIR"

case "$ACTION" in
    start)
        echo "🚀 Starting SearXNG on http://localhost:$PORT..."
        # Generate a random secret key if it's the default
        if grep -q "ultrasecretkey" settings.yml; then
            echo "Generating random secret key..."
            sed -i "s/ultrasecretkey/$(openssl rand -hex 16)/g" settings.yml
        fi
        docker compose up -d
        echo "✅ SearXNG is running!"
        echo "   - Web UI: http://localhost:$PORT"
        echo "   - API: http://localhost:$PORT/search?q=test&format=json"
        ;;
    stop)
        echo "🛑 Stopping SearXNG..."
        docker compose down
        ;;
    restart)
        echo "🔄 Restarting SearXNG..."
        docker compose down
        docker compose up -d
        ;;
    *)
        echo "Usage: $0 {start|stop|restart}"
        exit 1
esac
