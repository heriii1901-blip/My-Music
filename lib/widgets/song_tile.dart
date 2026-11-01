import 'package:flutter/material.dart';
import '../models/song.dart';

class SongTile extends StatelessWidget {
  final Song song;
  final bool isPlaying;
  final bool selectionMode;
  final bool selected;
  final VoidCallback onTap;

  const SongTile({
    super.key,
    required this.song,
    required this.isPlaying,
    required this.onTap,
    this.selectionMode = false,
    this.selected = false,
  });

  String _formatDuration(int ms) {
    final total = Duration(milliseconds: ms);
    final m = total.inMinutes;
    final s = (total.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final cached = song.localCachePath != null;
    final color = Theme.of(context).colorScheme;

    return ListTile(
      onTap: onTap,
      selected: isPlaying,
      // Kiri: cover lagu. Sementara placeholder, nanti diganti gambar dari coverR2Key.
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 48,
          height: 48,
          color: color.surfaceContainerHighest,
          child: Icon(Icons.music_note, color: color.outline),
        ),
      ),
      title: Text(song.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Row(
        children: [
          // Penanda kecil lagu yang di-pin. Hapus blok if ini kalau gak mau.
          if (song.isPinned) ...[
            Icon(Icons.push_pin, size: 14, color: color.primary),
            const SizedBox(width: 4),
          ],
          Text(_formatDuration(song.durationMs)),
        ],
      ),
      // Kanan: kotak centang saat mode pilih, selain itu status cloud/ceklis.
      trailing: selectionMode
          ? Checkbox(
              value: selected,
              onChanged: (_) => onTap(),
            )
          : Icon(
              cached ? Icons.check_circle : Icons.cloud_outlined,
              color: cached ? Colors.greenAccent : color.outline,
            ),
    );
  }
}
