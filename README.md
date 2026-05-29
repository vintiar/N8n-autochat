# n8n WhatsApp Automation — Restoran Sasak Lombok

Sistem otomasi WhatsApp lengkap untuk restoran khas Lombok menggunakan n8n + Evolution API + Google Sheets.

## Fitur

- **Auto-reply & Menu** — Balas otomatis info menu, harga, jam buka, lokasi
- **Terima Pesanan** — Proses order via WA, konfirmasi ke pelanggan, notif ke dapur
- **Reservasi Meja** — Booking meja dengan percakapan natural
- **Laporan Harian** — Rekap pesanan & omzet dikirim ke owner setiap malam

## Stack

| Komponen | Fungsi |
|---|---|
| n8n | Workflow automation engine |
| Evolution API | WhatsApp Business connection |
| PostgreSQL | Database n8n & Evolution API |
| Redis | Cache session Evolution API |
| Google Sheets | Penyimpanan data (menu, pesanan, reservasi) |

## Quick Start

### 1. Clone & Konfigurasi

```bash
git clone https://github.com/vintiar/n8n-autochat.git
cd n8n-autochat
cp .env.example .env
nano .env   # isi semua nilai yang diperlukan
```

### 2. Jalankan Services

```bash
docker compose up -d
```

Akses n8n di: `http://your-domain.com:5678`

### 3. Setup Google Sheets

Buat spreadsheet baru dan tambah 4 sheet sesuai panduan di `docs/google-sheets-setup.md`.

### 4. Setup Evolution API

Lihat panduan lengkap di `docs/setup-evolution-api.md`:
1. Buat instance baru di Evolution API
2. Scan QR code dengan WhatsApp Business
3. Set webhook ke n8n

### 5. Import Workflows n8n

Di n8n: **Settings → Import from File**, lalu import satu per satu:

```
workflows/01-main-chatbot.json     # Chatbot utama (wajib)
workflows/04-daily-report.json     # Laporan harian
```

### 6. Setup Credentials di n8n

- **Google Sheets OAuth2** — tambah credentials, lalu ganti `REPLACE_WITH_YOUR_CREDENTIAL_ID` di semua workflow
- **Evolution API** sudah pakai env vars, tidak perlu credential terpisah

## Alur Percakapan

```
Pelanggan: halo
Bot: Selamat datang di Restoran Sasak Lombok!
     1. Lihat Menu  2. Pesan  3. Reservasi  4. Jam  5. Lokasi

Pelanggan: 2
Bot: Silakan ketik pesanan kamu...

Pelanggan: 2 Ayam Taliwang, 1 Plecing Kangkung
Bot: Konfirmasi pesanan? [ya/tidak]

Pelanggan: ya
Bot: [minta nama] → [dine-in/take-away] → [konfirmasi akhir]
     Pesanan #ORD-123456 berhasil! Notif dikirim ke dapur.
```

## Struktur Repo

```
n8n-autochat/
├── docker-compose.yml
├── .env.example
├── workflows/
│   ├── 01-main-chatbot.json      # Chatbot utama
│   └── 04-daily-report.json      # Laporan harian
└── docs/
    ├── google-sheets-setup.md
    └── setup-evolution-api.md
```
