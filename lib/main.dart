import 'package:flutter/material.dart';
import 'package:innap_webview_study/app/my_app.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

// final keepAlive = InAppWebViewKeepAlive();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await InAppWebViewController.setWebContentsDebuggingEnabled(false);

  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MyApp(),
  ));
}
