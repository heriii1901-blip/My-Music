// Ngatur file audio yang kesimpen lokal (cache dir, bukan folder Music biasa)
// Tujuan: streaming default, download manual per lagu, ada limit ukuran + auto-evict

class CacheManager {
  // static const int maxCacheSizeBytes = 1 * 1024 * 1024 * 1024; // 1GB, bisa diubah

  // TODO: Future<String> downloadAndCache(Song song)
  //   -> download dari presigned URL, simpen ke app cache dir, update local_cache_path

  // TODO: Future<void> evictIfOverLimit()
  //   -> cek total ukuran cache, kalau lebih dari limit, hapus yang paling
  //      lama ngk diputer DAN ngk di-pin (LRU), sampe di bawah limit lagi

  // TODO: Future<void> deleteCachedFile(String songId)
  //   -> hapus file lokal manual (misal user pilih "remove download")
}
