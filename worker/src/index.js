// Cloudflare Worker: jembatan aman antara app dan R2
// App ngk pernah pegang R2 access key langsung, semua lewat sini

export default {
  async fetch(request, env) {
    // TODO: route "/upload-url" -> generate presigned PUT URL buat upload file baru
    // TODO: route "/download-url" -> generate presigned GET URL buat streaming/download
    // TODO: tambahin auth check sederhana (misal API key/token) biar Worker
    //       ngk bisa dipanggil sembarang orang

    return new Response("musikku worker - belum diimplementasi", { status: 200 });
  },
};

// wrangler.toml (config Worker) bikin terpisah, isinya binding ke R2 bucket:
// [[r2_buckets]]
// binding = "MUSIC_BUCKET"
// bucket_name = "musikku-bucket"
