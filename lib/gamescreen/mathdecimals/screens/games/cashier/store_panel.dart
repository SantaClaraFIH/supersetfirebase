import 'dart:math';

import 'package:flutter/material.dart';

import 'models.dart';

class CashierStorePanel extends StatelessWidget {
  const CashierStorePanel({
    super.key,
    required this.aisleLabel,
    required this.basketLabel,
    required this.cashierCardLabel,
    required this.storeSceneLabel,
    required this.customerCardLabel,
    required this.scanLaneLabel,
    required this.scanPromptLabel,
    required this.customer,
    required this.scannedItemIds,
    required this.isScanningStage,
    required this.characterFloat,
    required this.onScanItem,
    required this.moneyText,
  });

  final String aisleLabel;
  final String basketLabel;
  final String cashierCardLabel;
  final String storeSceneLabel;
  final String customerCardLabel;
  final String scanLaneLabel;
  final String scanPromptLabel;
  final CustomerOrder customer;
  final Set<String> scannedItemIds;
  final bool isScanningStage;
  final Animation<double> characterFloat;
  final void Function(StoreItem item) onScanItem;
  final String Function(int cents) moneyText;

  String _customerChipText() {
    final String lead = '${customer.emoji} ${customer.name}';
    return '$lead • $customerCardLabel';
  }

  Widget _buildItemCard(
    StoreItem item, {
    required bool scanned,
    bool compact = false,
    double? forcedWidth,
  }) {
    return Container(
      width: forcedWidth ?? (compact ? 120 : 138),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: scanned
              ? [const Color(0xFFD8F3D6), const Color(0xFFBCEAB5)]
              : [Colors.white, const Color(0xFFF6F6F6)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: scanned ? Colors.green : Colors.black26,
          width: scanned ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(item.icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(moneyText(item.priceCents)),
              ],
            ),
          ),
          if (scanned) const Icon(Icons.check_circle, color: Colors.green),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isNarrow = constraints.maxWidth < 430;
        final bool isVeryNarrow = constraints.maxWidth < 340;
        final double cardWidth = isVeryNarrow
            ? constraints.maxWidth - 28
            : ((constraints.maxWidth - 12 - 12 - 8) / 2).clamp(118.0, 180.0);

        return Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFF8F2E8), Color(0xFFE7D7C0)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.brown.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                left: 10,
                right: 10,
                top: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF5F8A67), Color(0xFF4D7358)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    aisleLabel,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 96,
                child: Container(
                  height: 54,
                  color: Colors.brown.withValues(alpha: 0.15),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 62, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: isNarrow
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    AnimatedBuilder(
                                      animation: characterFloat,
                                      builder: (context, child) {
                                        return Transform.translate(
                                          offset: Offset(0, characterFloat.value),
                                          child: const Text('🙂', style: TextStyle(fontSize: 36)),
                                        );
                                      },
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            cashierCardLabel,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: Colors.brown.shade700,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            storeSceneLabel,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(fontWeight: FontWeight.w800),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE6F0FF),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    _customerChipText(),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontWeight: FontWeight.w800),
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              children: [
                                AnimatedBuilder(
                                  animation: characterFloat,
                                  builder: (context, child) {
                                    return Transform.translate(
                                      offset: Offset(0, characterFloat.value),
                                      child: const Text('🙂', style: TextStyle(fontSize: 36)),
                                    );
                                  },
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        cashierCardLabel,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Colors.brown.shade700,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        storeSceneLabel,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontWeight: FontWeight.w800),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Container(
                                    padding:
                                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE6F0FF),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      _customerChipText(),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontWeight: FontWeight.w800),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 16,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF8E6F5C), Color(0xFF6E5648)],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      basketLabel,
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                    ),
                    const SizedBox(height: 6),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: customer.items.map((item) {
                            final bool scanned = scannedItemIds.contains(item.id);
                            return Draggable<StoreItem>(
                              data: item,
                              feedback: Material(
                                color: Colors.transparent,
                                child: _buildItemCard(
                                  item,
                                  scanned: scanned,
                                  compact: true,
                                  forcedWidth: min(140, cardWidth),
                                ),
                              ),
                              childWhenDragging: Opacity(
                                opacity: 0.35,
                                child: _buildItemCard(
                                  item,
                                  scanned: scanned,
                                  forcedWidth: cardWidth,
                                ),
                              ),
                              child: _buildItemCard(
                                item,
                                scanned: scanned,
                                forcedWidth: cardWidth,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    DragTarget<StoreItem>(
                      onWillAcceptWithDetails: (_) => isScanningStage,
                      onAcceptWithDetails: (details) => onScanItem(details.data),
                      builder: (context, candidateData, rejectedData) {
                        final highlighted = candidateData.isNotEmpty;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: highlighted
                                  ? [
                                      const Color(0xFFCCF3C9),
                                      const Color(0xFFAEE7A9),
                                    ]
                                  : [
                                      const Color(0xFFD7E9FF),
                                      const Color(0xFFB9D5FA),
                                    ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: highlighted ? Colors.green : Colors.blueGrey,
                              width: 2,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Text('📟', style: TextStyle(fontSize: 24)),
                              const SizedBox(width: 8),
                              Column(
                                children: const [
                                  Icon(Icons.arrow_downward, size: 16, color: Colors.blueGrey),
                                  Icon(Icons.arrow_downward, size: 16, color: Colors.blueGrey),
                                ],
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      scanLaneLabel,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    Text(
                                      scanPromptLabel,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.blueGrey.shade700,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '${scannedItemIds.length}/${customer.items.length}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
