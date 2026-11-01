import 'package:flutter/material.dart';
import '../models/song.dart';
import '../widgets/song_tile.dart';
import 'upload_screen.dart';

enum SortMode { terbaru, dipin, diunduh, abjad }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Data dummy dulu. Nanti diganti load dari AppDatabase.
  late List<Song> _songs;
  String? _playingId;

  SortMode _sort = SortMode.terbaru;
  bool _selecting = false;
  final Set<String> _selected = {};

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
        // dibedain per jam biar urutan "Terbaru" kelihatan
        addedAt: DateTime.now().subtract(Duration(hours: i)),
        // tiap lagu ke-3 dianggap sudah ke-cache
        localCachePath: i % 3 == 0 ? '/dummy/path/$i.mp3' : null,
      );
    });
  }

  // ---------- Urutan ----------
  int _byNewest(Song a, Song b) => b.addedAt.compareTo(a.addedAt);

  List<Song> get _sorted {
    final list = List<Song>.from(_songs);
    switch (_sort) {
      case SortMode.terbaru:
        list.sort(_byNewest);
        break;
      case SortMode.dipin:
        list.sort((a, b) {
          if (a.isPinned != b.isPinned) return a.isPinned ? -1 : 1;
          return _byNewest(a, b);
        });
        break;
      case SortMode.diunduh:
        list.sort((a, b) {
          final ac = a.localCachePath != null;
          final bc = b.localCachePath != null;
          if (ac != bc) return ac ? -1 : 1;
          return _byNewest(a, b);
        });
        break;
      case SortMode.abjad:
        list.sort(
            (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;
    }
    return list;
  }

  String _sortLabel(SortMode m) {
    switch (m) {
      case SortMode.terbaru:
        return 'Terbaru';
      case SortMode.dipin:
        return 'Di-pin';
      case SortMode.diunduh:
        return 'Diunduh';
      case SortMode.abjad:
        return 'Abjad (A-Z)';
    }
  }

  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Urutkan', style: TextStyle(fontSize: 18)),
            ),
            for (final m in SortMode.values)
              ListTile(
                title: Text(_sortLabel(m)),
                trailing: _sort == m ? const Icon(Icons.check) : null,
                onTap: () {
                  setState(() => _sort = m);
                  Navigator.pop(ctx);
                },
              ),
          ],
        ),
      ),
    );
  }

  // ---------- Mode pilih ----------
  void _exitSelect() {
    setState(() {
      _selecting = false;
      _selected.clear();
    });
  }

  void _onTileTap(Song song) {
    if (_selecting) {
      setState(() {
        if (!_selected.add(song.id)) _selected.remove(song.id);
      });
    } else {
      setState(() => _playingId = song.id);
    }
  }

  // Kalau semua yang dipilih sudah di-pin -> lepas pin. Selain itu -> pin semua.
  void _applyPin() {
    final chosen = _songs.where((s) => _selected.contains(s.id)).toList();
    final allPinned = chosen.every((s) => s.isPinned);
    setState(() {
      _songs = _songs.map((s) {
        return _selected.contains(s.id) ? s.copyWith(isPinned: !allPinned) : s;
      }).toList();
    });
    _exitSelect();
  }

  AppBar _buildAppBar() {
    if (_selecting) {
      return AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _exitSelect,
        ),
        title: Text('${_selected.length} dipilih'),
        actions: [
          IconButton(
            icon: const Icon(Icons.push_pin_outlined),
            tooltip: 'Pin / lepas pin',
            onPressed: _selected.isEmpty ? null : _applyPin,
          ),
        ],
      );
    }
    return AppBar(
      title: const Text('Musikku'),
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (v) {
            if (v == 'select') {
              setState(() => _selecting = true);
            } else if (v == 'sort') {
              _showSortSheet();
            }
          },
          itemBuilder: (ctx) => const [
            PopupMenuItem(value: 'select', child: Text('Pilih')),
            PopupMenuItem(value: 'sort', child: Text('Urutkan...')),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final songs = _sorted;
    final playing = _songs.where((s) => s.id == _playingId).firstOrNull;

    return Scaffold(
      appBar: _buildAppBar(),
      body: ListView.builder(
        itemCount: songs.length,
        itemBuilder: (context, i) {
          final song = songs[i];
          return SongTile(
            song: song,
            isPlaying: song.id == _playingId,
            selectionMode: _selecting,
            selected: _selected.contains(song.id),
            onTap: () => _onTileTap(song),
          );
        },
      ),
      floatingActionButton: _selecting
          ? null
          : FloatingActionButton(
              onPressed: () async {
                final newSong = await Navigator.push<Song>(
                  context,
                  MaterialPageRoute(builder: (_) => const UploadScreen()),
                );
                if (newSong != null) {
                  setState(() => _songs.add(newSong));
                }
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
                      playing.title,
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
