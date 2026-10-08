import 'package:flutter/material.dart';
import '../models/song.dart';
import '../widgets/song_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Data dummy dulu. Nanti diganti load dari AppDatabase.
  late List<Song> _songs;
  String? _playingId;

  @override
  void initState() {
    super.initState();
    _songs = List.generate(12, (i) {
      return Song(
        id: 'dummy-$i',
        title: 'Lagu Contoh ${i + 1}',
        artist: i.isEven ? 'Artis A' : 'Artis B',
        durationMs: (150 + i * 17) * 1000,
        r2Key: 'songs/dummy-$i.mp3',
        addedAt: DateTime.now(),
        // tiap lagu ke-3 dianggap sudah ke-cache
        localCachePath: i % 3 == 0 ? '/dummy/path/$i.mp3' : null,
      );
    });
  }

  void _togglePin(int index) {
    setState(() {
      _songs[index] = _songs[index].copyWith(isPinned: !_songs[index].isPinned);
    });
  }

  @override
  Widget build(BuildContext context) {
    final playing = _songs.where((s) => s.id == _playingId).firstOrNull;

    return Scaffold(
      appBar: AppBar(title: const Text('musikku')),
      body: ListView.builder(
        itemCount: _songs.length,
        itemBuilder: (context, i) {
          final song = _songs[i];
          return SongTile(
            song: song,
            isPlaying: song.id == _playingId,
            onTap: () => setState(() => _playingId = song.id),
            onTogglePin: () => _togglePin(i),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tambah lagu: belum diimplementasi')),
          );
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: playing == null
          ? null
          : BottomAppBar(
              child: Row(
                children: [
                  const Icon(Icons.music_note),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '${playing.title} - ${playing.artist}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
