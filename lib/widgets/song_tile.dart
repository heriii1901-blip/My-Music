import 'package:flutter/material.dart';
import '../models/song.dart';

class SongTile extends StatelessWidget {
  final Song song;
  final bool isPlaying;
  final VoidCallback onTap;
  final VoidCallback onTogglePin;

  const SongTile({
    super.key,
    required this.song,
    required this.isPlaying,
    required this.onTap,
    required this.onTogglePin,
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
      leading: Icon(
        cached ? Icons.check_circle : Icons.cloud_outlined,
        color: cached ? Colors.greenAccent : color.outline,
      ),
      title: Text(song.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        '${song.artist} • ${_formatDuration(song.durationMs)}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: IconButton(
        icon: Icon(song.isPinned ? Icons.push_pin : Icons.push_pin_outlined),
        onPressed: onTogglePin,
      ),
    );
  }
}
