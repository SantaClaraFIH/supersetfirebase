import 'dart:math';

import 'package:flutter/material.dart';

import 'models.dart';

class CashierRegisterPanel extends StatelessWidget {
  const CashierRegisterPanel({
    super.key,
    required this.registerLabel,
    required this.drawerClosedLabel,
    required this.customerTrayLabel,
    required this.trayTotalText,
    required this.changeTextScale,
    required this.changeTextShakeX,
    required this.drawerRectForSize,
    required this.trayRectForSize,
    required this.drawerOpen,
    required this.showTokens,
    required this.registerTokens,
    required this.buildToken,
    required this.drawerScrollOffset,
    required this.drawerScrollMaxExtent,
    required this.onScrollDrawerBy,
    required this.onDrawerScrollSet,
    required this.onSizeChanged,
  });

  final String registerLabel;
  final String drawerClosedLabel;
  final String customerTrayLabel;
  final String trayTotalText;
  final double changeTextScale;
  final double changeTextShakeX;
  final Rect Function(Size size) drawerRectForSize;
  final Rect Function(Size size) trayRectForSize;
  final bool drawerOpen;
  final bool showTokens;
  final List<MoneyToken> registerTokens;
  final Widget Function(MoneyToken token) buildToken;
  final double drawerScrollOffset;
  final double Function() drawerScrollMaxExtent;
  final void Function(double delta) onScrollDrawerBy;
  final void Function(double offset) onDrawerScrollSet;
  final void Function(Size size) onSizeChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        onSizeChanged(size);

        final drawerRect = drawerRectForSize(size);
        final trayRect = trayRectForSize(size);
        final bool compactLayout = size.height < 420 || size.width < 380;
        final double machineTop = compactLayout ? 50 : 44;
        final double machineHeight = compactLayout ? 100 : 112;
        final double miniDisplayWidth = compactLayout ? 96 : 112;
        final double miniDisplayHeight = compactLayout ? 52 : 60;
        final double miniDisplayRight = compactLayout ? 12 : 16;
        final double miniDisplayTop = compactLayout ? 4 : 2;
        final double longDisplayLeft = compactLayout ? 84 : 94;
        final double longDisplayRight =
          miniDisplayRight + miniDisplayWidth + (compactLayout ? 10 : 14);
        final double longDisplayTop = compactLayout ? 12 : 10;
        final double longDisplayHeight = compactLayout ? 20 : 22;
        const double drawerTokenSize = 34;
        const double drawerColGap = 5;
        const double drawerRowGap = 5;
        const double drawerContentLeftInset = 10;
        const double drawerContentTopInset = 10;
        final double drawerContentWidth = max(24.0, drawerRect.width - 40);
        final double drawerContentHeight = max(22.0, drawerRect.height - 40);
        final int drawerColumns = max(
          2,
          ((drawerContentWidth + drawerColGap) / (drawerTokenSize + drawerColGap))
              .floor(),
        );
        final double drawerStepX = drawerColumns <= 1
          ? 0
          : (drawerContentWidth - drawerTokenSize) / (drawerColumns - 1);
        final int drawerTokenCount =
          registerTokens.where((token) => !token.inTray).length;
        final int drawerSocketCount = max(20, drawerTokenCount + 5);
        final double trayLabelTop =
          min(size.height - 30, trayRect.bottom + (compactLayout ? 6 : 8));
        final double trayLabelLeft =
          (trayRect.left + (trayRect.width / 2)).clamp(60.0, size.width - 60.0);
        final bool showFlowArrows = !compactLayout;
        final double flowArrowLeft = ((drawerRect.right + trayRect.left) / 2) - 12;
        final double flowCenterY =
          ((drawerRect.top + drawerRect.bottom) + (trayRect.top + trayRect.bottom)) / 4;
        final double flowArrowTop = max(24.0, flowCenterY - 38);

        return Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFF0DFC2), Color(0xFFE1BE88)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.brown.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.14),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            fit: StackFit.expand,
            clipBehavior: Clip.hardEdge,
            children: [
              Positioned(
                left: 10,
                right: 10,
                top: 32,
                bottom: 18,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFC7A06D), Color(0xFF9A744A)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.black.withValues(alpha: 0.22)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: 8,
                child: Text(
                  registerLabel,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
              ),
              Positioned(
                left: 14,
                top: machineTop,
                right: 14,
                child: Container(
                  height: machineHeight,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE6E8EB), Color(0xFFCBCFD5)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black26),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: miniDisplayRight,
                        top: miniDisplayTop,
                        child: Column(
                          children: [
                            Container(
                              width: miniDisplayWidth,
                              height: miniDisplayHeight,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFC4D5EA), Color(0xFFA9C0DB)],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.black38),
                              ),
                            ),
                            Container(
                              width: 8,
                              height: compactLayout ? 12 : 14,
                              color: Colors.black54,
                            )
                          ],
                        ),
                      ),
                      Positioned(
                        left: 10,
                        top: 8,
                        child: Container(
                          width: 66,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.black26),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            'Receipt',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                      Positioned(
                        left: longDisplayLeft,
                        right: longDisplayRight,
                        top: longDisplayTop,
                        child: Container(
                          height: longDisplayHeight,
                          decoration: BoxDecoration(
                            color: const Color(0xFF86B9DF),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.black26),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 12,
                        right: 12,
                        bottom: 8,
                        child: Wrap(
                          spacing: 5,
                          runSpacing: 5,
                          children: List.generate(
                            12,
                            (index) => Container(
                              width: 22,
                              height: 12,
                              decoration: BoxDecoration(
                                color: index == 10
                                    ? const Color(0xFFE57373)
                                    : const Color(0xFFFDFDFD),
                                borderRadius: BorderRadius.circular(3),
                                border: Border.all(color: Colors.black26),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: miniDisplayRight,
                        top: miniDisplayTop,
                        child: IgnorePointer(
                          child: SizedBox(
                            width: miniDisplayWidth,
                            height: miniDisplayHeight,
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 6),
                                child: Transform.translate(
                                  offset: Offset(changeTextShakeX, 0),
                                  child: Transform.scale(
                                    scale: changeTextScale,
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      alignment: Alignment.center,
                                      child: Text(
                                        trayTotalText,
                                        maxLines: 1,
                                        style: TextStyle(
                                          fontSize: compactLayout ? 14 : 16,
                                          fontWeight: FontWeight.w900,
                                          color: const Color(0xFF1E2430),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 20,
                right: 20,
                top: drawerRect.top - 22,
                child: Container(
                  height: 16,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7A5A39), Color(0xFF63492E)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.18),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: drawerRect.left,
                top: drawerRect.top,
                child: Container(
                  width: drawerRect.width,
                  height: drawerRect.height,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: drawerOpen
                          ? [const Color(0xFF2E3138), const Color(0xFF202329)]
                          : [const Color(0xFF5D616C), const Color(0xFF494D56)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black.withValues(alpha: 0.25)),
                  ),
                  child: Stack(
                    children: [
                      if (drawerOpen)
                        Positioned.fill(
                          child: Stack(
                            clipBehavior: Clip.hardEdge,
                            children: List.generate(drawerSocketCount, (index) {
                              final int col = index % drawerColumns;
                              final int row = index ~/ drawerColumns;
                              final double x =
                                  drawerContentLeftInset + (col * drawerStepX);
                              final double y = drawerContentTopInset +
                                  (row * (drawerTokenSize + drawerRowGap)) -
                                  drawerScrollOffset;

                              final bool hidden =
                                  y < drawerContentTopInset ||
                                      y + drawerTokenSize >
                                          drawerContentTopInset + drawerContentHeight;
                              if (hidden) {
                                return const SizedBox.shrink();
                              }

                              return Positioned(
                                left: x,
                                top: y,
                                child: Container(
                                  width: drawerTokenSize,
                                  height: drawerTokenSize,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF343843),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.black.withValues(alpha: 0.40),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        )
                      else
                        Center(
                          child: Text(
                            drawerClosedLabel,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      Positioned(
                        left: 10,
                        right: 10,
                        bottom: 8,
                        child: Container(
                          height: 22,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFC7985E), Color(0xFFAF7E49)],
                            ),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.black26),
                          ),
                          child: Center(
                            child: Container(
                              width: 38,
                              height: 8,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE6E6E6),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.black26),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: trayRect.left,
                top: trayRect.top,
                child: Container(
                  width: trayRect.width,
                  height: trayRect.height,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFF9F1E3),
                        Color(0xFFE4CCAA),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF5E3EA1), width: 2.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: trayLabelLeft - 58,
                top: trayLabelTop,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.86),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    customerTrayLabel,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              if (showFlowArrows)
                Positioned(
                  left: flowArrowLeft,
                  top: flowArrowTop,
                  child: Column(
                    children: const [
                      Icon(Icons.arrow_forward, color: Colors.deepPurple, size: 24),
                      SizedBox(height: 2),
                      Icon(Icons.arrow_forward, color: Colors.deepPurple, size: 24),
                      SizedBox(height: 2),
                      Icon(Icons.arrow_forward, color: Colors.deepPurple, size: 24),
                    ],
                  ),
                ),
              if (showTokens) ...registerTokens.map(buildToken),
              if (drawerOpen)
                Positioned(
                  left: drawerRect.right - 24,
                  top: drawerRect.top + 6,
                  child: Container(
                    width: 18,
                    height: drawerRect.height - 12,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.24),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () => onScrollDrawerBy(-44),
                          child: const Icon(
                            Icons.keyboard_arrow_up,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        Expanded(
                          child: Builder(
                            builder: (context) {
                              final double maxExtent = drawerScrollMaxExtent();
                              const double minThumb = 26;
                              final double trackHeight = drawerRect.height - 52;
                              final double thumbHeight = max(minThumb, trackHeight * 0.30);
                              final double progress =
                                  maxExtent == 0 ? 0 : (drawerScrollOffset / maxExtent);
                              final double thumbTop =
                                  (trackHeight - thumbHeight) * progress;

                              return GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onVerticalDragUpdate: (details) {
                                  if (maxExtent <= 0) {
                                    return;
                                  }
                                  final delta = details.delta.dy * (maxExtent / trackHeight);
                                  onScrollDrawerBy(delta);
                                },
                                onTapDown: (details) {
                                  if (maxExtent <= 0) {
                                    return;
                                  }
                                  final double y =
                                      details.localPosition.dy.clamp(0.0, trackHeight);
                                  final double available = max(1.0, trackHeight - thumbHeight);
                                  final double target =
                                      (y - (thumbHeight / 2)).clamp(0.0, available);
                                  onDrawerScrollSet((target / available) * maxExtent);
                                },
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.18),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Stack(
                                    children: [
                                      Positioned(
                                        top: thumbTop,
                                        left: 0,
                                        right: 0,
                                        child: Container(
                                          height: thumbHeight,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        GestureDetector(
                          onTap: () => onScrollDrawerBy(44),
                          child: const Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
