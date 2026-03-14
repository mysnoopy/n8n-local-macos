# **![](https://github.com/mysnoopy/n8n-local-macos/blob/main/images/image1.png)**

# **🚀 n8n Local PRO Stack**

**A professional-grade, containerized n8n environment running on macOS. This setup is optimized for performance, security, and persistence, specifically tailored for automation workflows.**

---

## **🏗️ Architecture & Services**

**This stack orchestrates four distinct services to provide a robust automation engine:**

* **n8n (App): The primary automation engine.**  
* **Postgres (DB): High-performance storage for workflows and execution history.**  
* **Cloudflared (Tunnel): Securely bridges your local n8n to the web without opening router ports.**  
* **Uptime Kuma (Monitor): A visual, user-friendly dashboard to track system health.**

---

## **🛡️ Security Model**

**This setup employs a Hybrid Security Architecture:**

1. **Public Access (n8n): Exposed to the web via Cloudflare Tunnel to support Webhooks (critical for connecting to external APIs). Secured by n8n’s internal authentication.**  
2. **Local Isolation (Monitor): The Uptime Kuma dashboard is restricted to access only on `127.0.0.1:3001`. It is physically inaccessible from the public internet.**  
3. **Encrypted Tunnel: All external traffic is routed through Cloudflare's global network via an encrypted tunnel. No ports are opened on your local router.**

---

## **📁 Folder Structure**

**All data is stored in your local project directory to ensure persistence:**

* **`./n8n_data`: All workflows, credentials, and binary files.**  
* **`./postgres_data`: Database files (PostgreSQL 16).**  
* **`./uptime_data`: Monitoring history and dashboard settings.**  
* **`.env`: Secret variables (Passwords, Tunnel Tokens).**  
* **`docker-compose.yml`: The blueprint for the containers.**

---

## **📊 Maintenance & Management**

### **🛠️ Basic Commands**

**Run these from within your project directory:**

**Start the System:**

**docker compose up \-d**

**Stop the System:**

**docker compose stop**

**View Real-time Logs:**

**\# To check if n8n is running properly:**  
**docker logs \-f n8n\_app**

**\# To check the tunnel status:**  
**docker logs \-f cloudflared\_tunnel**

---

### **🔄 Safe Update Procedure**

**To update your stack to the latest versions of n8n and Postgres without losing data, you can run the following commands or save them as `update_n8n.sh`:**

**\#\!/bin/bash**  
**echo "🔄 Pulling latest images..."**  
**docker compose pull**

**echo "🏗️  Restarting containers..."**  
**docker compose up \-d \--remove-orphans**

**echo "🧹 Cleaning up old image layers..."**  
**docker image prune \-f**

**echo "✅ Update complete\! Workflows are safe."**

---

### **📈 Monitoring Setup**

**After logging into your local monitor at http://localhost:3001, add these three monitors for total visibility:**

1. **n8n App:**  
   * **Type: HTTP**  
   * **URL: [https://your-n8n.yourdomain.com](https://www.google.com/search?q=https://your-n8n.yourdomain.com)**  
2. **Database:**  
   * **Type: TCP Port**  
   * **Host: n8n\_db**  
   * **Port: 5432**  
3. **Tunnel Engine:**  
   * **Type: TCP Port**  
   * **Host: cloudflared\_tunnel**  
   * **Port: 20241**

**Cloudflare Tunnel setup**  
Log in to your Cloudflare account before setting up your new n8n tunnel. The script will pop up the following screen for Cloudflare tunnel setup.  
![](https://github.com/mysnoopy/n8n-local-macos/blob/main/images/image2.png)  
**Step 1**  
![](https://github.com/mysnoopy/n8n-local-macos/blob/main/images/image3.png)

**Step 2**  
![](https://github.com/mysnoopy/n8n-local-macos/blob/main/images/image4.png)

**Step 3**  
![](https://github.com/mysnoopy/n8n-local-macos/blob/main/images/image5.png)

**Step 4**  
![](https://github.com/mysnoopy/n8n-local-macos/blob/main/images/image6.png)

**Step 5**  
![](https://github.com/mysnoopy/n8n-local-macos/blob/main/images/image7.png)

**Cloudflare tunnel setup completed.**  
![](https://github.com/mysnoopy/n8n-local-macos/blob/main/images/image8.png)

**n8n account setup and license installation**  
**Step 1: A free license and activation key will be sent to the email address you entered.**  
![](https://github.com/mysnoopy/n8n-local-macos/blob/main/images/image9.png)

**Step 2: You can skip the question by clicking “Get started”.**  
![](https://github.com/mysnoopy/n8n-local-macos/blob/main/images/image10.png)

**Step 3: Ensure your email address is correct.**  
![](https://github.com/mysnoopy/n8n-local-macos/blob/main/images/image11.png)

**Step 4: The free license and activation key will be delivered to your email inbox.**  
![](https://github.com/mysnoopy/n8n-local-macos/blob/main/images/image12.png)

**Step 5**  
![](https://github.com/mysnoopy/n8n-local-macos/blob/main/images/image13.png)

**Step 6: Navigate to “Usage and plan” to enter your license key.**  
![](https://github.com/mysnoopy/n8n-local-macos/blob/main/images/image14.png)

**Step 7**  
![](https://github.com/mysnoopy/n8n-local-macos/blob/main/images/image15.png)

**Step 8: As soon as you enter the license key, your n8n will be activated as a community version with unlimited use.**  
![](https://github.com/mysnoopy/n8n-local-macos/blob/main/images/image16.png)

**n8n community version activated.**  


