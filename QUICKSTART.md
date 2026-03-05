# 🚀 Quick Start - Deploy ke VPS Linux

Cara tercepat deploy DexScreener Tracker ke VPS Linux!

## ⚡ Method 1: Auto Install Script (RECOMMENDED)

### 1. Login ke VPS
```bash
ssh username@IP_VPS_ANDA
```

### 2. Download & Run Install Script
```bash
wget https://raw.githubusercontent.com/YOUR_REPO/install.sh
# atau jika belum upload ke GitHub, copy manual install.sh ke VPS

chmod +x install.sh
bash install.sh
```

### 3. Upload index.html
```bash
# Dari komputer lokal:
scp index.html username@IP_VPS:~/dexscreener-tracker/

# Atau download langsung di VPS:
cd ~/dexscreener-tracker
wget https://raw.githubusercontent.com/YOUR_REPO/index.html
```

### 4. Start App
```bash
cd ~/dexscreener-tracker
pm2 start server.js --name dexscreener-tracker
pm2 startup
pm2 save
```

### 5. Setup Firewall
```bash
sudo ufw allow 3000
sudo ufw enable
```

### 6. Akses App
```
http://IP_VPS_ANDA:3000
```

**DONE! 🎉**

---

## ⚡ Method 2: Manual Install (Step by Step)

### 1. Install Node.js
```bash
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs
```

### 2. Install PM2
```bash
sudo npm install -g pm2
```

### 3. Create App Directory
```bash
mkdir ~/dexscreener-tracker
cd ~/dexscreener-tracker
```

### 4. Upload Files
**Option A - SCP dari komputer lokal:**
```bash
scp server.js index.html package.json username@IP_VPS:~/dexscreener-tracker/
```

**Option B - Create manual di VPS:**
```bash
nano package.json
# Paste content, Ctrl+X, Y, Enter

nano server.js
# Paste content, Ctrl+X, Y, Enter

nano index.html
# Paste content, Ctrl+X, Y, Enter
```

### 5. Install Dependencies
```bash
npm install
```

### 6. Start dengan PM2
```bash
pm2 start server.js --name dexscreener-tracker
pm2 startup
pm2 save
```

### 7. Open Port
```bash
sudo ufw allow 3000
sudo ufw enable
```

### 8. Access
```
http://IP_VPS_ANDA:3000
```

---

## 🌐 Setup Nginx + SSL (Optional)

### Auto Script:
```bash
sudo bash setup-nginx.sh
# Follow prompts
```

### Manual:
```bash
# Install Nginx
sudo apt install -y nginx

# Create config
sudo nano /etc/nginx/sites-available/dexscreener-tracker
```

Paste:
```nginx
server {
    listen 80;
    server_name YOUR_DOMAIN_OR_IP;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```

Enable & restart:
```bash
sudo ln -s /etc/nginx/sites-available/dexscreener-tracker /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
sudo ufw allow 'Nginx Full'
```

**SSL (jika pakai domain):**
```bash
sudo apt install -y certbot python3-certbot-nginx
sudo certbot --nginx -d YOUR_DOMAIN.com
```

---

## 📱 Konfigurasi Telegram

1. Buka browser, akses: `http://IP_VPS_ANDA:3000`
2. Buat bot di Telegram (@BotFather):
   - `/newbot`
   - Ikuti instruksi
   - Copy Bot Token
3. Dapatkan Chat ID (@userinfobot):
   - `/start`
   - Copy Chat ID
4. Di web app:
   - Paste Bot Token
   - Paste Chat ID
   - Pilih blockchain
   - Klik "Mulai Tracking"

---

## 🔧 Useful Commands

```bash
# Check status
pm2 status

# View logs
pm2 logs dexscreener-tracker

# Restart
pm2 restart dexscreener-tracker

# Stop
pm2 stop dexscreener-tracker

# Monitor
pm2 monit

# Check if app running
curl http://localhost:3000/api/latest-pairs/ethereum?limit=1
```

---

## 🐛 Troubleshooting

**App tidak jalan?**
```bash
pm2 logs dexscreener-tracker
```

**Port 3000 sudah dipakai?**
```bash
# Edit server.js, ubah PORT jadi 3001
nano ~/dexscreener-tracker/server.js
# Restart
pm2 restart dexscreener-tracker
```

**Tidak bisa akses dari luar?**
```bash
# Check firewall
sudo ufw status

# Allow port
sudo ufw allow 3000
```

**Check if API working:**
```bash
curl http://localhost:3000/api/latest-pairs/bsc?limit=1
```

---

## 📦 Update Aplikasi

```bash
cd ~/dexscreener-tracker
# Upload file baru atau edit
nano server.js
# Restart
pm2 restart dexscreener-tracker
```

---

## 🎯 Production Checklist

- [ ] Node.js installed
- [ ] PM2 installed & configured
- [ ] App started with PM2
- [ ] PM2 startup enabled
- [ ] Firewall configured
- [ ] Nginx installed (optional)
- [ ] SSL certificate (optional)
- [ ] Telegram bot configured
- [ ] App accessible from browser
- [ ] Logs checked for errors

---

**Need help? Check DEPLOY_VPS.md for detailed guide!**
