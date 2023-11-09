import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewURL extends StatefulWidget {
  const WebViewURL({
    Key? key,
    this.url,
  }) : super(key: key);
  final String? url;

  @override
  _WebViewURLState createState() => _WebViewURLState();
}

class _WebViewURLState extends State<WebViewURL> {
  @override
  Widget build(BuildContext context) {
    return WebView(
      initialUrl: widget.url,
      javascriptMode: JavascriptMode.unrestricted,
      userAgent: "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3",
    );
  }
}