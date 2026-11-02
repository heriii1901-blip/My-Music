import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:just_audio/just_audio.dart';
import '../models/song.dart';
import '../services/r2_service.dart';
import '../widgets/generated_cover.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final _titleCtrl = TextEditingController();
  final _coverKey = GlobalKey();

  PlatformFile? _file;
  String? _coverTitle; // judul yang dipakai pas tombol generate ditekan
  int _variant = 0;
  bool _saving = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  bool get _hasTitle => _titleCtrl.text.trim().isNotEmpty;
  bool get _canSave => _hasTitle && _file != null && !_saving;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3'],
    );
    if (result == null) return;
    final f = result.files.single;
    setState(() {
      _file = f;
      // Judul kosong -> isi otomatis dari nama file
      if (!_hasTitle) {
        _titleCtrl.text =
            f.name.replaceAll(RegExp(r'\.mp3$', caseSensitive: false), '');
      }
    });
  }

  void _generateCover() {
    setState(() {
      if (_coverTitle != null) _variant++;
      _coverTitle = _titleCtrl.text.trim();
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);

    Uint8List? coverBytes;
    if (_coverTitle != null) {
      final boundary =
          _coverKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary != null) {
        final image = await boundary.toImage(pixelRatio: 2);
        final data = await image.toByteData(format: ui.ImageByteFormat.png);
        coverBytes = data?.buffer.asUint8List();
      }
    }

    if (!mounted) return;

    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final title = _titleCtrl.text.trim();
    final addedAt = DateTime.now();

    try {
      // Baca durasi asli dari file mp3
      var durationMs = 0;
      final probe = AudioPlayer();
      try {
        final d = await probe.setFilePath(_file!.path!);
        durationMs = d?.inMilliseconds ?? 0;
      } catch (_) {}
      await probe.dispose();

      await R2Service().uploadSong(
        id: id,
        title: title,
        artist: 'Tidak diketahui',
        durationMs: durationMs,
        addedAt: addedAt,
        file: File(_file!.path!),
        cover: coverBytes,
      );

      if (!mounted) return;
      Navigator.pop(
        context,
        Song(
          id: id,
          title: title,
          artist: 'Tidak diketahui',
          durationMs: durationMs,
          r2Key: 'songs/$id.mp3',
          coverBytes: coverBytes,
          addedAt: addedAt,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Upload gagal: $e')));
    }
  }

  String _formatSize(int bytes) =>
      '${(bytes / 1048576).toStringAsFixed(1)} MB';

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Upload Lagu')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Judul
            TextField(
              controller: _titleCtrl,
              onChanged: (_) => setState(() {}),
              textCapitalization: TextCapitalization.words,
              style: const TextStyle(fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                labelText: 'Judul lagu',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 2. Kotak upload MP3 (putus-putus, jadi garis penuh kalau sudah dipilih)
            InkWell(
              onTap: _pickFile,
              borderRadius: BorderRadius.circular(16),
              child: CustomPaint(
                painter: _BorderPainter(
                  color: _file == null ? color.outline : Colors.greenAccent,
                  dashed: _file == null,
                ),
                child: SizedBox(
                  height: 180,
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _file == null
                          ? [
                              Icon(Icons.music_note_rounded,
                                  size: 52, color: color.outline),
                              const SizedBox(height: 8),
                              Text(
                                'Upload MP3',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: color.outline,
                                ),
                              ),
                            ]
                          : [
                              const Icon(Icons.check_circle,
                                  size: 52, color: Colors.greenAccent),
                              const SizedBox(height: 8),
                              Text(
                                _file!.name,
                                maxLines: 2,
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${_formatSize(_file!.size)} • ketuk buat ganti',
                                style: TextStyle(
                                    fontSize: 12, color: color.outline),
                              ),
                            ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 3. Cover
            const Text('Cover',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 260),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: _coverTitle == null
                        ? Container(
                            color: color.surfaceContainerHighest,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.image_outlined,
                                    size: 48, color: color.outline),
                                const SizedBox(height: 8),
                                Text('Belum ada cover',
                                    style: TextStyle(color: color.outline)),
                              ],
                            ),
                          )
                        : RepaintBoundary(
                            key: _coverKey,
                            child: GeneratedCover(
                              title: _coverTitle!,
                              variant: _variant,
                            ),
                          ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: FilledButton.tonalIcon(
                onPressed: _hasTitle ? _generateCover : null,
                icon: const Icon(Icons.auto_awesome),
                label: Text(
                    _coverTitle == null ? 'Generate cover' : 'Generate ulang'),
              ),
            ),
            const SizedBox(height: 32),

            // Simpan
            FilledButton(
              onPressed: _canSave ? _save : null,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      'Simpan',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Gambar border kotak: putus-putus (dashed) atau garis penuh.
class _BorderPainter extends CustomPainter {
  final Color color;
  final bool dashed;

  _BorderPainter({required this.color, required this.dashed});

  @override
  void paint(Canvas canvas, Size size) {
    const sw = 2.0;
    const dash = 8.0;
    const gap = 6.0;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = sw;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(sw / 2, sw / 2, size.width - sw, size.height - sw),
        const Radius.circular(16),
      ));

    if (!dashed) {
      canvas.drawPath(path, paint);
      return;
    }

    for (final metric in path.computeMetrics()) {
      var d = 0.0;
      while (d < metric.length) {
        canvas.drawPath(
          metric.extractPath(d, min(d + dash, metric.length)),
          paint,
        );
        d += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(_BorderPainter old) =>
      old.color != color || old.dashed != dashed;
}
