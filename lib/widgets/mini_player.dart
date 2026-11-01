import 'package:flutter/material.dart';
import '../models/song.dart';
import '../player/player_controller.dart';
import 'marquee_text.dart';

class MiniPlayer extends StatelessWidget {
  final PlayerController player;
  final Song song;
  final VoidCallback onTap;

  const MiniPlayer({
    super.key,
    required this.player,
    required this.song,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final p = player.player;

    const btnConstraints = BoxConstraints(minWidth: 40, minHeight: 40);

    return Material(
      color: color.surfaceContainer,
      child: InkWell(
        onTap: onTap,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: song.coverBytes != null
                      ? Image.memory(song.coverBytes!,
                          width: 40, height: 40, fit: BoxFit.cover)
                      : Container(
                          width: 40,
                          height: 40,
                          color: color.surfaceContainerHighest,
                          child: Icon(Icons.music_note, color: color.outline),
                        ),
                ),
                const SizedBox(width: 12),

                // Kiri (~6/10): judul + bar progres
                Expanded(
                  flex: 6,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MarqueeText(
                        text: song.title,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      StreamBuilder<Duration>(
                        stream: p.positionStream,
                        builder: (_, snap) {
                          final total = p.duration?.inMilliseconds ?? 0;
                          final pos = snap.data?.inMilliseconds ?? 0;
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: LinearProgressIndicator(
                              value:
                                  total > 0 ? (pos / total).clamp(0.0, 1.0) : 0,
                              minHeight: 4,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // Kanan (~4/10): prev, play/pause, next
                Expanded(
                  flex: 4,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          iconSize: 26,
                          padding: EdgeInsets.zero,
                          constraints: btnConstraints,
                          icon: const Icon(Icons.skip_previous),
                          onPressed: () => player.previous(),
                        ),
                        StreamBuilder<bool>(
                          stream: p.playingStream,
                          builder: (_, snap) => IconButton(
                            iconSize: 30,
                            padding: EdgeInsets.zero,
                            constraints: btnConstraints,
                            icon: Icon(
                              snap.data == true
                                  ? Icons.pause
                                  : Icons.play_arrow,
                            ),
                            onPressed: () => player.toggle(),
                          ),
                        ),
                        IconButton(
                          iconSize: 26,
                          padding: EdgeInsets.zero,
                          constraints: btnConstraints,
                          icon: const Icon(Icons.skip_next),
                          onPressed: () => player.next(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
