# Deploy ke Railway — Panduan Lengkap

## Prasyarat

```bash
# Install Railway CLI
npm install -g @railway/cli

# Login
railway login
```

---

## Arsitektur di Railway

```
Railway Project: restoran-lombok
├── Service: n8n              ← workflow engine
├── Service: evolution-api    ← WhatsApp connection
├── Plugin: PostgreSQL        ← database
└── Plugin: Redis             ← cache
```

Semua service dalam satu project bisa saling komunikasi via **internal hostname** Railway.

---

## Step 1 — Buat Project & Deploy n8n

```bash
# Di folder repo n8n-autochat
cd n8n-autochat

# Buat project baru di Railway
railway init
# Pilih: Create new project
# Nama: restoran-lombok

# Deploy service n8n (pakai Dockerfile di root)
railway up
```

Railway akan otomatis mendeteksi `Dockerfile` dan mendeploy n8n.

---

## Step 2 — Tambah PostgreSQL & Redis

```bash
# Tambah PostgreSQL plugin
railway add --plugin postgresql

# Tambah Redis plugin
railway add --plugin redis
```

Atau lewat dashboard Railway:
- Klik **+ New** → **Database** → **PostgreSQL**
- Klik **+ New** → **Database** → **Redis**

---

## Step 3 — Set Environment Variables n8n

```bash
railway variables set \
  N8N_HOST="${{RAILWAY_PUBLIC_DOMAIN}}" \
  N8N_PROTOCOL="https" \
  WEBHOOK_URL="https://${{RAILWAY_PUBLIC_DOMAIN}}/" \
  N8N_BASIC_AUTH_ACTIVE="true" \
  N8N_BASIC_AUTH_USER="admin" \
  N8N_BASIC_AUTH_PASSWORD="ganti_password_aman" \
  GENERIC_TIMEZONE="Asia/Makassar" \
  DB_TYPE="postgresdb" \
  DB_POSTGRESDB_HOST="${{Postgres.PGHOST}}" \
  DB_POSTGRESDB_PORT="${{Postgres.PGPORT}}" \
  DB_POSTGRESDB_DATABASE="${{Postgres.PGDATABASE}}" \
  DB_POSTGRESDB_USER="${{Postgres.PGUSER}}" \
  DB_POSTGRESDB_PASSWORD="${{Postgres.PGPASSWORD}}" \
  RESTAURANT_NAME="Restoran Sasak Lombok" \
  RESTAURANT_ADDRESS="Jl. Raya Senggigi No. 123, Lombok Barat, NTB" \
  RESTAURANT_PHONE="628123456789" \
  RESTAURANT_MAPS="https://maps.google.com/?q=-8.4095,116.0571" \
  WA_OWNER_NUMBER="628123456789" \
  WA_KITCHEN_NUMBER="628123456790" \
  GOOGLE_SHEET_ID="isi_spreadsheet_id_kamu"
```

> **Catatan:** `${{Postgres.PGHOST}}` adalah referensi Railway ke plugin PostgreSQL.
> Di dashboard Railway, ini bisa diisi lewat **Variables → Add Reference**.

---

## Step 4 — Deploy Evolution API

Evolution API perlu service **terpisah** karena butuh Dockerfile berbeda dan volume persistent.

### Buat Service Baru di Dashboard

1. Buka **railway.app/dashboard**
2. Project `restoran-lombok` → **+ New Service**
3. Pilih **GitHub Repo** → repo yang sama (`n8n-autochat`)
4. Di **Settings** service baru ini:
   - Ubah **Dockerfile Path** → `Dockerfile.evolution`
   - Ubah **Root Directory** → `/` (kosong)

### Set Variables Evolution API

Di service Evolution API, klik **Variables** → tambah:

```
SERVER_URL             = https://[domain-evolution-api-kamu].up.railway.app
AUTHENTICATION_API_KEY = buat_api_key_panjang_acak_disini
DATABASE_PROVIDER      = postgresql
DATABASE_CONNECTION_URI = ${{Postgres.DATABASE_URL}}
CACHE_REDIS_ENABLED    = true
CACHE_REDIS_URI        = ${{Redis.REDIS_URL}}
CONFIG_SESSION_PHONE_CLIENT = Restoran Sasak Lombok
QRCODE_LIMIT           = 30
DEL_INSTANCE           = false
```

### Tambah Volume untuk Session WA

Ini **penting** agar session WA tidak hilang saat redeploy:

1. Service Evolution API → **Settings** → **Volumes**
2. **+ Add Volume**
   - Mount path: `/evolution/instances`
   - Size: 1 GB

---

## Step 5 — Hubungkan n8n ke Evolution API

Setelah Evolution API ter-deploy, salin domain publiknya (misal: `evolution-xxx.up.railway.app`).

Lalu tambah variable di service **n8n**:

```bash
railway variables set \
  EVOLUTION_URL="https://evolution-xxx.up.railway.app" \
  EVOLUTION_API_KEY="api_key_yang_sama_dengan_evolution" \
  EVOLUTION_INSTANCE="restoran_lombok"
```

---

## Step 6 — Setup WA Instance

Setelah Evolution API jalan:

```bash
# 1. Buat instance
curl -X POST https://evolution-xxx.up.railway.app/instance/create \
  -H "apikey: API_KEY_KAMU" \
  -H "Content-Type: application/json" \
  -d '{"instanceName": "restoran_lombok", "qrcode": true}'

# 2. Lihat QR code (scan dengan WA Business)
curl https://evolution-xxx.up.railway.app/instance/connect/restoran_lombok \
  -H "apikey: API_KEY_KAMU"

# 3. Set webhook ke n8n
curl -X POST https://evolution-xxx.up.railway.app/webhook/set/restoran_lombok \
  -H "apikey: API_KEY_KAMU" \
  -H "Content-Type: application/json" \
  -d '{
    "url": "https://[domain-n8n-kamu].up.railway.app/webhook/evolution-webhook",
    "events": ["MESSAGES_UPSERT"]
  }'
```

---

## Step 7 — Import Workflows n8n

1. Buka `https://[domain-n8n].up.railway.app`
2. Login dengan user/password yang sudah di-set
3. **Settings → Import from File** → upload satu per satu:
   - `workflows/01-main-chatbot.json`
   - `workflows/02-broadcast-promo.json`
   - `workflows/03-customer-feedback.json`
   - `workflows/04-daily-report.json`
4. Tambah credential **Google Sheets OAuth2**
5. Ganti semua `REPLACE_WITH_YOUR_CREDENTIAL_ID` di setiap workflow
6. **Aktifkan** semua workflow

---

## Cek Status Deployment

```bash
# Lihat semua service
railway status

# Lihat log n8n
railway logs

# Lihat log service tertentu
railway logs --service evolution-api
```

---

## Estimasi Biaya Railway

| Resource | Estimasi/bulan |
|---|---|
| n8n service (512MB RAM) | ~$2-3 |
| Evolution API (256MB RAM) | ~$1-2 |
| PostgreSQL | ~$0 (free tier) |
| Redis | ~$0 (free tier) |
| Volume 1GB | ~$0.25 |
| **Total** | **~$3-5** |

Railway memberikan **$5 credit gratis** per bulan untuk akun baru.
Artinya bisa **gratis untuk bulan pertama**, bulan selanjutnya ~$3-5.

---

## Tips Railway

- **Custom domain**: Settings → Networking → Custom Domain (gratis)
- **Auto-deploy**: setiap push ke branch ini akan otomatis redeploy n8n
- **Jangan lupa volume** untuk Evolution API atau session WA hilang saat redeploy
- Gunakan **Sleep on Inactivity: OFF** di settings service agar tidak sleep
