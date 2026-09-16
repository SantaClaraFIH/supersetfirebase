import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

import 'fractions_config.dart';

const String _viewType = 'bilingual-fractions-iframe';

bool _registered = false;

void _registerIframeFactory() {
  if (_registered) return;
  ui_web.platformViewRegistry.registerViewFactory(_viewType, (int viewId) {
    final iframe = web.HTMLIFrameElement()
      ..src = fractionsAppUrl
      ..allow = 'microphone *; autoplay *'
      ..setAttribute('allowfullscreen', 'true');
    iframe.style
      ..border = 'none'
      ..width = '100%'
      ..height = '100%';
    return iframe;
  });
  _registered = true;
}

class FractionsGameView extends StatefulWidget {
  const FractionsGameView({super.key});

  @override
  State<FractionsGameView> createState() => _FractionsGameViewState();
}

class _FractionsGameViewState extends State<FractionsGameView> {
  @override
  void initState() {
    super.initState();
    _registerIframeFactory();
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.expand(
      child: HtmlElementView(viewType: _viewType),
    );
  }
}
