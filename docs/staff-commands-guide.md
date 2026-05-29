# Panduan Staff Commands via WhatsApp

Staff dapur/kasir bisa kelola pesanan langsung via WhatsApp ke nomor restoran.
Bot akan mengenali pesan dari nomor `WA_KITCHEN_NUMBER` dan `WA_OWNER_NUMBER` sebagai perintah staff.

## Setup Staff Commands di Main Chatbot

Untuk mengaktifkan staff commands, tambahkan node berikut di workflow `01-main-chatbot`
**setelah** node **Extract Message Data** dan **sebelum** node **Get Session**:

### Node Baru: "Is Staff?"

**Type:** IF Node

**Kondisi:**
```
{{ $json.phone }} == {{ $env.WA_KITCHEN_NUMBER }}
OR
{{ $json.phone }} == {{ $env.WA_OWNER_NUMBER }}
```

### Node Baru: "Handle Staff Command"

**Type:** Code Node

**Code:**
```javascript
const phone = $json.phone;
const msg = $json.messageLower;
const originalMsg = $json.message;

let responseText = '';
let staffAction = null;
let targetOrderId = null;

// Perintah staff
if (msg.startsWith('selesai ') || msg.startsWith('done ')) {
  targetOrderId = msg.split(' ')[1]?.toUpperCase();
  staffAction = 'complete_order';
  responseText = `Menandai pesanan ${targetOrderId} sebagai selesai...`;

} else if (msg.startsWith('batal ') || msg.startsWith('cancel ')) {
  targetOrderId = msg.split(' ')[1]?.toUpperCase();
  staffAction = 'cancel_order';
  responseText = `Membatalkan pesanan ${targetOrderId}...`;

} else if (msg === 'status' || msg === 'laporan cepat') {
  staffAction = 'quick_status';
  responseText = 'Mengambil data hari ini...';

} else {
  // Tampilkan menu perintah staff
  responseText = `*PERINTAH STAFF*

- SELESAI [ID] - Tandai pesanan selesai
  Contoh: SELESAI ORD-123456

- BATAL [ID] - Batalkan pesanan
  Contoh: BATAL ORD-123456

- STATUS - Lihat ringkasan hari ini

Format ID pesanan: ORD-xxxxxx`;
}

return [{ json: { phone, msg, responseText, staffAction, targetOrderId, instance: $json.instance } }];
```

### Alur Setelah Staff Command

Berdasarkan `staffAction`:

| staffAction | Tindakan |
|---|---|
| `complete_order` | Update status di Orders sheet → Cari phone customer → Kirim notif ke customer |
| `cancel_order` | Update status di Orders sheet → Kirim notif ke customer |
| `quick_status` | Hitung pesanan hari ini dari sheet → Kirim ringkasan ke staff |

### Pesan Notifikasi ke Customer

**Pesanan Selesai:**
```
Halo [nama]! 🍽️

Pesanan kamu *[ORD-ID]* sudah siap!

Silakan ambil di kasir.
Terima kasih sudah makan di Restoran Sasak Lombok! 🙏
```

**Pesanan Dibatalkan:**
```
Maaf [nama],

Pesanan *[ORD-ID]* harus kami batalkan.

Untuk info lebih lanjut hubungi:
[RESTAURANT_PHONE]

Mohon maaf atas ketidaknyamanannya. 🙏
```

## Nomor WA Staff

Atur di file `.env`:
```
WA_KITCHEN_NUMBER=628xxxxxxxxx   # Nomor dapur
WA_OWNER_NUMBER=628xxxxxxxxx     # Nomor owner
```

Hanya nomor ini yang bisa menggunakan staff commands. Pelanggan biasa tidak terpengaruh.
