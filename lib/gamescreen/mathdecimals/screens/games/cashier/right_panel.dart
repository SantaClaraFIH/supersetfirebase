import 'package:flutter/material.dart';

import 'models.dart';
import 'widgets.dart';

class CashierRightPanel extends StatelessWidget {
  const CashierRightPanel({
    super.key,
    required this.questionPanelLabel,
    required this.instructionText,
    required this.showInstruction,
    required this.subtotalLabel,
    required this.paidLabel,
    required this.changeDueLabel,
    required this.scannedLabel,
    required this.remainingLabel,
    required this.sessionDoneLabel,
    required this.customer,
    required this.scannedItemIds,
    required this.subtotalCents,
    required this.changeDueCents,
    required this.isSessionComplete,
    required this.moneyText,
  });

  final String questionPanelLabel;
  final String instructionText;
  final bool showInstruction;
  final String subtotalLabel;
  final String paidLabel;
  final String changeDueLabel;
  final String scannedLabel;
  final String remainingLabel;
  final String sessionDoneLabel;
  final CustomerOrder customer;
  final Set<String> scannedItemIds;
  final int subtotalCents;
  final int changeDueCents;
  final bool isSessionComplete;
  final String Function(int cents) moneyText;

  @override
  Widget build(BuildContext context) {
    final remaining =
        customer.items.where((item) => !scannedItemIds.contains(item.id)).toList();
    final scanned =
        customer.items.where((item) => scannedItemIds.contains(item.id)).toList();

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF3F8FF), Color(0xFFDCEAFF)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.blueGrey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              questionPanelLabel,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            if (showInstruction) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blue.shade100),
                ),
                child: Text(
                  instructionText,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 10),
            ] else
              const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  CashierMetricRow(
                    label: subtotalLabel,
                    value: moneyText(subtotalCents),
                  ),
                  CashierMetricRow(
                    label: paidLabel,
                    value: moneyText(customer.paidCents),
                  ),
                  CashierMetricRow(
                    label: changeDueLabel,
                    value: moneyText(changeDueCents),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(scannedLabel, style: const TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: scanned
                  .map((item) => Chip(label: Text('${item.icon} ${item.name}')))
                  .toList(),
            ),
            const SizedBox(height: 8),
            Text(remainingLabel, style: const TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: remaining
                  .map(
                    (item) => Chip(
                      backgroundColor: Colors.orange.shade100,
                      label: Text('${item.icon} ${item.name}'),
                    ),
                  )
                  .toList(),
            ),
            const Spacer(),
            if (isSessionComplete)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  sessionDoneLabel,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
