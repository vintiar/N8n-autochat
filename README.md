# n8n WhatsApp Automation — Restoran Sasak Lombok

Sistem otomasi WhatsApp lengkap untuk restoran khas Lombok menggunakan n8n + Evolution API + Google Sheets.

## Fitur

| Fitur | Workflow | Keterangan |
|---|---|---|
| Auto-reply & Menu | 01 | Balas otomatis, info menu, harga, jam, lokasi |
| Terima Pesanan | 01 | Order via WA, konfirmasi customer, notif dapur |
| Reservasi Meja | 01 | Booking meja percakapan natural, notif owner |
| Broadcast Promo | 02 | Kirim promo ke semua pelanggan, jeda 2 detik/pesan |
| Customer Feedback | 03 | Request rating otomatis 45 menit setelah pesan |
| Laporan Harian | 04 | Rekap pesanan & reservasi setiap 22:00 WITA ke owner |
| Staff Commands | 01* | Staff bisa update status pesanan via WA |

*Staff commands memerlukan konfigurasi tambahan, lihat `docs/staff-commands-guide.md`

## Stack

| Komponen | Fungsi |
|---|---|
| n8n | Workflow automation engine |
| Evolution API | WhatsApp Business connection |
| PostgreSQL | Database n8n & Evolution API |
| Redis | Cache session Evolution API |
| Google Sheets | Penyimpanan data (menu, pesanan, reservasi, broadcast) |

## Quick Start

### 1. Clone & Konfigurasi

```bash
git clone https://github.com/vintiar/n8n-autochat.git
cd n8n-autochat
cp .env.example .env
nano .env   # isi semua nilai
```

### 2. Jalankan Services

```bash
docker compose up -d
# Akses n8n: http://your-server:5678
```

### 3. Setup Google Sheets

Buat spreadsheet baru dengan 5 sheet:
`Sessions` | `Orders` | `Reservations` | `Menu` | `Broadcasts`

Lihat panduan lengkap: `docs/google-sheets-setup.md`

### 4. Setup Evolution API

```
1. Buat instance: POST /instance/create
2. Scan QR code
3. Set webhook ke URL n8n
```

Lihat panduan: `docs/setup-evolution-api.md`

### 5. Import Workflows n8n

Di n8n: **Settings → Import from File**

```
workflows/01-main-chatbot.json       # Wajib - chatbot utama
workflows/02-broadcast-promo.json    # Promo ke semua pelanggan
workflows/03-customer-feedback.json  # Feedback otomatis
workflows/04-daily-report.json       # Laporan harian
```

### 6. Konfigurasi Credentials

Di n8n: **Credentials → Add Credential → Google Sheets OAuth2**

Setelah dibuat, ganti semua `REPLACE_WITH_YOUR_CREDENTIAL_ID` di ke-4 workflow dengan ID credential kamu.

### 7. Aktifkan Workflows

Aktifkan workflow satu per satu dengan toggle di n8n. Urutan:
1. `01-main-chatbot` (aktifkan pertama)
2. `03-customer-feedback`
3. `04-daily-report`

Workflow `02-broadcast-promo` dijalankan manual sesuai kebutuhan.

## Alur Percakapan Customer

```
Customer: halo
Bot: Selamat datang! Pilih: 1.Menu 2.Pesan 3.Reservasi 4.Jam 5.Lokasi

Customer: 2
Bot: Ketik pesanan kamu...

Customer: 2 Ayam Taliwang, 1 Plecing Kangkung
Bot: Konfirmasi pesanan? (ya/tidak)

Customer: ya → (nama) → (dine-in/take-away) → konfirmasi
Bot: Pesanan ORD-123456 berhasil! Notif dikirim ke dapur.

[45 menit kemudian - otomatis]
Bot: Bagaimana pesanannya? Rating 1-5?
```

## Alur Reservasi

```
Customer: 3
Bot: Berapa orang?

Customer: 4 → (tanggal) → (jam) → (nama) → konfirmasi
Bot: Reservasi RES-123456 berhasil! Owner dinotifikasi.
```

## Struktur Repo

```
n8n-autochat/
├── docker-compose.yml
├── .env.example
├── workflows/
│   ├── 01-main-chatbot.json       # Chatbot utama + pesanan + reservasi
│   ├── 02-broadcast-promo.json    # Broadcast promo ke semua customer
│   ├── 03-customer-feedback.json  # Auto-request feedback 45 menit post-order
│   └── 04-daily-report.json       # Laporan harian 22:00 WITA ke owner
└── docs/
    ├── google-sheets-setup.md     # Struktur 5 sheet + data awal menu
    ├── setup-evolution-api.md     # Setup WA instance & webhook
    └── staff-commands-guide.md    # Integrasi perintah staff via WA
```

## Troubleshooting

| Masalah | Solusi |
|---|---|
| Bot tidak membalas | Pastikan workflow 01 aktif, cek webhook Evolution API |
| Google Sheets error | Cek credential ID sudah benar di semua workflow |
| Pesanan tidak tersimpan | Pastikan sheet `Orders` ada dengan kolom yang benar |
| Laporan tidak terkirim | Cek `WA_OWNER_NUMBER` di `.env`, pastikan format `628xxx` |
| Broadcast tidak jalan | Pastikan sheet `Broadcasts` ada baris dengan `status=pending` |
