import 'dart:io';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:popover/popover.dart';
import 'package:shape_mobile/services/api_service.dart';
import 'package:toastification/toastification.dart';
import 'package:shape_mobile/services/preference_service.dart';
import 'package:shape_mobile/db/app_database.dart';
import 'package:shape_mobile/services/loading_modal.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final bool showReturn;

  const CustomAppBar({super.key, required this.title, this.showReturn = false});

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _CustomAppBarState extends State<CustomAppBar> {
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUnreadCount();
  }

  Future<void> _loadUnreadCount() async {
    final count = await AppDatabase.instance.getUnreadNotificationCount();
    if (!mounted) return;
    setState(() => _unreadCount = count);
  }

  @override
  Widget build(BuildContext context) {
    final currentRoute = ModalRoute.of(context)?.settings.name;
    final String? avatarPath = PreferenceService.avatarPath;
    final ImageProvider profileImage;

    // ✅ Prefer local file image if available
    if (avatarPath != null && File(avatarPath).existsSync()) {
      profileImage = FileImage(File(avatarPath));
    } else {
      profileImage = const AssetImage('assets/flutter/images/profile.png');
    }

    return GFAppBar(
      automaticallyImplyLeading: widget.showReturn,
      leading: widget.showReturn
          ? IconButton(
              icon: Icon(Icons.arrow_back),
              color: Colors.black,
              iconSize: 32,
              onPressed: currentRoute == '/lessonSession'
                  ? () {
                      Navigator.pop(context);
                    }
                  : () {
                      Navigator.pushNamed(context, '/home');
                    },
            )
          : null,
      titleSpacing: widget.showReturn ? 0 : NavigationToolbar.kMiddleSpacing,
      backgroundColor: Colors.white,
      elevation: 1,
      title: Text(
        widget.title,
        style: const TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: <Widget>[
        Stack(
          alignment: Alignment.center,
          children: [
            GFIconButton(
              icon: const Icon(
                Icons.notifications_rounded,
                size: 30,
                color: Colors.black87,
              ),
              onPressed: currentRoute == '/notification'
                  ? null
                  : () async {
                      Navigator.pushNamed(
                        context,
                        '/notification',
                      ).then((_) => _loadUnreadCount());
                    },
              type: GFButtonType.transparent,
            ),
            if (_unreadCount > 0)
              Positioned(
                top: 10,
                right: 2,
                child: GFBadge(
                  shape: GFBadgeShape.circle,
                  color: Colors.red,
                  child: Text(
                    '$_unreadCount',
                    style: const TextStyle(fontSize: 10, color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 8),
        Builder(
          builder: (context) => GFIconButton(
            icon: CircleAvatar(backgroundImage: profileImage),
            onPressed: () {
              showPopover(
                context: context,
                bodyBuilder: (context) => const ListItems(),
                direction: PopoverDirection.bottom,
                width: 200,
                height: 235,
                arrowWidth: 16,
                arrowHeight: 10,
              );
            },
            type: GFButtonType.transparent,
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}

class ListItems extends StatelessWidget {
  const ListItems({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(8),
      children: [
        ListTile(
          leading: const Icon(Icons.person),
          title: const Text('Profile'),
          onTap: () => Navigator.pushNamed(context, '/profile'),
        ),
        ListTile(
          leading: const Icon(Icons.settings),
          title: const Text('Settings'),
          onTap: () => Navigator.pop(context),
        ),
        ListTile(
          leading: const Icon(Icons.autorenew_sharp),
          title: const Text('Update'),
          onTap: () async {
            FocusScope.of(context).unfocus();

            final modalKey = GlobalKey<LoadingModalState>();
            final authService = AuthService();

            // ✅ Attach modal to root navigator
            showDialog(
              context: Navigator.of(context, rootNavigator: true).context,
              barrierDismissible: false,
              builder: (_) => LoadingModal(
                key: modalKey,
                initialMessage: "Preparing to sync...",
              ),
            );

            // Wait for modal mount
            await Future.delayed(const Duration(milliseconds: 300));

            try {
              final success = await authService
                  .fetchAndSyncStudentData(
                    onProgress: (msg) {
                      modalKey.currentState?.updateMessage(msg);
                    },
                  )
                  .timeout(const Duration(seconds: 60), onTimeout: () => false);
              // ✅ Close modal from root navigator
              Navigator.pop(context);

              if (success) {
                toastification.showSuccess(
                  context: context,
                  title: 'Activities synced successfully!',
                  autoCloseDuration: const Duration(seconds: 5),
                  padding: const EdgeInsets.all(10),
                );
                Navigator.pop(context);
              } else {
                toastification.showError(
                  context: context,
                  title: 'Sync timed out. Please check your connection.',
                  autoCloseDuration: const Duration(seconds: 5),
                  padding: const EdgeInsets.all(10),
                );
                Navigator.pop(context);
              }
            } on ApiException catch (e) {
              if (context.mounted) {
                Navigator.of(context, rootNavigator: true).pop();
              }
              if (context.mounted) {
                toastification.showError(
                  context: context,
                  title: e.message == "connection_timeout"
                      ? 'Connection timed out. Please check your internet.'
                      : e.message,
                  autoCloseDuration: const Duration(seconds: 5),
                  padding: const EdgeInsets.all(10),
                );
                Navigator.pop(context);
              }
            } catch (e) {
              if (context.mounted) {
                Navigator.of(context, rootNavigator: true).pop();
              }
              if (context.mounted) {
                toastification.showError(
                  context: context,
                  title: e.toString(),
                  autoCloseDuration: const Duration(seconds: 5),
                  padding: const EdgeInsets.all(10),
                );
                Navigator.pop(context);
              }
            }
          },
        ),
        ListTile(
          leading: const Icon(Icons.logout),
          title: const Text('Logout'),
          onTap: () {
            Navigator.pop(context);
            showConfirmation(context);
          },
        ),
      ],
    );
  }
}

void showConfirmation(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.transparent,
        child: IntrinsicHeight(
          child: GFCard(
            padding: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: Colors.white,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 24,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.warning_rounded,
                      size: 100,
                      color: Colors.redAccent,
                    ),
                    const Text(
                      'Log out now?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: GFButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        color: Colors.grey,
                        text: "Cancel",
                        textStyle: const TextStyle(color: Colors.white),
                        shape: GFButtonShape.pills,
                        size: GFSize.MEDIUM,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: LogoutButton()),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

Future<void> handleLogout(BuildContext context) async {
  final authService = AuthService();

  final success = await authService.logout();

  if (!success) {
    toastification.showError(
      context: context,
      title: 'Failed to logout. Please check your connection.',
      autoCloseDuration: const Duration(seconds: 5),
      padding: const EdgeInsets.all(10),
    );
    Navigator.pop(context);
    return;
  }

  toastification.showSuccess(
    context: context,
    title: 'Logged out successfully!',
    autoCloseDuration: const Duration(seconds: 5),
    padding: const EdgeInsets.all(10),
  );

  if (context.mounted) {
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }
}

class LogoutButton extends StatefulWidget {
  @override
  _LogoutButtonState createState() => _LogoutButtonState();
}

class _LogoutButtonState extends State<LogoutButton> {
  bool isLoggingOut = false;

  @override
  Widget build(BuildContext context) {
    return GFButton(
      onPressed: isLoggingOut
          ? null
          : () async {
              setState(() => isLoggingOut = true);
              await handleLogout(context);
            },
      color: Colors.red,
      shape: GFButtonShape.pills,
      size: GFSize.MEDIUM,
      child: isLoggingOut
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Text("Continue", style: TextStyle(color: Colors.white)),
    );
  }
}
