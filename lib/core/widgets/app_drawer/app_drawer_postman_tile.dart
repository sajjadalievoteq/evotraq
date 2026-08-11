import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/widgets/app_drawer/app_drawer_navigation_icon.dart';
import 'package:traqtrace_app/core/widgets/postman_collection_dialog.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';

class AppDrawerPostmanTile extends StatelessWidget {
  const AppDrawerPostmanTile({super.key, required this.isAdmin});

  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: AppDrawerNavigationIcon(NavIcons.postmanCollection),
      title: const Text('Postman Collection'),
      subtitle: Text(
        isAdmin
            ? 'Download or update the API collection'
            : 'Download the API collection',
        style: const TextStyle(fontSize: 11),
      ),
      trailing: isAdmin
          ? Tooltip(
              message: 'Admin: download or upload',
              child: TraqIcon(
                NavIcons.security,
                size: 16,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
              ),
            )
          : null,
      onTap: () => PostmanCollectionDialog.show(context, isAdmin: isAdmin),
    );
  }
}
