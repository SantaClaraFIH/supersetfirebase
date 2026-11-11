import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'fractions_config.dart';

class FractionsGameView extends StatefulWidget {
  const FractionsGameView({super.key});

  @override
  State<FractionsGameView> createState() => _FractionsGameViewState();
}

class _FractionsGameViewState extends State<FractionsGameView> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFFFFFFFA))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() {
            _isLoading = true;
            _errorMessage = null;
          }),
          onPageFinished: (_) => setState(() => _isLoading = false),
          onWebResourceError: (error) => setState(() {
            _isLoading = false;
            _errorMessage = error.description;
          }),
        ),
      )
      ..loadRequest(Uri.parse(fractionsAppUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: WebViewWidget(controller: _controller)),
        if (_isLoading) const Center(child: CircularProgressIndicator()),
        if (_errorMessage != null)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.wifi_off_rounded,
                      size: 48, color: Colors.grey),
                  const SizedBox(height: 12),
                  const Text(
                    "Couldn't load Fractions.\nCheck your connection and try again.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _controller.reload(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
