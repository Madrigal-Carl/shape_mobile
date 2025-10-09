import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:popover/popover.dart';
import 'package:shape_mobile/services/auth_service.dart';
import 'package:toastification/toastification.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showReturn;

  const CustomAppBar({super.key, required this.title, this.showReturn = false});

  @override
  Widget build(BuildContext context) {
    final currentRoute = ModalRoute.of(context)?.settings.name;

    return GFAppBar(
      automaticallyImplyLeading: showReturn,
      leading: showReturn
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
      titleSpacing: showReturn ? 0 : NavigationToolbar.kMiddleSpacing,
      backgroundColor: Colors.white,
      elevation: 1,
      title: Text(
        title,
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
                  : () {
                      Navigator.pushNamed(context, '/notification');
                    },
              type: GFButtonType.transparent,
            ),
            const Positioned(
              top: 10,
              right: 2,
              child: GFBadge(
                shape: GFBadgeShape.circle,
                color: Colors.red,
                child: Text(
                  '3',
                  style: TextStyle(fontSize: 10, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 8),
        Builder(
          builder: (context) => GFIconButton(
            icon: const CircleAvatar(
              backgroundImage: AssetImage('assets/flutter/images/profile.png'),
            ),
            onPressed: () {
              showPopover(
                context: context,
                bodyBuilder: (context) => const ListItems(),
                direction: PopoverDirection.bottom,
                width: 200,
                height: 185,
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

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
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
                    Expanded(
                      child: GFButton(
                        onPressed: () async {
                          final authService = AuthService();

                          try {
                            await authService.logout().timeout(
                              const Duration(seconds: 5),
                              onTimeout: () {
                                toastification.showError(
                                  context: context,
                                  title:
                                      'Connection timed out. Please check your internet.',
                                  autoCloseDuration: const Duration(seconds: 5),
                                  padding: const EdgeInsets.all(10),
                                );
                                return;
                              },
                            );

                            toastification.showSuccess(
                              context: context,
                              title: 'Logged out successfully!',
                              autoCloseDuration: const Duration(seconds: 5),
                              padding: const EdgeInsets.all(10),
                            );

                            if (context.mounted) {
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                '/',
                                (route) => false,
                              );
                            }
                          } catch (e) {
                            toastification.showError(
                              context: context,
                              title:
                                  'Failed to logout. Please check your connection.',
                              autoCloseDuration: const Duration(seconds: 5),
                              padding: const EdgeInsets.all(10),
                            );
                          }
                        },
                        color: Colors.red,
                        text: "Continue",
                        textStyle: const TextStyle(color: Colors.white),
                        shape: GFButtonShape.pills,
                        size: GFSize.MEDIUM,
                      ),
                    ),
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
