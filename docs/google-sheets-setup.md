# Setup Google Sheets

Buat satu spreadsheet baru, lalu tambahkan 5 sheet (tab) berikut:

---

## Sheet 1: Sessions

Menyimpan status percakapan setiap nomor WA.

| Kolom | Tipe | Keterangan |
|---|---|---|
| phone | Text | Nomor WA (628xxx) — **primary key** |
| name | Text | Nama pelanggan dari WA |
| state | Text | Status percakapan saat ini |
| cart | Text | JSON array item di keranjang |
| pending_order | Text | Teks pesanan yang belum dikonfirmasi |
| order_customer_name | Text | Nama pemesan |
| order_type | Text | `dine-in` atau `take-away` |
| last_order_id | Text | ID pesanan terakhir |
| reservation_guests | Number | Jumlah tamu reservasi |
| reservation_date | Text | Tanggal reservasi |
| reservation_time | Text | Jam reservasi |
| reservation_name | Text | Nama untuk reservasi |
| last_reservation_id | Text | ID reservasi terakhir |
| last_updated | DateTime | Waktu update terakhir |

**Nilai `state` yang valid:**

| State | Keterangan |
|---|---|
| `start` / `main_menu` | Menu utama |
| `ordering` | Menunggu input pesanan |
| `order_confirm` | Menunggu konfirmasi pesanan |
| `order_name` | Menunggu nama pemesan |
| `order_type` | Menunggu tipe (dine-in/take-away) |
| `order_final` | Konfirmasi akhir pesanan |
| `reservation_guests` | Menunggu jumlah tamu |
| `reservation_date` | Menunggu tanggal |
| `reservation_time` | Menunggu jam |
| `reservation_name` | Menunggu nama reservasi |
| `reservation_confirm` | Konfirmasi reservasi |

---

## Sheet 2: Orders

Rekap semua pesanan masuk.

| Kolom | Tipe | Keterangan |
|---|---|---|
| order_id | Text | ID unik (ORD-xxxxxx) |
| phone | Text | Nomor WA pemesan |
| customer_name | Text | Nama pelanggan |
| items | Text | Daftar pesanan |
| order_type | Text | `dine-in` atau `take-away` |
| status | Text | `confirmed` / `feedback_sent` / `done` / `cancelled` |
| order_time | DateTime | Waktu pesanan masuk |

**Alur status:** `confirmed` → `feedback_sent` (otomatis 45 menit kemudian) → `done` (diupdate staff)

---

## Sheet 3: Reservations

Rekap semua reservasi meja.

| Kolom | Tipe | Keterangan |
|---|---|---|
| reservation_id | Text | ID unik (RES-xxxxxx) |
| phone | Text | Nomor WA |
| customer_name | Text | Nama tamu |
| guests | Number | Jumlah tamu |
| date | Text | Tanggal kedatangan |
| time | Text | Jam kedatangan |
| status | Text | `confirmed` / `cancelled` |
| created_at | DateTime | Waktu booking dibuat |

---

## Sheet 4: Menu

Daftar menu — bisa diupdate langsung dari spreadsheet.

| Kolom | Tipe | Keterangan |
|---|---|---|
| id | Number | ID menu |
| category | Text | Kategori |
| name | Text | Nama menu |
| description | Text | Deskripsi singkat |
| price | Number | Harga (angka saja, tanpa Rp) |
| available | Boolean | `TRUE` / `FALSE` |

### Data Awal Menu Sasak Lombok

| id | category | name | price | available |
|---|---|---|---|---|
| 1 | Ayam | Ayam Taliwang Pedas | 45000 | TRUE |
| 2 | Ayam | Ayam Taliwang Tidak Pedas | 45000 | TRUE |
| 3 | Ayam | Pelecing Ayam | 40000 | TRUE |
| 4 | Sate | Sate Rembiga | 35000 | TRUE |
| 5 | Sate | Sate Ayam Bulayak | 30000 | TRUE |
| 6 | Sayuran | Plecing Kangkung | 20000 | TRUE |
| 7 | Sayuran | Beberuk Terong | 15000 | TRUE |
| 8 | Sayuran | Urap Sayur | 18000 | TRUE |
| 9 | Nasi | Nasi Balap Puyung | 25000 | TRUE |
| 10 | Nasi | Nasi Putih | 5000 | TRUE |
| 11 | Ikan | Ikan Bakar Bumbu Lombok | 55000 | TRUE |
| 12 | Ikan | Ikan Goreng Pedas | 50000 | TRUE |
| 13 | Minuman | Es Kelapa Muda | 15000 | TRUE |
| 14 | Minuman | Es Teh Manis | 8000 | TRUE |
| 15 | Minuman | Es Jeruk | 10000 | TRUE |
| 16 | Minuman | Air Mineral | 5000 | TRUE |

---

## Sheet 5: Broadcasts

Antrian pesan promo untuk dikirim ke semua pelanggan.

| Kolom | Tipe | Keterangan |
|---|---|---|
| broadcast_id | Text | ID unik broadcast (misal: BC-001) |
| message | Text | Isi pesan promo (bisa pakai format WA *bold*, _italic_) |
| status | Text | `pending` = siap kirim, `sent` = sudah terkirim |
| recipients | Number | Jumlah penerima (diisi otomatis setelah kirim) |
| sent_at | DateTime | Waktu dikirim (diisi otomatis) |
| created_at | DateTime | Waktu pesan dibuat |

### Cara Kirim Promo

1. Buka sheet **Broadcasts**
2. Tambah baris baru:
   - `broadcast_id`: BC-001 (nomor urut)
   - `message`: isi pesan promo kamu
   - `status`: **pending**
3. Buka n8n → Workflow **02 - Broadcast Promo**
4. Klik **Execute** (play manual)
5. Bot akan kirim ke semua pelanggan dengan jeda 2 detik per nomor

### Contoh Pesan Promo

```
*PROMO AKHIR PEKAN!* 🌶️

Diskon 20% untuk Ayam Taliwang & Sate Rembiga!

Berlaku: Sabtu - Minggu, 10.00 - 22.00 WITA

Syarat: Menunjukkan pesan ini saat memesan

Info & reservasi:
https://wa.me/628xxxxxxxxx

_Restoran Sasak Lombok_
```

---

## Cara Ambil Spreadsheet ID

Buka spreadsheet di browser:
```
https://docs.google.com/spreadsheets/d/[SPREADSHEET_ID]/edit
```
Salin bagian `[SPREADSHEET_ID]` ke file `.env` sebagai `GOOGLE_SHEET_ID`.
