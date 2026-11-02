import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import '../config.dart';
import '../models/song.dart';
import '../services/r2_service.dart';

class PlayerController {
  final AudioPlayer player = AudioPlayer();
  final ValueNotifier<Song?> current = ValueNotifier(null);
  List<Song> _playlist = [];

  // Dipanggil buat ngisi durasi asli lagu.
  void Function(String songId, int durationMs)? onDuration;

  PlayerController() {
    // Loop terus: habis lagu terakhir balik ke lagu pertama
    player.setLoopMode(LoopMode.all);

    // Lagu yang lagi main berubah (otomatis / next / prev / dari notifikasi)
    player.currentIndexStream.listen((i) {
      if (i != null && i >= 0 && i < _playlist.length) {
        current.value = _playlist[i];
      }
    });

    player.durationStream.listen((d) {
      final i = player.currentIndex;
      if (d != null && i != null && i >= 0 && i < _playlist.length) {
        onDuration?.call(_playlist[i].id, d.inMilliseconds);
      }
    });
  }

  // File lokal kalau ada, kalau nggak streaming dari R2 lewat Worker.
  AudioSource _sourceOf(Song s) {
    final tag = MediaItem(id: s.id, title: s.title, artist: s.artist);
    final path = s.localCachePath;
    if (path != null && File(path).existsSync()) {
      return AudioSource.file(path, tag: tag);
    }
    return AudioSource.uri(
      Uri.parse(R2Service.songUrl(s.id)),
      headers: Config.authHeaders,
      tag: tag,
    );
  }

  /// Putar [song]. [queue] = urutan lagu yang lagi tampil di list.
  /// Return null kalau sukses, atau pesan error kalau gagal.
  Future<String?> play(Song song, List<Song> queue) async {
    final index = queue.indexWhere((s) => s.id == song.id);
    if (index == -1) return 'Lagu tidak ditemukan di daftar';

    try {
      _playlist = List.of(queue);
      await player.setAudioSource(
        ConcatenatingAudioSource(
          children: [for (final s in queue) _sourceOf(s)],
        ),
        initialIndex: index,
        initialPosition: Duration.zero,
      );
      current.value = song;
      player.play(); // tanpa await, future-nya baru selesai pas lagu habis
      return null;
    } catch (e) {
      return 'Gagal memutar lagu: $e';
    }
  }

  Future<void> toggle() => player.playing ? player.pause() : player.play();

  Future<void> seek(Duration position) => player.seek(position);

  Future<void> next() => player.seekToNext();

  Future<void> previous() async {
    // Udah lewat 3 detik -> "prev" = ulang dari awal (kayak Spotify)
    if (player.position > const Duration(seconds: 3)) {
      await player.seek(Duration.zero);
    } else {
      await player.seekToPrevious();
    }
  }

  void dispose() {
    player.dispose();
    current.dispose();
  }
}
