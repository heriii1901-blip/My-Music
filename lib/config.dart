class Config {
  static const workerUrl = 'https://musikku.my-music1901.workers.dev'; // tanpa "/" di akhir
  static const apiToken = 'TOKENMU';0wmc3vfpb8dnosaj5g2iyh17uz4txl9kqre6

  static Map<String, String> get authHeaders =>
      {'Authorization': 'Bearer $apiToken'};
}
