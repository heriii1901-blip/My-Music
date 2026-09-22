// Skeleton database lokal (rencana pake drift atau sqflite).
// TODO: pilih salah satu (drift lebih type-safe, sqflite lebih ringan/simpel)

// Skema kasar tabel `songs`:
//
// CREATE TABLE songs (
//   id TEXT PRIMARY KEY,
//   title TEXT NOT NULL,
//   artist TEXT,
//   duration_ms INTEGER,
//   r2_key TEXT NOT NULL,
//   cover_r2_key TEXT,
//   added_at INTEGER NOT NULL,
//   is_pinned INTEGER DEFAULT 0,
//   local_cache_path TEXT
// );

class AppDatabase {
  // TODO: init koneksi db
  // TODO: insertSong(Song song)
  // TODO: getAllSongs()
  // TODO: deleteSong(String id)
  // TODO: updatePinStatus(String id, bool pinned)
  // TODO: updateLocalCachePath(String id, String? path)
}
