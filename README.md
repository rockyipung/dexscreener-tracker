# DexScreener Coin Tracker

Monitor koin baru dari DexScreener dan dapatkan notifikasi langsung ke Telegram!

## 🚀 Fitur

- ✅ **Real-time tracking** dari DexScreener API
- 📱 **Notifikasi Telegram** otomatis untuk setiap koin baru
- ⛓️ **Multi-chain support**: Ethereum, BSC, Polygon, Solana, Base, Arbitrum, dll
- 📊 **Detail lengkap**: Price, Liquidity, Volume, Price Change
- 🎨 **UI Modern** dengan animasi smooth
- 📋 **Activity log** untuk monitoring

## 📋 Prerequisites

- Node.js (v14 atau lebih baru)
- NPM atau Yarn
- Bot Telegram (buat di @BotFather)

## 🔧 Instalasi

1. **Install dependencies:**
   ```bash
   npm install
   ```

2. **Setup Telegram Bot:**
   - Buka Telegram, cari `@BotFather`
   - Ketik `/newbot` dan ikuti instruksi
   - Simpan **Bot Token** yang diberikan
   
3. **Dapatkan Chat ID:**
   - Cari `@userinfobot` di Telegram
   - Ketik `/start` untuk mendapatkan **Chat ID** Anda
   - Atau gunakan Chat ID grup (dimulai dengan `-100`)

## ▶️ Cara Menjalankan

1. **Start backend server:**
   ```bash
   npm start
   ```
   
   Server akan berjalan di `http://localhost:3000`

2. **Buka aplikasi:**
   - Buka `index.html` di browser
   - Atau kunjungi `http://localhost:3000`

3. **Konfigurasi:**
   - Masukkan Bot Token Telegram
   - Masukkan Chat ID
   - Pilih blockchain yang ingin dimonitor
   - Atur interval pemeriksaan (minimum 30 detik)

4. **Mulai tracking:**
   - Klik tombol "Mulai Tracking"
   - Aplikasi akan mulai memonitor koin baru
   - Notifikasi akan dikirim otomatis ke Telegram

## 🔔 Format Notifikasi Telegram

Setiap koin baru akan dikirimkan dengan format:
```
🆕 KOIN BARU TERDETEKSI!

💰 Token Name (SYMBOL)
🔗 Chain: ETHEREUM
🏪 DEX: Uniswap V2

💵 Price: $0.00000123
📊 Liquidity: $50,234.56
📈 Volume 24h: $12,345.67
📉 Change 24h: +123.45%

⏰ [Timestamp]

🔍 [Link ke DexScreener]
```

## 📁 Struktur File

```
dexscreener-tracker/
├── server.js          # Backend server (Express)
├── index.html         # Frontend aplikasi
├── package.json       # Dependencies
└── README.md         # Dokumentasi ini
```

## 🛠️ API Endpoints

Backend menyediakan beberapa endpoint:

- `GET /api/latest-pairs/:chain` - Ambil pairs terbaru dari chain
- `GET /api/search/:query` - Search token
- `GET /api/tokens/:address` - Info token by address
- `POST /api/telegram/send` - Kirim notifikasi ke Telegram

## ⚙️ Konfigurasi Lanjutan

### Mengubah Port
Edit `server.js`:
```javascript
const PORT = process.env.PORT || 3000;
```

### Interval Tracking
Minimum: 30 detik (untuk menghindari rate limit)
Maximum: 600 detik (10 menit)

### Multi-Chain Monitoring
Saat ini hanya bisa monitor 1 chain per instance. Untuk monitor multiple chains:
- Jalankan beberapa instance dengan port berbeda
- Atau modifikasi kode untuk loop multiple chains

## 🐛 Troubleshooting

**"API Offline" / Cannot connect:**
- Pastikan backend server (`npm start`) sudah berjalan
- Check console untuk error messages
- Pastikan port 3000 tidak digunakan aplikasi lain

**"Gagal kirim notifikasi":**
- Verifikasi Bot Token benar
- Verifikasi Chat ID benar
- Pastikan bot sudah di-add ke grup (jika menggunakan grup chat)

**Tidak ada koin baru terdeteksi:**
- DexScreener API mengembalikan pairs yang sudah ada
- Coba chain lain yang lebih aktif (misal: BSC, Base)
- Tunggu beberapa menit, koin baru muncul secara periodik

## 📝 Notes

- Rate limit: DexScreener API memiliki rate limit, gunakan interval >= 30 detik
- CORS: Backend server diperlukan untuk bypass CORS restrictions
- Data persistence: Saat ini data hanya di memory, restart akan reset tracking

## 🤝 Contributing

Feel free to fork, modify, dan improve!

## 📄 License

MIT License - Gunakan sesuka hati!

## 🔗 Links

- [DexScreener](https://dexscreener.com)
- [DexScreener API Docs](https://docs.dexscreener.com)
- [Telegram Bot API](https://core.telegram.org/bots/api)

---

**Happy Tracking! 🚀**
