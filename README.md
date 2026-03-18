# 🚀 n8n Local PRO Stack for macOS

A professional-grade, containerized n8n environment optimized for performance, security, and persistence. This setup is specifically designed to support **Octoix AI** and **Hire Chat** automation workflows on Apple Silicon (M1/M2/M3) or Intel Macs.

---

## 🏗️ Architecture & Services
This stack orchestrates four distinct services to provide a robust, self-hosted automation engine:

* **n8n (App):** The primary automation engine.
* **Postgres (DB):** High-performance storage for workflows and execution history.
* **Cloudflared (Tunnel):** Securely bridges your local n8n instance to the web without opening router ports.
* **Uptime Kuma (Monitor):** A visual, user-friendly dashboard to track system health and container status.

---

## 🛡️ Security Model
This setup employs a **Hybrid Security Architecture**:

1.  **Public Access (n8n):** Exposed to the web via Cloudflare Tunnel to support **Webhooks** (critical for connecting to external APIs like Stripe, WhatsApp, or Typeform). Secured by n8n’s internal authentication.
2.  **Local Isolation (Monitor):** The Uptime Kuma dashboard is restricted to `127.0.0.1:3001`. It is physically inaccessible from the public internet, ensuring your system stats remain private.
3.  **Encrypted Tunnel:** All external traffic is routed through Cloudflare's global network via an encrypted tunnel. No ports are opened on your local router (No Port Forwarding required).

---

## 📋 Prerequisites & Installation
The included installer script handles most dependencies automatically.

### Requirements:
* **macOS:** Sonoma or Sequoia recommended.
* **Xcode Command Line Tools:** Required for Homebrew (The script will prompt for installation if missing).
* **Homebrew & Docker Desktop:** Automatically installed/verified by the script.

### Installation:
1.  Clone this repository to your Mac.
2.  Make the script executable:
    ```bash
    chmod +x create_n8n_local.sh
    ```
3.  Run the installer:
    ```bash
    ./create_n8n_local.sh
    ```

---

## 📁 Folder Structure
All data is stored in your local project directory to ensure persistence:

* `./n8n_data`: All workflows, credentials, and binary files.
* `./postgres_data`: Database files (PostgreSQL 16).
* `./uptime_data`: Monitoring history and dashboard settings.
* `.env`: **(SECRET)** Variables containing your Passwords and Tunnel Tokens. **Do not commit this file.**
* `docker-compose.yml`: The blueprint for your containers.

---

## 📊 Maintenance & Management

### 🛠️ Basic Commands
Run these from within your project directory:

**Start the System:**
```bash
docker compose up -d
