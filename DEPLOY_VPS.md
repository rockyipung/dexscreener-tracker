# 🚀 Cara Deploy DexScreener Tracker di VPS Linux

Panduan lengkap untuk menjalankan DexScreener Tracker di VPS Linux (Ubuntu/Debian)

## 📋 Prerequisites

- VPS Linux (Ubuntu 20.04/22.04 atau Debian 11/12)
- Akses SSH ke VPS
- Domain (opsional, untuk HTTPS)

## 🔧 Step 1: Persiapan VPS

### 1.1 Login ke VPS via SSH
```bash
ssh root@IP_VPS_ANDA
# atau
ssh username@IP_VPS_ANDA
```

### 1.2 Update System
```bash
sudo apt update && sudo apt upgrade -y
```

### 1.3 Install Node.js & NPM
```bash
# Install Node.js 18.x (LTS)
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs

# Verifikasi instalasi
node --version
npm --version
```

### 1.4 Install PM2 (Process Manager)
```bash
sudo npm install -g pm2
```

### 1.5 Install Git (jika belum ada)
```bash
sudo apt install -y git
```

## 📦 Step 2: Upload & Setup Aplikasi

### Opsi A: Upload Manual via SCP

**Dari komputer lokal:**
```bash
# Compress files
tar -czf dexscreener-tracker.tar.gz index.html server.js package.json

# Upload ke VPS
scp dexscreener-tracker.tar.gz username@IP_VPS:/home/username/

# SSH ke VPS dan extract
ssh username@IP_VPS
cd /home/username
tar -xzf dexscreener-tracker.tar.gz
mkdir dexscreener-tracker
mv index.html server.js package.json dexscreener-tracker/
cd dexscreener-tracker
```

### Opsi B: Clone dari Git Repository (jika sudah upload ke GitHub)

```bash
cd /home/username
git clone https://github.com/YOUR_USERNAME/dexscreener-tracker.git
cd dexscreener-tracker
```

### Opsi C: Buat File Langsung di VPS

```bash
# Buat folder
mkdir -p /home/username/dexscreener-tracker
cd /home/username/dexscreener-tracker

# Buat package.json
nano package.json
# Copy paste isi package.json, lalu Ctrl+X, Y, Enter

# Buat server.js
nano server.js
# Copy paste isi server.js, lalu Ctrl+X, Y, Enter

# Buat index.html
nano index.html
# Copy paste isi index.html, lalu Ctrl+X, Y, Enter
```

## 🔨 Step 3: Install Dependencies

```bash
cd /home/username/dexscreener-tracker
npm install
```

## 🚀 Step 4: Jalankan Aplikasi dengan PM2

### 4.1 Start dengan PM2
```bash
pm2 start server.js --name dexscreener-tracker
```

### 4.2 Setup Auto-Start saat VPS Restart
```bash
pm2 startup
# Jalankan command yang muncul (biasanya dimulai dengan sudo)

pm2 save
```

### 4.3 Useful PM2 Commands
```bash
# Lihat status
pm2 status

# Lihat logs
pm2 logs dexscreener-tracker

# Restart aplikasi
pm2 restart dexscreener-tracker

# Stop aplikasi
pm2 stop dexscreener-tracker

# Delete dari PM2
pm2 delete dexscreener-tracker

# Monitor real-time
pm2 monit
```

## 🌐 Step 5: Setup Firewall

```bash
# Allow port 3000
sudo ufw allow 3000

# Allow SSH (PENTING!)
sudo ufw allow 22

# Enable firewall
sudo ufw enable

# Check status
sudo ufw status
```

## 🔒 Step 6: Setup Nginx Reverse Proxy (Opsional tapi Recommended)

### 6.1 Install Nginx
```bash
sudo apt install -y nginx
```

### 6.2 Konfigurasi Nginx
```bash
sudo nano /etc/nginx/sites-available/dexscreener-tracker
```

**Paste konfigurasi ini:**
```nginx
server {
    listen 80;
    server_name IP_VPS_ANDA atau domain.com;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### 6.3 Enable Site & Restart Nginx
```bash
sudo ln -s /etc/nginx/sites-available/dexscreener-tracker /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

### 6.4 Allow HTTP/HTTPS di Firewall
```bash
sudo ufw allow 'Nginx Full'
```

## 🔐 Step 7: Setup SSL dengan Let's Encrypt (jika pakai domain)

```bash
# Install Certbot
sudo apt install -y certbot python3-certbot-nginx

# Dapatkan SSL Certificate
sudo certbot --nginx -d domain.com -d www.domain.com

# Auto-renewal sudah aktif secara default
# Test renewal:
sudo certbot renew --dry-run
```

## 📱 Step 8: Akses Aplikasi

### Tanpa Nginx (langsung):
```
http://IP_VPS_ANDA:3000
```

### Dengan Nginx:
```
http://IP_VPS_ANDA
```

### Dengan Domain & SSL:
```
https://domain.com
```

## 🎯 Step 9: Setup Telegram Bot

1. Buka aplikasi di browser (sesuai URL di atas)
2. Isi Bot Token dari @BotFather
3. Isi Chat ID dari @userinfobot
4. Pilih blockchain
5. Klik "Mulai Tracking"

## 🔍 Monitoring & Troubleshooting

### Check jika aplikasi running:
```bash
pm2 status
pm2 logs dexscreener-tracker
```

### Check port 3000 terbuka:
```bash
sudo netstat -tlnp | grep 3000
# atau
sudo ss -tlnp | grep 3000
```

### Check Nginx status:
```bash
sudo systemctl status nginx
```

### Restart semua services:
```bash
pm2 restart dexscreener-tracker
sudo systemctl restart nginx
```

### Lihat error logs:
```bash
# PM2 logs
pm2 logs dexscreener-tracker --err

# Nginx logs
sudo tail -f /var/log/nginx/error.log
sudo tail -f /var/log/nginx/access.log
```

## 🛡️ Security Best Practices

### 1. Ubah SSH Port (opsional)
```bash
sudo nano /etc/ssh/sshd_config
# Ubah Port 22 ke port lain, misal 2222
sudo systemctl restart sshd

# Jangan lupa allow port baru di firewall:
sudo ufw allow 2222
```

### 2. Disable Root Login
```bash
sudo nano /etc/ssh/sshd_config
# Set: PermitRootLogin no
sudo systemctl restart sshd
```

### 3. Install Fail2Ban
```bash
sudo apt install -y fail2ban
sudo systemctl enable fail2ban
sudo systemctl start fail2ban
```

### 4. Keep System Updated
```bash
# Setup auto-updates
sudo apt install -y unattended-upgrades
sudo dpkg-reconfigure -plow unattended-upgrades
```

## 🔄 Update Aplikasi

```bash
cd /home/username/dexscreener-tracker

# Backup dulu (opsional)
cp server.js server.js.backup

# Update file (edit manual atau git pull)
nano server.js

# Restart
pm2 restart dexscreener-tracker
```

## 📊 Monitor Resource Usage

```bash
# CPU & Memory usage
htop
# atau
top

# Disk usage
df -h

# PM2 monitoring
pm2 monit
```

## 🗑️ Uninstall/Remove

```bash
# Stop & delete dari PM2
pm2 stop dexscreener-tracker
pm2 delete dexscreener-tracker
pm2 save

# Remove files
rm -rf /home/username/dexscreener-tracker

# Remove Nginx config (jika ada)
sudo rm /etc/nginx/sites-enabled/dexscreener-tracker
sudo rm /etc/nginx/sites-available/dexscreener-tracker
sudo systemctl restart nginx
```

## 💡 Tips & Tricks

1. **Multiple Chains**: Jalankan multiple instances dengan port berbeda
   ```bash
   # Edit server.js, ubah PORT jadi 3001, 3002, dst
   pm2 start server.js --name tracker-ethereum -- --port 3001
   pm2 start server.js --name tracker-bsc -- --port 3002
   ```

2. **Log Rotation**: PM2 otomatis handle log rotation
   ```bash
   pm2 install pm2-logrotate
   ```

3. **Environment Variables**:
   ```bash
   # Buat file .env
   nano .env
   
   # Isi:
   PORT=3000
   NODE_ENV=production
   
   # Start dengan env vars
   pm2 start server.js --name dexscreener-tracker --env production
   ```

4. **Backup Config**:
   ```bash
   # Save PM2 config
   pm2 save
   
   # Export ke file
   pm2 save --force
   ```

## ❓ FAQ

**Q: Aplikasi berhenti sendiri?**
A: Check logs dengan `pm2 logs`, biasanya karena error atau memory habis

**Q: Tidak bisa akses dari luar?**
A: Check firewall (`sudo ufw status`) dan security group VPS provider

**Q: RAM penuh?**
A: Restart PM2 secara periodik atau upgrade VPS specs

**Q: Ingin running di background tanpa SSH?**
A: PM2 sudah handle ini, aman untuk logout SSH

---

**Selamat! Tracker Anda sudah running 24/7 di VPS! 🎉**

Untuk pertanyaan atau issue, check logs dengan `pm2 logs dexscreener-tracker`
