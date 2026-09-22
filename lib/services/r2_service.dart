// Service buat komunikasi ke Cloudflare Worker
// (Worker yang generate presigned URL, app NGK boleh pegang R2 key langsung)

class R2Service {
  // final String workerBaseUrl = "https://xxx.workers.dev";

  // TODO: Future<String> getUploadUrl(String fileName)
  //   -> minta presigned URL ke Worker buat upload file baru

  // TODO: Future<String> getDownloadUrl(String r2Key)
  //   -> minta presigned URL ke Worker buat streaming/download file

  // TODO: Future<void> uploadFile(String presignedUrl, File file)
  //   -> upload langsung ke R2 pake presigned URL di atas
}
