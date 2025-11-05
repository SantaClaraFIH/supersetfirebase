import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/theme_provider.dart';
import '../config/app_theme.dart';

/// Themed ConfirmDialog component matching Math World design
class ConfirmDialog extends StatefulWidget {
  final bool open;
  final String title;
  final String? description;
  final String confirmLabel;
  final String cancelLabel;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const ConfirmDialog({
    super.key,
    required this.open,
    required this.title,
    this.description,
    this.confirmLabel = 'Confirm',
    this.cancelLabel = 'Cancel',
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  State<ConfirmDialog> createState() => _ConfirmDialogState();
}

class _ConfirmDialogState extends State<ConfirmDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 220),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.96,
      end: 1.0,
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

    // Start animation when widget is first shown
    if (widget.open) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _controller.forward();
        }
      });
    }
  }

  @override
  void didUpdateWidget(ConfirmDialog oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.open && !oldWidget.open) {
      _controller.forward();
    } else if (!widget.open && oldWidget.open) {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.open) return const SizedBox.shrink();

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final colors =
            themeProvider.isDarkMode ? AppColors.dark : AppColors.light;

        return GestureDetector(
          onTap: widget.onCancel,
          child: FadeTransition(
            opacity: _opacityAnimation,
            child: Container(
              color: Colors.black.withOpacity(0.5),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                child: Center(
                  child: GestureDetector(
                    onTap: () {}, // Prevent tap from closing
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: FadeTransition(
                        opacity: _opacityAnimation,
                        child: Container(
                          constraints: const BoxConstraints(
                            maxWidth: 448,
                            minWidth: 300,
                          ),
                          width: MediaQuery.of(context).size.width * 0.92,
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              colors: [
                                Colors.white.withOpacity(0.08),
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.6],
                              center: Alignment.topCenter,
                              radius: 1.5,
                            ),
                            color: themeProvider.isDarkMode
                                ? Colors.white.withOpacity(0.10)
                                : Colors.white.withOpacity(0.10),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.12),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 40,
                                offset: const Offset(0, 16),
                                spreadRadius: 0,
                              ),
                              BoxShadow(
                                color:
                                    const Color(0xFF5078FF).withOpacity(0.20),
                                blurRadius: 40,
                                offset: const Offset(0, 0),
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Title row with icon
                                  Row(
                                    children: [
                                      // Icon chip
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color(0xFF9C88FF),
                                              Color(0xFF4DD0E1),
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFF9C88FF)
                                                  .withOpacity(0.3),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.logout_rounded,
                                          color: Colors.white,
                                          size: 22,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          widget.title,
                                          style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: colors.primaryText,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  // Description
                                  if (widget.description != null)
                                    Text(
                                      widget.description!,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: colors.secondaryText,
                                        height: 1.5,
                                      ),
                                    ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'You\'ll be signed out on this device.',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color:
                                          colors.secondaryText.withOpacity(0.7),
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  // Buttons row
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      // Cancel button
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.10),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          border: Border.all(
                                            color:
                                                Colors.white.withOpacity(0.15),
                                            width: 1,
                                          ),
                                        ),
                                        child: Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            onTap: widget.onCancel,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 24,
                                                vertical: 12,
                                              ),
                                              child: Text(
                                                widget.cancelLabel,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  color: colors.primaryText,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      // Logout button
                                      Container(
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color(0xFFEF5350), // Rose
                                              Color(0xFFFF6B35), // Orange
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.red.withOpacity(0.3),
                                              blurRadius: 12,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            onTap: widget.onConfirm,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 24,
                                                vertical: 12,
                                              ),
                                              child: Text(
                                                widget.confirmLabel,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
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
          ),
        );
      },
    );
  }
}

/// Helper function to show themed confirm dialog
Future<bool?> showConfirmDialog({
  required BuildContext context,
  required String title,
  String? description,
  String confirmLabel = 'Confirm',
  String cancelLabel = 'Cancel',
}) async {
  bool? result;

  await showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return ConfirmDialog(
        open: true,
        title: title,
        description: description,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        onConfirm: () {
          result = true;
          Navigator.of(context).pop();
        },
        onCancel: () {
          result = false;
          Navigator.of(context).pop();
        },
      );
    },
  );

  return result;
}
