// Model buat satu lagu.
// TODO: sesuaikan field kalau ada tambahan (misal genre, playlist_id, dll)

class Song {
  final String id; // uuid, generate pas upload
  final String title;
  final String artist;
  final int durationMs;
  final String r2Key; // path/key file di R2, bukan URL langsung
  final String? coverR2Key; // optional, kalau mau ada cover art
  final DateTime addedAt;
  final bool isPinned; // true = ngk boleh kehapus otomatis dari cache
  final String? localCachePath; // null kalau belum pernah didownload/cache

  Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.durationMs,
    required this.r2Key,
    this.coverR2Key,
    required this.addedAt,
    this.isPinned = false,
    this.localCachePath,
  });

  // TODO: fromMap() / toMap() buat konversi ke/dari SQLite row
}
