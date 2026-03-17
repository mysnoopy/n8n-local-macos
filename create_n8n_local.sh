#!/bin/bash

clear
echo "===================================================="
echo "🚀 n8n PRO INSTALLER: DEEP CLEAN & DEPENDENCY CHECK"
echo "===================================================="

# --- 0. DEPENDENCY CHECK (Brew & Docker) ---
echo "🔍 Checking system requirements..."

# Check for Homebrew
if ! command -v brew &> /dev/null; then
    echo "🍺 Homebrew not found. Installing now..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    # Add brew to path for the current session
    eval "$(/opt/homebrew/bin/brew shellenv)" 2>/dev/null || eval "$(/usr/local/bin/brew shellenv)"
else
    echo "✅ Homebrew is installed."
fi

# Check for Docker
if ! command -v docker &> /dev/null; then
    echo "🐳 Docker not found. Installing Docker Desktop via Brew..."
    brew install --cask docker
    echo "⚠️  Please open Docker from your Applications folder, complete the setup, and run this script again."
    exit 1
else
    # Check if Docker Daemon is running
    if ! docker info &> /dev/null; then
        echo "⏳ Docker is installed but not running. Starting Docker..."
        open --background -a Docker
        echo "Waiting for Docker to start..."
        until docker info &> /dev/null; do
            printf "."
            sleep 2
        done
        echo " Docker is ready!"
    fi
    echo "✅ Docker is installed and running."
fi

# --- 1. DESTRUCTION WARNING & CONFIRMATION ---
echo ""
echo "⚠️  WARNING: TARGETED WIPE DETECTED"
echo "This script will force-delete n8n containers and local data."
echo "----------------------------------------------------"

read -p "❓ Wipe n8n environment and start fresh? (y/n): " confirm
if [[ $confirm != [yY] ]]; then
    echo "❌ Setup cancelled."
    exit 1
fi

echo "🧹 Performing Deep Clean..."

# 1. Force stop and remove specific containers by name
docker rm -f n8n_app n8n_db uptime_kuma cloudflared_tunnel >/dev/null 2>&1

# 2. Clean up networks and orphans
docker compose down -v --remove-orphans >/dev/null 2>&1

# 3. Wipe the actual data folders in the current directory
rm -rf ./n8n_data ./postgres_data ./uptime_data ./.env ./docker-compose.yml

echo "✅ Environment cleared."

# --- 2. SYSTEM REPAIRS ---
docker context use default >/dev/null 2>&1
if [ -f ~/.docker/config.json ]; then
    sed -i '' 's/desktop//g' ~/.docker/config.json 2>/dev/null
fi

# --- 3. PRE-PLANNING ---
echo ""
echo "📝 PRE-PLANNING:"
read -p "🌐 What subdomain do you want? (e.g., 'n8n'): " MY_SUBDOMAIN
read -p "🏠 What is your domain? (e.g., 'yourdomain.com'): " MY_DOMAIN
FULL_URL="https://${MY_SUBDOMAIN}.${MY_DOMAIN}"
echo ""

# --- 4. CLOUDFLARE UI STEPS (EXACT VERSION) ---
echo "☁️  STEP 1: CONFIGURE CLOUDFLARE"
open "https://one.dash.cloudflare.com/"
echo "----------------------------------------------------"
echo "I have opened your dashboard. FOLLOW THESE STEPS:"
echo ""
echo "1️⃣  (Connectors): Click 'Networks' -> 'Connectors' -> 'Add a tunnel'."
echo ""
echo "2️⃣  (Select tunnel type): Click 'Cloudflared'."
echo ""
echo "3️⃣  (Name your tunnel): Type '${MY_SUBDOMAIN}-tunnel' -> Click 'Save tunnel'."
echo ""
echo "4️⃣  (Install and run connectors): Click 'Docker' -> 📋 CLICK THE COPY BUTTON next to the big box of code and paste it to Notepad -> Click 'Next'"
echo ""
echo "5️⃣  (Route tunnel): Click 'Next' and fill these boxes:"
echo "   - Subdomain: ${MY_SUBDOMAIN}"
echo "   - Domain:    (Select ${MY_DOMAIN})"
echo "   - Service Type: HTTP"
echo "   - Service URL:  n8n:5678"
echo ""
echo "💡 TIP: For monitoring, add another Public Hostname on the same tunnel:"
echo "   - Subdomain: monitor-${MY_SUBDOMAIN}"
echo "   - Service: HTTP://monitor:61208"
echo ""
echo "🔥 IMPORTANT: You MUST click 'Complete setup' at the bottom of the"
echo "   Cloudflare page before you continue here."
echo "----------------------------------------------------"
echo ""

while true; do
    read -p "❓ Have you clicked 'Complete setup' in your browser? (y/n): " yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) echo "Please finish the Cloudflare setup first!";;
        * ) echo "Please answer y or n.";;
    esac
done

echo ""
read -p "📋 Paste the ENTIRE Docker command from Cloudflare: " FULL_COMMAND
TUNNEL_TOKEN=$(echo "$FULL_COMMAND" | sed -n 's/.*--token \([^ ]*\).*/\1/p')

if [ -z "$TUNNEL_TOKEN" ]; then echo "❌ Token Error."; exit 1; fi

read -p "🐘 Create a Database Password (letters/numbers only): " DB_PASSWORD

# --- 5. DATA DIRECTORY SETUP ---
mkdir -p ./n8n_data ./postgres_data ./uptime_data
GEN_KEY=$(openssl rand -hex 16)

# --- 6. DEPLOYMENT ---
cat <<EOF > .env
DOMAIN_NAME=${MY_SUBDOMAIN}.${MY_DOMAIN}
TUNNEL_TOKEN=${TUNNEL_TOKEN}
POSTGRES_USER=n8n_admin
POSTGRES_PASSWORD=${DB_PASSWORD}
N8N_ENCRYPTION_KEY=${GEN_KEY}
EOF

cat <<EOF > docker-compose.yml
services:
  postgres:
    image: postgres:16-alpine
    container_name: n8n_db
    restart: always
    environment:
      - POSTGRES_USER=\${POSTGRES_USER}
      - POSTGRES_PASSWORD=\${POSTGRES_PASSWORD}
      - POSTGRES_DB=n8n_prod
    volumes:
      - ./postgres_data:/var/lib/postgresql/data
    networks:
      - n8n-network
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U \${POSTGRES_USER} -d n8n_prod"]
      interval: 5s
      timeout: 5s
      retries: 5

  n8n:
    image: n8nio/n8n:latest
    container_name: n8n_app
    restart: always
    environment:
      - DB_TYPE=postgresdb
      - DB_POSTGRESDB_HOST=postgres
      - DB_POSTGRESDB_DATABASE=n8n_prod
      - DB_POSTGRESDB_USER=\${POSTGRES_USER}
      - DB_POSTGRESDB_PASSWORD=\${POSTGRES_PASSWORD}
      - N8N_HOST=\${DOMAIN_NAME}
      - WEBHOOK_URL=https://\${DOMAIN_NAME}
      - N8N_ENCRYPTION_KEY=\${N8N_ENCRYPTION_KEY}
    volumes:
      - ./n8n_data:/home/node/.n8n
    networks:
      - n8n-network
    depends_on:
      postgres:
        condition: service_healthy

  friendly_monitor:
    image: louislam/uptime-kuma:1
    container_name: uptime_kuma
    restart: always
    ports:
      - "127.0.0.1:3001:3001"
    volumes:
      - ./uptime_data:/app/data
    networks:
      - n8n-network

  cloudflared:
    image: cloudflare/cloudflared:latest
    container_name: cloudflared_tunnel
    restart: always
    command: tunnel --no-autoupdate run --token \${TUNNEL_TOKEN}
    networks:
      - n8n-network
    depends_on:
      - n8n

networks:
  n8n-network:
    driver: bridge
EOF

echo "🏗️  Starting containers..."
docker compose up -d --remove-orphans

# --- 7. SMART ENDPOINT CHECK ---
echo ""
echo "⏳ Waiting for n8n to wake up at ${FULL_URL}..."
until $(curl --output /dev/null --silent --head --fail "$FULL_URL"); do
    printf "."
    sleep 2
done

# --- 8. DESKTOP SHORTCUT ---
SHORTCUT_PATH="$HOME/Desktop/n8n-Status.webloc"
{
printf '<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>URL</key>
    <string>http://localhost:3001</string>
</dict>
</plist>' > "$SHORTCUT_PATH"
} &> /dev/null

echo ""
echo "===================================================================================================="
echo "✅ SUCCESS! EVERYTHING IS LIVE."
echo "----------------------------------------------------"
echo "🌐 n8n App:        ${FULL_URL}"
echo "📊 Friendly Status: http://localhost:3001"
echo ""
echo "🛠️  RECOMMENDED MONITORS TO ADD IN UPTIME KUMA:"
echo "1. Create your new account"
echo ""
echo "2. At home screen, click 'Add New Monitor'" 
echo "   Add Monitor Type: 'HTTP' -> Friendly Name: 'n8n App' -> URL: ${FULL_URL} -> Save"
echo ""
echo "3. At home screen, click 'Add New Monitor'"
echo "   Add Monitor Type: 'TCP Port' -> Friendly Name: 'n8n DB' -> Hostname: n8n_db -> Port: 5432 -> Save"
echo ""
echo "4. At home screen, click 'Add New Monitor'"
echo "   Add Monitor Type: 'TCP Port' -> Name: 'Tunnel' -> Host: cloudflared_tunnel -> Port: 20241 -> Save"
echo "===================================================================================================="
