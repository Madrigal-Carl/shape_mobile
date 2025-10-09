import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';

class NotificationCollectionWidget extends StatelessWidget {
  final List<Map<String, dynamic>> notifs;
  const NotificationCollectionWidget({
    super.key,
    required this.notifs,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(
        vertical: 18,
      ),
      itemCount: notifs.length,
      itemBuilder: (context, index) {
        final notif = notifs[index];
        return GFListTile(
          radius: 28,
          color: Color(0xFFEAF7F9),
          shadow: BoxShadow(
            color: Colors.black12,
            offset: Offset(4, 4),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 14,
          ),
          titleText: notif['title'],
          subTitleText: notif['subtitle'],
        );
      },
    );
  }
}
