# Setup Evolution API & Webhook

## 1. Akses Evolution API

Setelah `docker compose up -d`, buka:
```
http://your-domain.com:8080
```

Atau gunakan Swagger UI di:
```
http://your-domain.com:8080/docs
```

## 2. Buat Instance WA

POST ke `/instance/create` dengan header `apikey: YOUR_EVOLUTION_API_KEY`:

```json
{
  "instanceName": "restoran_lombok",
  "qrcode": true,
  "integration": "WHATSAPP-BAILEYS"
}
```

## 3. Scan QR Code

GET `/instance/connect/restoran_lombok` → akan tampil QR code.

Buka WhatsApp Business di HP → Linked Devices → Scan QR.

## 4. Set Webhook ke n8n

POST ke `/webhook/set/restoran_lombok`:

```json
{
  "url": "https://your-domain.com/webhook/evolution-webhook",
  "webhook_by_events": false,
  "webhook_base64": false,
  "events": [
    "MESSAGES_UPSERT"
  ]
}
```

Ganti `https://your-domain.com/webhook/evolution-webhook` dengan URL webhook n8n kamu.

> URL webhook n8n bisa dilihat di workflow **01-Main Chatbot**, klik node **Evolution Webhook**,
> lalu copy **Production URL** atau **Test URL**.

## 5. Verifikasi Koneksi

GET `/instance/fetchInstances` → status harus `open`.

Coba kirim pesan ke nomor WA yang sudah di-scan. Bot harus membalas.

## Troubleshooting

| Masalah | Solusi |
|---|---|
| QR expired | GET `/instance/connect/restoran_lombok` lagi |
| Status `close` | Restart instance: POST `/instance/restart/restoran_lombok` |
| Webhook tidak menerima | Cek URL webhook di n8n, pastikan workflow aktif |
| Pesan tidak terkirim | Cek EVOLUTION_API_KEY di `.env`, restart evolution-api container |
