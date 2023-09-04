import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

const String kExamplePage = '''
<!DOCTYPE html>
<html lang="en">
<head>
<title>Load file or HTML string example</title>
</head>
<body>

<h1>Local demo page</h1>
<p>
 This is an example page used to demonstrate how to load a local file or HTML
 string using the <a href="https://pub.dev/packages/webview_flutter">Flutter
 webview</a> plugin.
</p>

</body>
</html>
''';

enum _MenuOptions {
  navigationDelegate,
  userAgent,
  javascriptChannel,
  listCookies,
  clearCookies,
  addCookie,
  setCookie,
  removeCookie,
  loadFlutterAsset,
  loadLocalFile,
  loadHtmlString,
}

class Menu extends StatelessWidget {
  Menu({super.key, required this.controller});
  final WebViewController controller;
  late final WebViewCookieManager cookieManager = WebViewCookieManager();

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (BuildContext context) {
        return PopupMenuButton<_MenuOptions>(
          key: const ValueKey<String>('Menu'),
          onSelected: (_MenuOptions value) async {
            switch (value) {
              case _MenuOptions.navigationDelegate:
                controller.loadRequest(Uri.parse('https://youtube.com'));
                break;
              case _MenuOptions.userAgent:
                final userAgent = await controller
                    .runJavaScriptReturningResult('navigator.userAgent');
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(userAgent.toString()),
                ));
                break;
              case _MenuOptions.javascriptChannel:
                await controller.runJavaScript('''
var req = new XMLHttpRequest();
req.open('GET', "https://api.ipify.org/?format=json");
req.onload = function() {
  if (req.status == 200) {
    let response = JSON.parse(req.responseText);
    SnackBar.postMessage("IP Address: " + response.ip);
  } else {
    SnackBar.postMessage("Error: " + req.status);
  }
}
req.send();
                ''');
                break;
              case _MenuOptions.listCookies:
                if (!context.mounted) return;
                _onListCookies(context);
                break;
              case _MenuOptions.clearCookies:
                if (!context.mounted) return;
                _onClearCookies(context);
                break;
              case _MenuOptions.addCookie:
                if (!context.mounted) return;
                _onAddCookie(context);
                break;
              case _MenuOptions.setCookie:
                if (!context.mounted) return;
                _onSetCookie(context);
                break;
              case _MenuOptions.removeCookie:
                if (!context.mounted) return;
                _onRemoveCookie(context);
                break;
              case _MenuOptions.loadFlutterAsset:
                if (!context.mounted) return;
                _onLoadFlutterAssetExample(context);
                break;
              case _MenuOptions.loadLocalFile:
                if (!context.mounted) return;
                _onLoadLocalFileExample(context);
                break;
              case _MenuOptions.loadHtmlString:
                if (!context.mounted) return;
                _onLoadHtmlStringExample(context);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem<_MenuOptions>(
              value: _MenuOptions.navigationDelegate,
              child: Text('Navigate to Youtube'),
            ),
            const PopupMenuItem<_MenuOptions>(
              value: _MenuOptions.userAgent,
              child: Text('Show user-agent'),
            ),
            const PopupMenuItem<_MenuOptions>(
              value: _MenuOptions.javascriptChannel,
              child: Text('Lookup IP Address'),
            ),
            const PopupMenuItem<_MenuOptions>(
              value: _MenuOptions.listCookies,
              child: Text('List cookies'),
            ),
            const PopupMenuItem<_MenuOptions>(
              value: _MenuOptions.clearCookies,
              child: Text('Clear cookies'),
            ),
            const PopupMenuItem<_MenuOptions>(
              value: _MenuOptions.addCookie,
              child: Text('Add cookie'),
            ),
            const PopupMenuItem<_MenuOptions>(
              value: _MenuOptions.setCookie,
              child: Text('Set cookie'),
            ),
            const PopupMenuItem<_MenuOptions>(
              value: _MenuOptions.removeCookie,
              child: Text('Remove cookie'),
            ),
            const PopupMenuItem<_MenuOptions>(
              value: _MenuOptions.loadFlutterAsset,
              child: Text('Load Flutter asset'),
            ),
            const PopupMenuItem<_MenuOptions>(
              value: _MenuOptions.loadLocalFile,
              child: Text('Load local file'),
            ),
            const PopupMenuItem<_MenuOptions>(
              value: _MenuOptions.loadHtmlString,
              child: Text('Load HTML string'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _onListCookies(BuildContext context) async {
    final String cookies =
        (await controller.runJavaScriptReturningResult('document.cookie'))
            .toString();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(cookies.isNotEmpty ? cookies : 'There are no cookies.'),
      ),
    );
  }

  Future<void> _onClearCookies(BuildContext context) async {
    final hadCookies = await cookieManager.clearCookies();
    String message = 'There were cookies. Now, they are gone!';
    if (!hadCookies) {
      message = 'There are no cookies to clear.';
    }
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  Future<void> _onAddCookie(BuildContext context) async {
    await controller.runJavaScript('''var date = new Date();
    date.setTime(date.getTime()+(30*24*60*60*1000));
    document.cookie = "FirstName=John; expires=" + date.toGMTString();''');
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Custom Cookie added.'),
      ),
    );
  }

  Future<void> _onSetCookie(BuildContext context) async {
    await cookieManager.setCookie(
      const WebViewCookie(name: 'foo', value: 'bar', domain: 'flutter.dev'),
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Custom cookie is set.'),
      ),
    );
  }

  Future<void> _onRemoveCookie(BuildContext context) async {
    await controller.runJavaScript(
        'document.cookie="FirstName=John; expires=Thu, 01 Jan 1970 00:00:00 UTC"');
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Custom cookie removed.'),
      ),
    );
  }

  Future<void> _onLoadFlutterAssetExample(BuildContext context) async {
    await controller.loadFlutterAsset('assets/www/index.html');
  }

  Future<void> _onLoadLocalFileExample(BuildContext context) async {
    final String pathToIndex = await _prepareLocalFile();
    await controller.loadFile(pathToIndex);
  }

  static Future<String> _prepareLocalFile() async {
    final String tmpDir = (await getTemporaryDirectory()).path;
    final File indexFile = File('$tmpDir/www/index.html');
    await Directory('$tmpDir/www').create(recursive: true);
    await indexFile.writeAsString(kExamplePage);
    return indexFile.path;
  }

  Future<void> _onLoadHtmlStringExample(BuildContext context) async {
    await controller.loadHtmlString(kExamplePage);
  }
}
