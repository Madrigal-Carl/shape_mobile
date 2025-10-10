import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';

class LoadingModal extends StatefulWidget {
  const LoadingModal({super.key, this.initialMessage = 'Please wait...'});
  final String initialMessage;

  @override
  LoadingModalState createState() => LoadingModalState();
}

class LoadingModalState extends State<LoadingModal> {
  String message = '';

  @override
  void initState() {
    super.initState();
    message = widget.initialMessage;
  }

  void updateMessage(String newMessage) {
    if (mounted) setState(() => message = newMessage);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: IntrinsicHeight(
        child: GFCard(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 16),
                const CircularProgressIndicator(),
                const SizedBox(height: 24),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
