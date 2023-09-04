import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewStack extends StatefulWidget {
  const WebViewStack(
      {required this.controller, required this.loadingPercentage, super.key});
  final WebViewController controller;
  final int loadingPercentage;

  @override
  State<WebViewStack> createState() => _WebViewStackState();
}

class _WebViewStackState extends State<WebViewStack> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        WebViewWidget(controller: widget.controller),
        if (widget.loadingPercentage < 100)
          LinearProgressIndicator(
            value: widget.loadingPercentage / 100.0,
          ),
      ],
    );
  }
}
