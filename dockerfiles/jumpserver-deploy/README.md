# JumpServer Deployment (Custom Build)

This repository contains a clean, containerized deployment of JumpServer, built from source with custom branding and Nginx proxying.

## Prerequisites

- Docker & Docker Compose
- Git

## Setup

1.  **Initialize the environment:**
    ```bash
    ./init.sh
    ```
    This will:
    - Create `.env` from `.env.example`.
    - Clone the JumpServer source code.
    - Download UI components (Lina/Luna).
    - Apply custom branding.

2.  **Configure Secrets:**
    Edit `.env` and set your own secrets (keys, passwords).
    ```bash
    nano .env
    ```

3.  **Start the Stack:**
    ```bash
    docker compose up -d --build
    ```

## Usage

- **URL:** http://localhost:8989 (or port defined in .env)
- **Default Admin:** `admin` / `admin` (Change immediately!)

## Scripts

Located in `scripts/`. Run them inside the `core` container:

- **Add Host:**
  ```bash
  docker compose exec core python3 /opt/jumpserver/add_host.py <IP> <HOSTNAME> --user <USER> --password <PASS>
  ```

- **Grant Admin Access:** (If admin loses access to assets)
  ```bash
  docker compose exec core python3 /opt/jumpserver/grant_admin.py
  ```

## Customization

- **Branding:** Place new images in `custom_branding/` and run `./init.sh` again.
- **Nginx:** Edit `nginx/default.conf` and restart the `web` container.
