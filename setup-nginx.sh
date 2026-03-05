#!/bin/bash

# Setup Nginx Reverse Proxy + SSL untuk DexScreener Tracker

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "============================================="
echo "🌐 Nginx + SSL Setup"
echo "============================================="
echo ""

# Check if running as root or with sudo
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}❌ Script ini butuh sudo privileges${NC}"
    echo -e "${YELLOW}Run dengan: sudo bash setup-nginx.sh${NC}"
    exit 1
fi

# Ask for domain or IP
echo -e "${YELLOW}Masukkan domain atau IP VPS Anda:${NC}"
read -p "Domain/IP: " DOMAIN

if [ -z "$DOMAIN" ]; then
    echo -e "${RED}❌ Domain/IP tidak boleh kosong!${NC}"
    exit 1
fi

# Install Nginx
echo -e "${GREEN}📦 Installing Nginx...${NC}"
apt update
apt install -y nginx

# Create Nginx config
NGINX_CONF="/etc/nginx/sites-available/dexscreener-tracker"

echo -e "${GREEN}📝 Creating Nginx configuration...${NC}"
cat > "$NGINX_CONF" << EOF
server {
    listen 80;
    server_name $DOMAIN;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

# Enable site
echo -e "${GREEN}🔗 Enabling site...${NC}"
ln -sf "$NGINX_CONF" /etc/nginx/sites-enabled/

# Test Nginx config
echo -e "${GREEN}🧪 Testing Nginx configuration...${NC}"
nginx -t

# Restart Nginx
echo -e "${GREEN}🔄 Restarting Nginx...${NC}"
systemctl restart nginx
systemctl enable nginx

# Setup firewall
echo -e "${GREEN}🛡️ Configuring firewall...${NC}"
ufw allow 'Nginx Full'
ufw --force enable

echo ""
echo -e "${GREEN}✅ Nginx setup complete!${NC}"
echo ""
echo -e "${YELLOW}📋 Access your app at:${NC}"
echo "   http://$DOMAIN"
echo ""

# Ask about SSL
if [[ $DOMAIN =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo -e "${YELLOW}⚠️  Anda menggunakan IP address${NC}"
    echo -e "${YELLOW}⚠️  SSL hanya bisa di-setup dengan domain name${NC}"
    exit 0
fi

read -p "🔒 Setup SSL dengan Let's Encrypt? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${GREEN}📦 Installing Certbot...${NC}"
    apt install -y certbot python3-certbot-nginx
    
    echo ""
    echo -e "${YELLOW}📧 Masukkan email untuk SSL certificate:${NC}"
    read -p "Email: " EMAIL
    
    if [ -z "$EMAIL" ]; then
        echo -e "${RED}❌ Email tidak boleh kosong!${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}🔒 Getting SSL certificate...${NC}"
    certbot --nginx -d "$DOMAIN" --non-interactive --agree-tos -m "$EMAIL"
    
    echo ""
    echo -e "${GREEN}✅ SSL setup complete!${NC}"
    echo -e "${GREEN}📋 Your app is now available at:${NC}"
    echo "   https://$DOMAIN"
    echo ""
    echo -e "${YELLOW}🔄 Auto-renewal is enabled${NC}"
    echo -e "${YELLOW}📅 Test renewal: sudo certbot renew --dry-run${NC}"
fi

echo ""
echo -e "${GREEN}🎉 All done!${NC}"
