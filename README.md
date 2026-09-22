# musikku

Personal music app — offline-first, file audio di Cloudflare R2, metadata di SQLite lokal.

## Struktur

```
lib/
  models/song.dart          -> struktur data satu lagu
  database/app_database.dart -> koneksi & skema SQLite lokal
  services/r2_service.dart   -> komunikasi ke Worker (buat presigned URL)
  services/cache_manager.dart -> logic download/cache/auto-delete file audio
  screens/home_screen.dart   -> halaman utama (list lagu + tombol tambah)
  widgets/song_tile.dart     -> item satu lagu di list
  player/player_controller.dart -> wrapper player (streaming/offline)

worker/
  src/index.js               -> Cloudflare Worker, generate presigned URL R2
```

## Catatan
- Belum full Flutter project (belum ada folder android/ios/dll). Jalanin `flutter create .`
  di root folder ini buat lengkapin struktur platform-nya, baru file-file di atas nyambung.
- Semua yang di `lib/` masih skeleton/TODO, belum ada logic asli.
- Worker butuh `wrangler.toml` sendiri (di-gitignore, isi binding ke R2 bucket) —
  jangan disamain sama repo public.
