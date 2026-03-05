const express = require('express');
const cors = require('cors');
const axios = require('axios');
const app = express();

app.use(cors());
app.use(express.json());
app.use(express.static('.'));

const TELEGRAM_CACHE = new Map();
const SEEN_PAIRS = new Set();

// Endpoint untuk mendapatkan koin terbaru dari DexScreener
app.get('/api/latest-pairs/:chain', async (req, res) => {
    try {
        const { chain } = req.params;
        const limit = req.query.limit || 20;
        
        // DexScreener API endpoint untuk pairs terbaru
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

// Endpoint untuk mendapatkan token info
app.get('/api/tokens/:address', async (req, res) => {
    try {
        const { address } = req.params;
        
        const response = await axios.get(`https://api.dexscreener.com/latest/dex/tokens/${address}`, {
            headers: {
                'Accept': 'application/json'
            }
        });

        res.json(response.data);
    } catch (error) {
        console.error('Error fetching token:', error.message);
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
