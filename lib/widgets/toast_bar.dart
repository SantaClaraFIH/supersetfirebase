import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/theme_provider.dart';
import '../config/app_theme.dart';

/// Toast kind types
enum ToastKind { success, info, warning, error }

/// Themed ToastBar component matching Math World design
class ToastBar extends StatefulWidget {
  final ToastKind kind;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback? onClose;
  final int autoCloseMs;

  const ToastBar({
    super.key,
    this.kind = ToastKind.success,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    this.onClose,
    this.autoCloseMs = 4000,
  });

  @override
  State<ToastBar> createState() => _ToastBarState();
}

class _ToastBarState extends State<ToastBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();

    // Auto close after specified duration
    if (widget.autoCloseMs > 0) {
      Future.delayed(Duration(milliseconds: widget.autoCloseMs), () {
        if (mounted) {
          _dismiss();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _dismiss() {
    _controller.reverse().then((_) {
      if (mounted && widget.onClose != null) {
        widget.onClose!();
      }
    });
  }

  Color _getIconColor() {
    switch (widget.kind) {
      case ToastKind.success:
        return Colors.green;
      case ToastKind.info:
        return const Color(0xFF9C88FF); // Violet
      case ToastKind.warning:
        return Colors.amber;
      case ToastKind.error:
        return Colors.red;
    }
  }

  IconData _getIcon() {
    switch (widget.kind) {
      case ToastKind.success:
        return Icons.check_circle_rounded;
      case ToastKind.info:
        return Icons.info_rounded;
      case ToastKind.warning:
        return Icons.warning_rounded;
      case ToastKind.error:
        return Icons.error_rounded;
    }
  }

  List<Color> _getIconGradient() {
    switch (widget.kind) {
      case ToastKind.success:
        return [Colors.green.shade400, Colors.green.shade600];
      case ToastKind.info:
        return [
          const Color(0xFF9C88FF),
          const Color(0xFF4DD0E1)
        ]; // Violet to Sky
      case ToastKind.warning:
        return [Colors.amber.shade400, Colors.amber.shade600];
      case ToastKind.error:
        return [Colors.red.shade400, Colors.red.shade600];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final colors =
            themeProvider.isDarkMode ? AppColors.dark : AppColors.light;

        return SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _opacityAnimation,
            child: Material(
              color: Colors.transparent,
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 768),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: themeProvider.isDarkMode
                              ? [
                                  Colors.white.withOpacity(0.10),
                                  Colors.white.withOpacity(0.05),
                                ]
                              : [
                                  Colors.white.withOpacity(0.12),
                                  Colors.white.withOpacity(0.06),
                                ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24), // rounded-3xl
                        border: Border.all(
                          color: Colors.white.withOpacity(0.15),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                            spreadRadius: 0,
                          ),
                          BoxShadow(
                            color: const Color(0xFF5078FF).withOpacity(0.20),
                            blurRadius: 40,
                            offset: const Offset(0, 0),
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Icon chip
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: _getIconGradient(),
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: _getIconColor().withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    _getIcon(),
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Content
                                Expanded(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.title,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: colors.primaryText,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (widget.message != null) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          widget.message!,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: colors.secondaryText,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                // Action buttons
                                if (widget.actionLabel != null ||
                                    widget.onClose != null) ...[
                                  const SizedBox(width: 12),
                                  if (widget.actionLabel != null) ...[
                                    // Primary action button
                                    Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            const Color(0xFF9C88FF),
                                            const Color(0xFF4DD0E1),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFF9C88FF)
                                                .withOpacity(0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          onTap: widget.onAction,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 8,
                                            ),
                                            child: Text(
                                              widget.actionLabel!,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                  ],
                                  // Dismiss button
                                  if (widget.onClose != null)
                                    IconButton(
                                      icon: const Icon(Icons.close_rounded),
                                      iconSize: 20,
                                      color: colors.secondaryText,
                                      onPressed: _dismiss,
                                      tooltip: 'Dismiss',
                                    ),
                                ],
                              ],
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
        );
      },
    );
  }
}

/// Helper function to show themed toast
void showToast({
  required BuildContext context,
  ToastKind kind = ToastKind.success,
  required String title,
  String? message,
  String? actionLabel,
  VoidCallback? onAction,
  int autoCloseMs = 4000,
}) {
  final overlay = Overlay.of(context);
  late OverlayEntry overlayEntry;

  overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: ToastBar(
          kind: kind,
          title: title,
          message: message,
          actionLabel: actionLabel,
          onAction: onAction,
          onClose: () {
            overlayEntry.remove();
          },
          autoCloseMs: autoCloseMs,
        ),
      ),
    ),
  );

  overlay.insert(overlayEntry);
}
