import 'package:flutter/material.dart';

class StoreItem {
  const StoreItem({
    required this.id,
    required this.name,
    required this.icon,
    required this.priceCents,
  });

  final String id;
  final String name;
  final String icon;
  final int priceCents;
}

class CustomerOrder {
  const CustomerOrder({
    required this.id,
    required this.name,
    required this.emoji,
    required this.items,
    required this.paidCents,
  });

  final int id;
  final String name;
  final String emoji;
  final List<StoreItem> items;
  final int paidCents;
}

class MoneyToken {
  MoneyToken({
    required this.id,
    required this.cents,
    required this.position,
  });

  final int id;
  final int cents;
  Offset position;
  bool inTray = false;
}

enum CheckoutStage {
  scanning,
  paymentInfo,
  makingChange,
  checkedOut,
  sessionComplete,
}
