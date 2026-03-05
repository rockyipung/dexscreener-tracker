#!/bin/bash

# DexScreener Tracker - Auto Install Script untuk VPS Linux
# Tested on Ubuntu 20.04/22.04 dan Debian 11/12

set -e

echo "============================================="
echo "🚀 DexScreener Tracker - Auto Installer"
echo "============================================="
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if running as root
if [ "$EUID" -eq 0 ]; then 
    echo -e "${YELLOW}⚠️  Sebaiknya jangan run sebagai root${NC}"
    echo -e "${YELLOW}⚠️  Tekan Ctrl+C untuk cancel, atau Enter untuk lanjut${NC}"
    read
fi

# Update system
echo -e "${GREEN}📦 Updating system...${NC}"
sudo apt update && sudo apt upgrade -y

# Install Node.js
echo -e "${GREEN}📦 Installing Node.js...${NC}"
if ! command -v node &> /dev/null; then
    curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
    sudo apt install -y nodejs
    echo -e "${GREEN}✅ Node.js installed: $(node --version)${NC}"
else
    echo -e "${YELLOW}⚠️  Node.js already installed: $(node --version)${NC}"
fi

# Install PM2
echo -e "${GREEN}📦 Installing PM2...${NC}"
if ! command -v pm2 &> /dev/null; then
    sudo npm install -g pm2
    echo -e "${GREEN}✅ PM2 installed${NC}"
else
    echo -e "${YELLOW}⚠️  PM2 already installed${NC}"
fi

# Install Git
echo -e "${GREEN}📦 Installing Git...${NC}"
if ! command -v git &> /dev/null; then
    sudo apt install -y git
    echo -e "${GREEN}✅ Git installed${NC}"
else
    echo -e "${YELLOW}⚠️  Git already installed${NC}"
fi

# Create app directory
APP_DIR="$HOME/dexscreener-tracker"
echo -e "${GREEN}📁 Creating app directory: $APP_DIR${NC}"
mkdir -p "$APP_DIR"
cd "$APP_DIR"

# Create package.json
echo -e "${GREEN}📝 Creating package.json...${NC}"
cat > package.json << 'EOF'
{
  "name": "dexscreener-tracker",
  "version": "1.0.0",
  "description": "DexScreener Coin Tracker with Telegram Notifications",
  "main": "server.js",
  "scripts": {
    "start": "node server.js",
    "dev": "nodemon server.js"
  },
  "dependencies": {
    "express": "^4.18.2",
    "cors": "^2.8.5",
    "axios": "^1.6.0"
  },
  "devDependencies": {
    "nodemon": "^3.0.1"
  }
}
EOF

# Create server.js
echo -e "${GREEN}📝 Creating server.js...${NC}"
cat > server.js << 'EOF'
const express = require('express');
const cors = require('cors');
const axios = require('axios');
const app = express();

app.use(cors());
app.use(express.json());
app.use(express.static('.'));

// Endpoint untuk mendapatkan koin terbaru dari DexScreener
app.get('/api/latest-pairs/:chain', async (req, res) => {
    try {
        const { chain } = req.params;
        const limit = req.query.limit || 20;
        
        const response = await axios.get(`https://api.dexscreener.com/latest/dex/pairs/${chain}`, {
            headers: {
                'Accept': 'application/json'
            }
        });

        if (response.data && response.data.pairs) {
            const pairs = response.data.pairs.slice(0, limit);
            res.json({ success: true, pairs });
        } else {
            res.json({ success: false, pairs: [] });
        }
    } catch (error) {
        console.error('Error fetching pairs:', error.message);
        res.status(500).json({ 
            success: false, 
            error: error.message,
            pairs: [] 
        });
    }
});

// Endpoint untuk search tokens
app.get('/api/search/:query', async (req, res) => {
    try {
        const { query } = req.params;
        
        const response = await axios.get(`https://api.dexscreener.com/latest/dex/search/?q=${query}`, {
            headers: {
                'Accept': 'application/json'
            }
        });

        res.json(response.data);
    } catch (error) {
        console.error('Error searching:', error.message);
        res.status(500).json({ 
            success: false, 
            error: error.message 
        });
    }
});

// Endpoint untuk kirim notifikasi Telegram
app.post('/api/telegram/send', async (req, res) => {
    try {
        const { botToken, chatId, message } = req.body;

        const response = await axios.post(
            `https://api.telegram.org/bot${botToken}/sendMessage`,
            {
                chat_id: chatId,
                text: message,
                parse_mode: 'HTML',
                disable_web_page_preview: false
            }
        );

        res.json(response.data);
    } catch (error) {
        console.error('Error sending telegram:', error.message);
        res.status(500).json({ 
            success: false, 
            error: error.response?.data || error.message 
        });
    }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`🚀 Server running on http://localhost:${PORT}`);
    console.log(`📡 DexScreener Tracker API ready`);
});
EOF

# Install dependencies
echo -e "${GREEN}📦 Installing npm dependencies...${NC}"
npm install

echo ""
echo -e "${GREEN}=============================================${NC}"
echo -e "${GREEN}✅ Installation Complete!${NC}"
echo -e "${GREEN}=============================================${NC}"
echo ""
echo -e "${YELLOW}📋 Next Steps:${NC}"
echo ""
echo "1. Upload index.html ke folder: $APP_DIR"
echo "   Atau download dengan:"
echo "   wget https://raw.githubusercontent.com/YOUR_REPO/index.html"
echo ""
echo "2. Start aplikasi dengan PM2:"
echo "   cd $APP_DIR"
echo "   pm2 start server.js --name dexscreener-tracker"
echo ""
echo "3. Setup auto-start:"
echo "   pm2 startup"
echo "   pm2 save"
echo ""
echo "4. Setup firewall:"
echo "   sudo ufw allow 3000"
echo "   sudo ufw enable"
echo ""
echo "5. Akses aplikasi di:"
echo "   http://$(hostname -I | awk '{print $1}'):3000"
echo ""
echo -e "${YELLOW}📖 Lihat DEPLOY_VPS.md untuk panduan lengkap${NC}"
echo ""

# Ask if user wants to start app now
read -p "🚀 Start aplikasi sekarang dengan PM2? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${GREEN}🚀 Starting application...${NC}"
    pm2 start server.js --name dexscreener-tracker
    pm2 save
    
    echo ""
    echo -e "${GREEN}✅ Application started!${NC}"
    echo -e "${GREEN}📊 Check status: pm2 status${NC}"
    echo -e "${GREEN}📋 View logs: pm2 logs dexscreener-tracker${NC}"
    echo ""
    echo -e "${YELLOW}⚠️  Jangan lupa upload index.html!${NC}"
fi

echo ""
echo -e "${GREEN}Happy Tracking! 🎉${NC}"
