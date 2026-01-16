#!/bin/bash
# Initialize JumpServer Deployment

# 1. Environment Setup
if [ ! -f .env ]; then
    echo "Creating .env from .env.example..."
    cp .env.example .env
    echo "WARNING: Please edit .env and set your secrets!"
fi

# Load env vars
set -a
source .env
set +a

# 2. Config Generation
if [ ! -f config.yml ]; then
    echo "Generating config.yml..."
    cp config.yml.example config.yml
    # Simple sed replacement
    sed -i "s/{{SECRET_KEY}}/${SECRET_KEY}/g" config.yml
    sed -i "s/{{BOOTSTRAP_TOKEN}}/${BOOTSTRAP_TOKEN}/g" config.yml
    sed -i "s/{{DB_HOST}}/${DB_HOST}/g" config.yml
    sed -i "s/{{DB_PORT}}/${DB_PORT}/g" config.yml
    sed -i "s/{{DB_USER}}/${DB_USER}/g" config.yml
    sed -i "s/{{DB_PASSWORD}}/${DB_PASSWORD}/g" config.yml
    sed -i "s/{{DB_NAME}}/${DB_NAME}/g" config.yml
    sed -i "s/{{REDIS_HOST}}/${REDIS_HOST}/g" config.yml
    sed -i "s/{{REDIS_PORT}}/${REDIS_PORT}/g" config.yml
    sed -i "s/{{HTTP_PORT}}/${HTTP_PORT}/g" config.yml
fi

# 3. Source Code
if [ ! -d "source" ]; then
    echo "Cloning JumpServer source code (${JUMPSERVER_VERSION})..."
    git clone --branch ${JUMPSERVER_VERSION} --depth 1 https://github.com/jumpserver/jumpserver.git source
fi

# 4. Data Directories
echo "Creating data directories..."
mkdir -p data/static/img data/media data/lina data/luna

# 5. UI Components
echo "Downloading UI components..."
cd data
if [ ! -d "lina" ] || [ -z "$(ls -A lina)" ]; then
    curl -L -O https://github.com/jumpserver/lina/releases/download/${JUMPSERVER_VERSION}/lina-${JUMPSERVER_VERSION}.tar.gz
    tar -xf lina-${JUMPSERVER_VERSION}.tar.gz
    mv lina-${JUMPSERVER_VERSION}/* lina/
    rm -rf lina-${JUMPSERVER_VERSION}*
fi

if [ ! -d "luna" ] || [ -z "$(ls -A luna)" ]; then
    curl -L -O https://github.com/jumpserver/luna/releases/download/${JUMPSERVER_VERSION}/luna-${JUMPSERVER_VERSION}.tar.gz
    tar -xf luna-${JUMPSERVER_VERSION}.tar.gz
    mv luna-${JUMPSERVER_VERSION}/* luna/
    rm -rf luna-${JUMPSERVER_VERSION}*
fi
cd ..

# 6. Branding
echo "Applying custom branding..."
./custom_branding/apply_branding.sh

echo "Setup complete!"
echo "1. Edit .env if you haven't already."
echo "2. Run: docker compose up -d --build"
