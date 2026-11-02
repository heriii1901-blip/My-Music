import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../config.dart';
import '../models/song.dart';

// Service buat komunikasi ke Cloudflare Worker.
class R2Service {
  static String songUrl(String id) => '${Config.workerUrl}/songs/$id.mp3';
  static String coverUrl(String id) => '${Config.workerUrl}/covers/$id.png';

  /// Ambil daftar lagu dari R2 (beserta cover-nya).
  Future<List<Song>> fetchLibrary() async {
    final res = await http.get(
      Uri.parse('${Config.workerUrl}/list'),
      headers: Config.authHeaders,
    );
    if (res.statusCode != 200) {
      throw Exception('Gagal ambil daftar lagu (${res.statusCode})');
    }

    final data = jsonDecode(res.body) as List;
    return Future.wait(data.map((e) async {
      final m = e as Map<String, dynamic>;
      final id = m['id'] as String;
      return Song(
        id: id,
        title: m['title'] as String,
        artist: m['artist'] as String,
        durationMs: (m['durationMs'] as num).toInt(),
        r2Key: 'songs/$id.mp3',
        coverBytes: m['hasCover'] == true ? await _fetchCover(id) : null,
        addedAt: DateTime.fromMillisecondsSinceEpoch(
            (m['addedAt'] as num).toInt()),
      );
    }));
  }

  Future<Uint8List?> _fetchCover(String id) async {
    try {
      final res = await http.get(
        Uri.parse(coverUrl(id)),
        headers: Config.authHeaders,
      );
      return res.statusCode == 200 ? res.bodyBytes : null;
    } catch (_) {
      return null;
    }
  }

  /// Upload lagu (+ cover kalau ada). Lempar Exception kalau gagal.
  Future<void> uploadSong({
    required String id,
    required String title,
    required String artist,
    required int durationMs,
    required DateTime addedAt,
    required File file,
    Uint8List? cover,
  }) async {
    final res = await http.put(
      Uri.parse(songUrl(id)),
      headers: {
        ...Config.authHeaders,
        'Content-Type': 'audio/mpeg',
        'x-title': Uri.encodeComponent(title),
        'x-artist': Uri.encodeComponent(artist),
        'x-duration': '$durationMs',
        'x-added': '${addedAt.millisecondsSinceEpoch}',
      },
      body: await file.readAsBytes(),
    );
    if (res.statusCode != 200) {
      throw Exception('Upload lagu gagal (${res.statusCode})');
    }

    if (cover != null) {
      final r = await http.put(
        Uri.parse(coverUrl(id)),
        headers: {...Config.authHeaders, 'Content-Type': 'image/png'},
        body: cover,
      );
      if (r.statusCode != 200) {
        throw Exception('Upload cover gagal (${r.statusCode})');
      }
    }
  }
}
