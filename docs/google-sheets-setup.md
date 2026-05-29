# Setup Google Sheets

Buat satu spreadsheet baru, lalu tambahkan 4 sheet (tab) berikut:

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
- `start` / `main_menu` — Menu utama
- `ordering` — Menunggu input pesanan
- `order_confirm` — Menunggu konfirmasi pesanan
- `order_name` — Menunggu nama pemesan
- `order_type` — Menunggu tipe pesanan
- `order_final` — Konfirmasi akhir pesanan
- `reservation_guests` — Menunggu jumlah tamu
- `reservation_date` — Menunggu tanggal
- `reservation_time` — Menunggu jam
- `reservation_name` — Menunggu nama reservasi
- `reservation_confirm` — Konfirmasi reservasi

## Sheet 2: Orders

Rekap semua pesanan yang masuk.

| Kolom | Tipe | Keterangan |
|---|---|---|
| order_id | Text | ID unik (ORD-xxxxxx) |
| phone | Text | Nomor WA pemesan |
| customer_name | Text | Nama pelanggan |
| items | Text | Daftar pesanan |
| order_type | Text | `dine-in` atau `take-away` |
| status | Text | `confirmed` / `processing` / `done` |
| order_time | DateTime | Waktu pesanan masuk |

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

## Sheet 4: Menu

Daftar menu — bisa diupdate langsung dari spreadsheet.

| Kolom | Tipe | Keterangan |
|---|---|---|
| id | Number | ID menu |
| category | Text | Kategori (Ayam, Sate, Sayuran, dll) |
| name | Text | Nama menu |
| description | Text | Deskripsi singkat |
| price | Number | Harga (tanpa titik/koma) |
| available | Boolean | `TRUE` / `FALSE` |

### Isi Awal Menu Sasak Lombok

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

## Cara Ambil Spreadsheet ID

Buka spreadsheet di browser. URL-nya seperti ini:
```
https://docs.google.com/spreadsheets/d/1BxiMVs0XRA5nFMdKvBdBZjgmUUqptlbs74OgVE2upms/edit
                                       ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
                                       ini adalah GOOGLE_SHEET_ID
```

Salin ID tersebut ke file `.env`.
