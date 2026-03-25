# 🚀 n8n Local PRO Stack for macOS

A professional-grade, containerized n8n environment optimized for performance, security, and persistence. This setup is specifically designed to support **Octoix AI** and **Hire Chat** automation workflows on Apple Silicon (M1/M2/M3) or Intel Macs.

---

## 🏗️ Architecture & Services
This stack orchestrates four distinct services to provide a robust, self-hosted automation engine:

* **n8n (App):** The primary automation engine.
* **Postgres (DB):** High-performance storage for workflows and execution history.
* **Cloudflared (Tunnel):** Securely bridges your local n8n instance to the web without opening router ports.
* **Uptime Kuma (Monitor):** A visual, user-friendly dashboard to track system health.

---

## 🛡️ Security Model
This setup employs a **Hybrid Security Architecture**:

1.  **Public Access (n8n):** Exposed to the web via Cloudflare Tunnel to support **Webhooks** (critical for connecting to external APIs). Secured by n8n’s internal authentication.
2.  **Local Isolation (Monitor):** The Uptime Kuma dashboard is restricted to `127.0.0.1:3001`. It is physically inaccessible from the public internet.
3.  **Encrypted Tunnel:** All external traffic is routed through Cloudflare's global network. No ports are opened on your local router.

---

## 📋 Prerequisites & Installation
The included installer script handles most dependencies automatically.

### Requirements:
* **macOS:** Sonoma or Sequoia recommended.
* **Xcode Command Line Tools:** The script will prompt for installation if missing.
* **Homebrew & Docker Desktop:** Automatically installed/verified by the script.

### Installation:
1.  Clone this repository to your Mac.
2.  Make the script executable: `chmod +x create_n8n_local.sh`
3.  Run the installer: `./create_n8n_local.sh`

---

## ☁️ Cloudflare Tunnel Setup Walkthrough
Log in to your Cloudflare account before setting up your new n8n tunnel. The script will open the dashboard for you. Follow these visual steps:

**Switch to Zero Trust Dashboard**   
![Cloudflare Setup](https://github.com/mysnoopy/n8n-local-macos/blob/main/images/image2-1.png)
**Step 0**  
![Cloudflare Setup](https://github.com/mysnoopy/n8n-local-macos/blob/main/images/image2-3.png)

**Step 1** ![Step 1](https://github.com/mysnoopy/n8n-local-macos/blob/main/images/image3.png)

**Step 2** ![Step 2](https://github.com/mysnoopy/n8n-local-macos/blob/main/images/image4.png)

**Step 3** ![Step 3](https://github.com/mysnoopy/n8n-local-macos/blob/main/images/image5.png)

**Step 4** ![Step 4](https://github.com/mysnoopy/n8n-local-macos/blob/main/images/image6.png)

**Step 5** ![Step 5](https://github.com/mysnoopy/n8n-local-macos/blob/main/images/image7.png)

**Cloudflare Tunnel Completed** ![Tunnel Done](https://github.com/mysnoopy/n8n-local-macos/blob/main/images/image8.png)

---

## 🔑 n8n Account & License Activation
Once n8n is live, follow these steps to activate your Community license:

**Step 1:** Enter your email address to receive the activation key.  
![License Step 1](https://github.com/mysnoopy/n8n-local-macos/blob/main/images/image9.png)

**Step 2:** Click "Get started" to skip the onboarding questions.  
![License Step 2](https://github.com/mysnoopy/n8n-local-macos/blob/main/images/image10.png)

**Step 3:** Confirm your admin email address.  
![License Step 3](https://github.com/mysnoopy/n8n-local-macos/blob/main/images/image11.png)

**Step 4:** Check your inbox for the free license key.  
![License Step 4](https://github.com/mysnoopy/n8n-local-macos/blob/main/images/image12.png)

**Step 5:** Continue to the n8n dashboard.  
![License Step 5](https://github.com/mysnoopy/n8n-local-macos/blob/main/images/image13.png)

**Step 6:** Navigate to **Usage and plan** to enter your key.  
![License Step 6](https://github.com/mysnoopy/n8n-local-macos/blob/main/images/image14.png)

**Step 7:** Apply the key.  
![License Step 7](https://github.com/mysnoopy/n8n-local-macos/blob/main/images/image15.png)

**Step 8:** Your version is now activated for unlimited use.  
![License Step 8](https://github.com/mysnoopy/n8n-local-macos/blob/main/images/image16.png)

---

## 📈 Monitoring Setup
After logging into your local monitor at [http://localhost:3001](http://localhost:3001), add these three monitors for total visibility:

1. **n8n App:**
   * **Type:** HTTP
   * **URL:** `https://your-n8n.yourdomain.com`
2. **Database:**
   * **Type:** TCP Port
   * **Host:** `n8n_db`
   * **Port:** `5432`
3. **Tunnel Engine:**
   * **Type:** TCP Port
   * **Host:** `cloudflared_tunnel`
   * **Port:** `20241`

---

## 📊 Maintenance Commands

**Start/Stop:**
```bash
docker compose up -d
docker compose stop
