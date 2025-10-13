import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:shape_mobile/db/app_database.dart';
import 'package:shape_mobile/models/FeedModel.dart';
import 'package:shape_mobile/utils.dart';

class NotificationCollectionWidget extends StatefulWidget {
  const NotificationCollectionWidget({super.key});

  @override
  State<NotificationCollectionWidget> createState() =>
      _NotificationCollectionWidgetState();
}

class _NotificationCollectionWidgetState
    extends State<NotificationCollectionWidget> {
  List<Feed> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final db = await AppDatabase.instance.database;

    // Fetch and sort by created_at DESC
    final result = await db.query(
      AppDatabase.feedsTable,
      orderBy: "datetime(created_at) DESC",
    );

    // await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    await _markAllAsRead();

    setState(() {
      _notifications = result.map((e) => Feed.fromJson(e)).toList();
      _isLoading = false;
    });
  }

  Future<void> _markAllAsRead() async {
    final db = await AppDatabase.instance.database;
    await db.update(AppDatabase.feedsTable, {
      'is_read': 1,
    }, where: 'is_read = 0');
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return SizedBox.expand(
        child: Align(
          alignment: const Alignment(0, -0.4),
          child: const CircularProgressIndicator(),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        // Empty state
        if (_notifications.isEmpty)
          SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 200),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.notifications_off, size: 100, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    "No Notifications Available",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 18),
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final notif = _notifications[index];
                return GFListTile(
                  radius: 28,
                  color: const Color(0xFFEAF7F9),
                  shadow: const BoxShadow(
                    color: Colors.black12,
                    offset: Offset(4, 4),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                  title: Text(
                    toTitleCase(notif.title),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  subTitle: Text(
                    notif.message,
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
