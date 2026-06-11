import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';

class RouterNotFoundScreen extends StatelessWidget {
  const RouterNotFoundScreen({super.key, required this.uri});

  final String uri;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(Constants.routerNotFoundTitle)),
      body: Center(
        child: Text('${Constants.routerNotFoundMessagePrefix} $uri'),
      ),
    );
  }
}
