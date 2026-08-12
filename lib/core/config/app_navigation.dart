import 'package:flutter/material.dart';

/// Root [Navigator] key shared between [AppRouter]'s `GoRouter` and any code
/// that needs to reach the Navigator without a `BuildContext` (e.g. an
/// `AuthCubit` reacting to a background 401/token-expiry with no active
/// screen context of its own).
///
/// Used specifically to close any dialogs/bottom sheets still on screen
/// *before* the auth-driven redirect to `/login` runs. Without this, a
/// `showDialog` route (e.g. the New/Edit Subscription dialog) can be left as
/// an orphaned overlay when GoRouter swaps out the underlying page on
/// logout - its `BlocProvider.value`/`FormBuilder` `InheritedElement` may
/// then unmount while it still has live dependents, tripping
/// framework.dart's `_dependents.isEmpty` assertion. Popping the dialog
/// synchronously first lets Flutter tear it down through the normal
/// deactivate/unmount path before the page-level redirect happens.
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();
