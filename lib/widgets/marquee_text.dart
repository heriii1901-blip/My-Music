import 'package:flutter/material.dart';

class MarqueeText extends StatefulWidget {
  final String text;
  final TextStyle? style;

  const MarqueeText({super.key, required this.text, this.style});

  @override
  State<MarqueeText> createState() => _MarqueeTextState();
}

class _MarqueeTextState extends State<MarqueeText> {
  final _scroll = ScrollController();
  double _opacity = 1;
  int _token = 0; // dipakai buat ngebatalin loop lama

  @override
  void initState() {
    super.initState();
    _loop();
  }

  @override
  void didUpdateWidget(MarqueeText old) {
    super.didUpdateWidget(old);
    if (old.text != widget.text) {
      if (_scroll.hasClients) _scroll.jumpTo(0);
      _opacity = 1;
      _loop(); // loop lama berhenti sendiri karena token berubah
    }
  }

  @override
  void dispose() {
    _token++;
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _loop() async {
    final myToken = ++_token;
    bool alive() => mounted && myToken == _token;
    Future<void> wait(int ms) => Future.delayed(Duration(milliseconds: ms));

    await wait(1000);
    while (alive()) {
      if (!_scroll.hasClients || _scroll.position.maxScrollExtent <= 0) {
        await wait(1000); // judul muat, gak perlu gerak
        continue;
      }
      final max = _scroll.position.maxScrollExtent;

      // Jalan ke kiri sampai ujung judul kelihatan (kecepatan ~40 px/detik)
      await _scroll.animateTo(
        max,
        duration: Duration(milliseconds: (max / 40 * 1000).round()),
        curve: Curves.linear,
      );
      if (!alive()) return;
      await wait(800);
      if (!alive()) return;

      // Kedip, lalu balik ke awal
      setState(() => _opacity = 0);
      await wait(300);
      if (!alive()) return;
      _scroll.jumpTo(0);
      setState(() => _opacity = 1);
      await wait(1000);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _opacity,
      duration: const Duration(milliseconds: 250),
      child: SingleChildScrollView(
        controller: _scroll,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        child: Text(
          widget.text,
          maxLines: 1,
          softWrap: false,
          style: widget.style,
        ),
      ),
    );
  }
}
