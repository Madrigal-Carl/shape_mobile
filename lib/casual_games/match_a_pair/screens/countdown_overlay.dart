import 'package:flutter/material.dart';

class CountdownOverlay extends StatefulWidget {
  final VoidCallback onFinish;
  const CountdownOverlay({required this.onFinish, Key? key}) : super(key: key);

  @override
  State<CountdownOverlay> createState() => _CountdownOverlayState();
}

class _CountdownOverlayState extends State<CountdownOverlay> {
  int _count = 3;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() async {
    for (int i = 3; i > 0; i--) {
      setState(() => _count = i);
      await Future.delayed(const Duration(seconds: 1));
    }
    setState(() => _count = 0);
    await Future.delayed(const Duration(milliseconds: 500));
    widget.onFinish();
  }

  @override
  Widget build(BuildContext context) {
    String text = _count > 0 ? '$_count' : 'Start!';
    return Container(
      color: Colors.black54,
      child: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: Text(
            text,
            key: ValueKey(text),
            style: const TextStyle(
              fontFamily: 'DynaPuff',
              fontSize: 80,
              color: Colors.white,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  blurRadius: 8,
                  color: Colors.black,
                  offset: Offset(2, 4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
