import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:supersetfirebase/services/translation_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'cashier/bottom_controls.dart';
import 'cashier/models.dart';
import 'cashier/register_panel.dart';
import 'cashier/right_panel.dart';
import 'cashier/store_panel.dart';

class CashierGameScreen extends StatefulWidget {
  const CashierGameScreen({super.key});

  @override
  State<CashierGameScreen> createState() => _CashierGameScreenState();
}

class _CashierGameScreenState extends State<CashierGameScreen>
    with TickerProviderStateMixin {
  static const double _kTokenSize = 34;
  static const double _kDrawerColGap = 5;
  static const double _kDrawerRowGap = 5;
  static const double _kDrawerContentInset = 10;
  static const double _kDrawerContentReduction = 40;
  static const double _kDrawerMinViewportWidth = 24;
  static const double _kDrawerMinViewportHeight = 22;
  static const double _kTrayContentInset = 3;
  static const double _kTrayMinViewportWidth = 24;
  static const double _kTrayMinViewportHeight = 22;
  static const double _kTrayHitInflate = 8;

  final Random _random = Random();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final FlutterTts _flutterTts = FlutterTts();
  SharedPreferences? _preferences;

  final Map<String, String> originalTexts = {
    'title': 'Decimal Cashier',
    'score': 'Score',
    'best': 'Best',
    'streak': 'Streak',
    'storeScene': 'Store Counter Scene',
    'register': 'Register',
    'questionPanel': 'Question Panel',
    'scanLane': 'Scan Lane',
    'basket': 'Basket Items',
    'subtotal': 'Subtotal',
    'paid': 'Paid',
    'changeDue': 'Change Due',
    'remaining': 'Remaining Items',
    'scanned': 'Scanned Items',
    'scanAll': 'Scan all items first.',
    'openRegister': 'Open Register',
    'checkChange': 'Check Change',
    'nextCustomer': 'Next Customer',
    'replay': 'Replay',
    'hint': 'Hint',
    'restart': 'Restart Session',
    'sessionDone': 'All 3 customers checked out!',
    'aisle': 'Aisle 5 • Grocery',
    'scanPrompt': 'Drag item to scanner',
    'drawerOpen': 'Drawer Open',
    'drawerClosed': 'Drawer Closed',
    'customerTray': 'Customer Tray',
    'customerCard': 'Current Customer',
    'cashierCard': 'Cashier',
    'promptScan': 'Customer {name} is ready. Drag each item across the scanner.',
    'promptPay': 'Total is {total}. Customer pays {paid}.',
    'promptChange': 'Give exact change: {change}. Use the register and tray.',
    'promptDone': 'Great! Customer {name} checked out.',
    'hintScan': 'Drag every item card into the scanner lane.',
    'hintChange': 'Change = paid - total. Build that amount in the tray.',
    'correct': 'Perfect change. Checkout complete!',
    'incorrect': 'Not exact yet. Try adjusting coins/bills.',
  };

  Map<String, String> translatedTexts = {};
  bool translated = false;

  final List<StoreItem> _catalog = const [
    StoreItem(id: 'milk', name: 'Milk', icon: '🥛', priceCents: 150),
    StoreItem(id: 'bread', name: 'Bread', icon: '🍞', priceCents: 225),
    StoreItem(id: 'apple', name: 'Apple', icon: '🍎', priceCents: 75),
    StoreItem(id: 'juice', name: 'Juice', icon: '🧃', priceCents: 125),
    StoreItem(id: 'cereal', name: 'Cereal', icon: '🥣', priceCents: 340),
    StoreItem(id: 'eggs', name: 'Eggs', icon: '🥚', priceCents: 260),
    StoreItem(id: 'banana', name: 'Banana', icon: '🍌', priceCents: 90),
    StoreItem(id: 'cheese', name: 'Cheese', icon: '🧀', priceCents: 315),
    StoreItem(id: 'chips', name: 'Chips', icon: '🍟', priceCents: 185),
  ];

  final List<int> _denominations = [100, 50, 25, 10, 5, 1];
  final List<MoneyToken> _registerTokens = [];
  final Map<int, int> _drawerStock = {
    100: 8,
    50: 10,
    25: 14,
    10: 16,
    5: 18,
    1: 50,
  };

  final List<String> _customerNames = ['Mia', 'Leo', 'Ava', 'Noah', 'Ella'];
  final List<String> _customerEmojis = ['🙂', '😀', '🛒', '👧', '👦'];

  final List<CustomerOrder> _customers = [];
  int _currentCustomerIndex = 0;
  CheckoutStage _stage = CheckoutStage.scanning;

  final Set<String> _scannedItemIds = <String>{};
  int _subtotalCents = 0;
  int _changeDueCents = 0;

  int _score = 0;
  int _bestScore = 0;
  int _streak = 0;

  Size _registerSize = Size.zero;
  int _tokenIdCounter = 0;
  int? _activeTokenId;
  final Map<int, Offset> _dragVisualByTokenId = <int, Offset>{};
  double _drawerScrollOffset = 0;
  bool _speechEnabled = true;

  late AnimationController _characterController;
  late Animation<double> _characterFloat;
  late AnimationController _changeBounceController;
  late AnimationController _changeShakeController;
  late Animation<double> _changeBounceAnimation;

  CustomerOrder get _currentCustomer => _customers[_currentCustomerIndex];

  int get _trayTotalCents => _registerTokens
      .where((token) => token.inTray)
      .fold(0, (sum, token) => sum + token.cents);

  double get _changeTextScale => _changeBounceAnimation.value;

  double get _changeTextShakeX {
    final double t = _changeShakeController.value;
    if (t == 0) {
      return 0;
    }
    final double decay = 1 - t;
    return sin(t * pi * 10) * 10 * decay;
  }

  @override
  void initState() {
    super.initState();
    _speechEnabled = true;
    _characterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _characterFloat = Tween<double>(begin: -4, end: 4).animate(
      CurvedAnimation(parent: _characterController, curve: Curves.easeInOut),
    );
    _changeBounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    );
    _changeBounceAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _changeBounceController, curve: Curves.easeInOut),
    );
    _changeShakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _changeBounceController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
    _changeShakeController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });

    _loadBestScore();
    _startNewSession();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _speak(_instructionText());
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _flutterTts.stop();
    _characterController.dispose();
    _changeBounceController.dispose();
    _changeShakeController.dispose();
    super.dispose();
  }

  bool _isChangeCurrentlyIncorrect() {
    return _stage == CheckoutStage.makingChange && _trayTotalCents != _changeDueCents;
  }

  void _updateChangeAnimations() {
    if (_isChangeCurrentlyIncorrect()) {
      if (!_changeBounceController.isAnimating) {
        _changeBounceController.repeat(reverse: true);
      }
      return;
    }

    if (_changeBounceController.isAnimating || _changeBounceController.value != 0) {
      _changeBounceController.stop();
      _changeBounceController.value = 0;
    }
  }

  Future<void> _loadBestScore() async {
    _preferences = await SharedPreferences.getInstance();
    if (!mounted) {
      return;
    }
    setState(() {
      _bestScore = _preferences?.getInt('cashier_session_best_score') ?? 0;
    });
  }

  Future<void> _saveBestScore() async {
    final prefs = _preferences ?? await SharedPreferences.getInstance();
    _preferences ??= prefs;
    if (_score > _bestScore) {
      if (mounted) {
        setState(() {
          _bestScore = _score;
        });
      } else {
        _bestScore = _score;
      }
      await prefs.setInt('cashier_session_best_score', _score);
    }
  }

  void _showTranslationError() {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Translation unavailable. Showing original text.'),
      ),
    );
  }

  Future<void> _playSound(String soundPath) async {
    try {
      await _audioPlayer.play(AssetSource(soundPath));
    } catch (_) {}
  }

  Future<void> _speak(String text, {bool userInitiated = false}) async {
    if (!_speechEnabled || text.trim().isEmpty) {
      return;
    }
    try {
      await _flutterTts.stop();
      await _flutterTts.setLanguage('en-US');
      await _flutterTts.setSpeechRate(0.8);
      await _flutterTts.setPitch(1.00);
      await _flutterTts.speak(text);
    } catch (e) {
      debugPrint('Cashier TTS error: $e');
    }
  }

  Future<void> translateTexts() async {
    if (translated) {
      setState(() {
        translatedTexts.clear();
        translated = false;
      });
      return;
    }

    try {
      final translations = await TranslationService
          .translateMap(originalTexts)
          .timeout(const Duration(seconds: 8));

      if (!mounted) {
        return;
      }
      setState(() {
        translatedTexts = translations;
        translated = true;
      });
    } on TimeoutException {
      _showTranslationError();
    } catch (_) {
      _showTranslationError();
    }
  }

  String _t(String key) {
    if (translated) {
      return translatedTexts[key] ?? originalTexts[key] ?? key;
    }
    return originalTexts[key] ?? key;
  }

  String _template(String key, Map<String, String> values) {
    String text = _t(key);
    for (final entry in values.entries) {
      if (!text.contains('{${entry.key}}')) {
        text = originalTexts[key] ?? text;
        break;
      }
    }
    for (final entry in values.entries) {
      text = text.replaceAll('{${entry.key}}', entry.value);
    }
    return text;
  }

  String _money(int cents) => '\$${(cents / 100).toStringAsFixed(2)}';

  int _wholeDollarPaymentAbove(int totalCents) {
    final int baseDollars = (totalCents / 100).ceil();
    final int extraDollars = 1 + _random.nextInt(2);
    return (baseDollars + extraDollars) * 100;
  }

  void _startNewSession() {
    _customers.clear();
    _score = 0;
    _streak = 0;
    _currentCustomerIndex = 0;

    for (int customerId = 0; customerId < 3; customerId++) {
      final int itemCount = 2 + _random.nextInt(3);
      final List<StoreItem> shuffled = [..._catalog]..shuffle(_random);
      final List<StoreItem> selected = shuffled.take(itemCount).toList();
      final int total = selected.fold(0, (sum, item) => sum + item.priceCents);
      final int paid = _wholeDollarPaymentAbove(total);

      _customers.add(
        CustomerOrder(
          id: customerId,
          name: _customerNames[_random.nextInt(_customerNames.length)],
          emoji: _customerEmojis[_random.nextInt(_customerEmojis.length)],
          items: selected,
          paidCents: paid,
        ),
      );
    }

    _prepareCurrentCustomer();
  }

  void _prepareCurrentCustomer() {
    _scannedItemIds.clear();
    _subtotalCents = 0;
    _changeDueCents = 0;
    _registerTokens.clear();
    _dragVisualByTokenId.clear();
    _drawerScrollOffset = 0;
    _stage = CheckoutStage.scanning;
    _activeTokenId = null;
    _changeShakeController.value = 0;
    _updateChangeAnimations();
    setState(() {});
  }

  void _scanItem(StoreItem item) async {
    if (_stage != CheckoutStage.scanning) {
      return;
    }
    if (_scannedItemIds.contains(item.id)) {
      return;
    }

    setState(() {
      _scannedItemIds.add(item.id);
      _subtotalCents += item.priceCents;
    });

    await _playSound('MathDecimals/sounds/success.mp3');

    final bool allScanned = _scannedItemIds.length == _currentCustomer.items.length;
    if (allScanned) {
      setState(() {
        _changeDueCents = _currentCustomer.paidCents - _subtotalCents;
        _stage = CheckoutStage.paymentInfo;
      });
      _updateChangeAnimations();
      await _speak(_instructionText(), userInitiated: true);
    }
  }

  Rect _drawerRect(Size size) {
    final double drawerHeight = (size.height * 0.33).clamp(124.0, 236.0);
    final double top = _registerSectionTop(size, drawerHeight);
    final double drawerWidth =
        (size.width * 0.44).clamp(126.0, size.width * 0.52).toDouble();
    return Rect.fromLTWH(
      14,
      top,
      drawerWidth,
      drawerHeight,
    );
  }

  Rect _trayRect(Size size) {
    final double trayHeight = (size.height * 0.33).clamp(124.0, 236.0);
    final double top = _registerSectionTop(size, trayHeight);
    final Rect drawer = _drawerRect(size);
    final double minTrayWidth = min(120.0, max(84.0, size.width * 0.30));
    double left = drawer.right + 12;
    final double maxLeft = size.width - minTrayWidth - 12;
    if (left > maxLeft) {
      left = max(12.0, maxLeft);
    }
    final double width = max(minTrayWidth, size.width - left - 12);
    return Rect.fromLTWH(
      left,
      top,
      width,
      trayHeight,
    );
  }

  double _registerSectionTop(Size size, double sectionHeight) {
    final double maxVisibleTop = size.height - sectionHeight - 14;
    if (maxVisibleTop <= 20) {
      return 8;
    }

    final double minTop = (size.height * 0.26).clamp(72.0, 170.0).toDouble();
    final double targetFactor = size.height < 500 ? 0.34 : 0.40;
    final double desiredTop = size.height * targetFactor;
    return desiredTop.clamp(minTop, maxVisibleTop).toDouble();
  }

  Rect _drawerTokenViewportRect(Size size) {
    final Rect drawer = _drawerRect(size);
    return Rect.fromLTWH(
      drawer.left + _kDrawerContentInset,
      drawer.top + _kDrawerContentInset,
      max(_kDrawerMinViewportWidth, drawer.width - _kDrawerContentReduction),
      max(_kDrawerMinViewportHeight, drawer.height - _kDrawerContentReduction),
    );
  }

  Rect _trayTokenViewportRect(Size size) {
    final Rect tray = _trayRect(size);
    return Rect.fromLTWH(
      tray.left + _kTrayContentInset,
      tray.top + _kTrayContentInset,
      max(_kTrayMinViewportWidth, tray.width - (_kTrayContentInset * 2)),
      max(_kTrayMinViewportHeight, tray.height - (_kTrayContentInset * 2)),
    );
  }

  Offset _clampTopLeftInRect(
    Offset position,
    Rect bounds, {
    double tokenSize = _kTokenSize,
  }) {
    final double clampedX =
        position.dx.clamp(bounds.left, bounds.right - tokenSize).toDouble();
    final double clampedY =
        position.dy.clamp(bounds.top, bounds.bottom - tokenSize).toDouble();
    return Offset(clampedX, clampedY);
  }

  double _clampDrawerSlotX(
    double x,
    Rect drawerContentRect, {
    double tokenSize = _kTokenSize,
  }) {
    return x
        .clamp(drawerContentRect.left, drawerContentRect.right - tokenSize)
        .toDouble();
  }

  int _drawerColumnCount(Rect drawerContentRect) {
    return max(
      2,
      ((drawerContentRect.width + _kDrawerColGap) / (_kTokenSize + _kDrawerColGap))
          .floor(),
    );
  }

  Offset _tokenSettledVisualPosition(MoneyToken token) {
    if (token.inTray) {
      return token.position;
    }
    return Offset(token.position.dx, token.position.dy - _drawerScrollOffset);
  }

  Offset _tokenVisualPosition(MoneyToken token) {
    return _dragVisualByTokenId[token.id] ?? _tokenSettledVisualPosition(token);
  }

  Offset _drawerContentPositionFromVisual(Offset visualPosition) {
    return Offset(visualPosition.dx, visualPosition.dy + _drawerScrollOffset);
  }

  bool _tokenWouldBeInTrayAt(Offset visualPosition) {
    final tray = _trayTokenViewportRect(_registerSize).inflate(_kTrayHitInflate);
    final center = visualPosition + const Offset(_kTokenSize / 2, _kTokenSize / 2);
    return tray.contains(center);
  }

  Offset _clampVisualTokenPosition(Offset visualPosition) {
    final double clampedX =
        visualPosition.dx.clamp(6.0, _registerSize.width - _kTokenSize - 6);
    final double clampedY =
        visualPosition.dy.clamp(6.0, _registerSize.height - _kTokenSize - 6);
    return Offset(clampedX, clampedY);
  }

  List<Offset> _traySlots(Rect tray) {
    final slotX = <double>[0.18, 0.40, 0.62, 0.84]
        .map((factor) => tray.left + (tray.width * factor) - (_kTokenSize / 2))
        .toList();
    final slotY = <double>[0.20, 0.42, 0.64, 0.84]
        .map((factor) => tray.top + (tray.height * factor) - (_kTokenSize / 2))
        .toList();

    final slots = <Offset>[];
    for (final y in slotY) {
      for (final x in slotX) {
        slots.add(_clampTopLeftInRect(Offset(x, y), tray));
      }
    }
    return slots;
  }

  List<Offset> _drawerSlots(Rect drawerContentRect, int slotCount) {
    final int columns = _drawerColumnCount(drawerContentRect);
    final double stepX = columns <= 1
        ? 0
        : (drawerContentRect.width - _kTokenSize) / (columns - 1);
    final slots = <Offset>[];

    for (int index = 0; index < slotCount; index++) {
      final int col = index % columns;
      final int row = index ~/ columns;
      final double x = _clampDrawerSlotX(
        drawerContentRect.left + (col * stepX),
        drawerContentRect,
      );
      final double y = drawerContentRect.top + (row * (_kTokenSize + _kDrawerRowGap));
      slots.add(Offset(x, y));
    }
    return slots;
  }

  Offset _nearestFreeSlot({
    required Offset target,
    required List<Offset> candidates,
    required List<Offset> occupied,
    required double minDistance,
  }) {
    Offset best = candidates.first;
    double bestDistance = double.infinity;

    for (final candidate in candidates) {
      final bool isOccupied = occupied.any(
        (point) => (point - candidate).distance < minDistance,
      );
      if (isOccupied) {
        continue;
      }
      final double distance = (candidate - target).distance;
      if (distance < bestDistance) {
        bestDistance = distance;
        best = candidate;
      }
    }

    if (bestDistance.isFinite) {
      return best;
    }

    return candidates.reduce(
      (a, b) => (a - target).distance < (b - target).distance ? a : b,
    );
  }

  void _settleTokenFromVisual(
    MoneyToken token,
    Offset releaseVisualPosition,
    Offset releaseVelocity,
  ) {
    final Offset momentumAdjusted = _clampVisualTokenPosition(
      releaseVisualPosition +
          Offset(
            (releaseVelocity.dx * 0.008).clamp(-18.0, 18.0),
            (releaseVelocity.dy * 0.008).clamp(-18.0, 18.0),
          ),
    );

    if (_tokenWouldBeInTrayAt(momentumAdjusted)) {
      final Rect tray = _trayTokenViewportRect(_registerSize);
      final List<Offset> slots = _traySlots(tray);
      final List<Offset> occupied = _registerTokens
          .where((other) => other.id != token.id && other.inTray)
          .map((other) => other.position)
          .toList();

      token.inTray = true;
      token.position = _nearestFreeSlot(
        target: momentumAdjusted,
        candidates: slots,
        occupied: occupied,
        minDistance: 26,
      );
      return;
    }

    final Rect drawerContentRect = _drawerTokenViewportRect(_registerSize);
    final Offset contentTarget = _drawerContentPositionFromVisual(momentumAdjusted);
    final int drawerTokenCount = _registerTokens.where((other) => !other.inTray).length;
    final List<Offset> slots =
      _drawerSlots(drawerContentRect, max(drawerTokenCount + 8, 24));
    final List<Offset> occupied = _registerTokens
        .where((other) => other.id != token.id && !other.inTray)
        .map((other) => other.position)
        .toList();

    token.inTray = false;
    token.position = _nearestFreeSlot(
      target: contentTarget,
      candidates: slots,
      occupied: occupied,
      minDistance: 20,
    );
  }

  void _buildRegisterTokens() {
    _registerTokens.clear();
    _dragVisualByTokenId.clear();
    final Rect drawerContentRect = _drawerTokenViewportRect(_registerSize);

    final List<int> drawerContents = <int>[];
    for (final denomination in _denominations) {
      final int count = _drawerStock[denomination] ?? 0;
      for (int index = 0; index < count; index++) {
        drawerContents.add(denomination);
      }
    }

    final List<Offset> drawerSlots =
      _drawerSlots(drawerContentRect, drawerContents.length + 12);

    for (int i = 0; i < drawerContents.length; i++) {
      _registerTokens.add(
        MoneyToken(
          id: _tokenIdCounter++,
          cents: drawerContents[i],
          position: drawerSlots[i],
        ),
      );
    }

    _drawerScrollOffset = 0;
  }

  double _drawerScrollMaxExtent() {
    if (_registerSize == Size.zero) {
      return 0;
    }

    final Rect drawerContentRect = _drawerTokenViewportRect(_registerSize);
    final int columns = _drawerColumnCount(drawerContentRect);
    final int tokenCount = _registerTokens.where((token) => !token.inTray).length;
    final int rows = (tokenCount / columns).ceil();
    final double contentHeight = rows <= 0
        ? 0
      : _kTokenSize + ((rows - 1) * (_kTokenSize + _kDrawerRowGap));
    final double viewportHeight = drawerContentRect.height;
    return max(0.0, contentHeight - viewportHeight);
  }

  void _scrollDrawerBy(double delta) {
    final double maxExtent = _drawerScrollMaxExtent();
    if (maxExtent <= 0) {
      return;
    }
    setState(() {
      _drawerScrollOffset = (_drawerScrollOffset + delta).clamp(0.0, maxExtent);
    });
  }

  void _openRegister() {
    if (_stage != CheckoutStage.paymentInfo) {
      return;
    }

    setState(() {
      _stage = CheckoutStage.makingChange;
      if (_registerSize != Size.zero) {
        _buildRegisterTokens();
      }
    });
    _updateChangeAnimations();
    _speak(_instructionText(), userInitiated: true);
  }

  void _applyTokenMomentum(MoneyToken token, Offset velocity) {
    final Offset releaseVisual = _dragVisualByTokenId[token.id] ?? _tokenSettledVisualPosition(token);
    _settleTokenFromVisual(token, releaseVisual, velocity);
  }

  void _checkChange() async {
    if (_stage != CheckoutStage.makingChange) {
      return;
    }

    final bool correct = _trayTotalCents == _changeDueCents;
    if (correct) {
      setState(() {
        _stage = CheckoutStage.checkedOut;
        _score += 20;
        _streak += 1;
      });
      _changeShakeController.value = 0;
      _updateChangeAnimations();
      _saveBestScore();
      await _playSound('MathDecimals/sounds/success.mp3');
      await _speak(_t('correct'), userInitiated: true);
    } else {
      setState(() {
        _streak = 0;
      });
      _changeShakeController
        ..stop()
        ..forward(from: 0);
      _updateChangeAnimations();
      await _playSound('MathDecimals/sounds/error.mp3');
      await _speak(_t('incorrect'), userInitiated: true);
    }
  }

  void _nextCustomer() {
    if (_stage != CheckoutStage.checkedOut) {
      return;
    }

    if (_currentCustomerIndex < _customers.length - 1) {
      setState(() {
        _currentCustomerIndex += 1;
      });
      _prepareCurrentCustomer();
      _speak(_instructionText(), userInitiated: true);
    } else {
      setState(() {
        _stage = CheckoutStage.sessionComplete;
      });
      _updateChangeAnimations();
      _saveBestScore();
      _speak(_t('sessionDone'), userInitiated: true);
    }
  }

  String _instructionText() {
    switch (_stage) {
      case CheckoutStage.scanning:
        return _template(
          'promptScan',
          {'name': _currentCustomer.name},
        );
      case CheckoutStage.paymentInfo:
        return _template(
          'promptPay',
          {
            'total': _money(_subtotalCents),
            'paid': _money(_currentCustomer.paidCents),
          },
        );
      case CheckoutStage.makingChange:
        return _template(
          'promptChange',
          {'change': _money(_changeDueCents)},
        );
      case CheckoutStage.checkedOut:
        return _template(
          'promptDone',
          {'name': _currentCustomer.name},
        );
      case CheckoutStage.sessionComplete:
        return _t('sessionDone');
    }
  }

  String _hintText() {
    if (_stage == CheckoutStage.scanning) {
      return _t('hintScan');
    }
    return _t('hintChange');
  }

  Widget _buildTopBadges() {
    Widget badge(String label, String value, Color color) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        badge(_t('score'), '$_score', Colors.indigo),
        const SizedBox(width: 8),
        badge(_t('best'), '$_bestScore', Colors.teal),
        const SizedBox(width: 8),
        badge(_t('streak'), '$_streak', Colors.deepOrange),
      ],
    );
  }

  Widget _buildStoreScene() {
    return CashierStorePanel(
      aisleLabel: _t('aisle'),
      basketLabel: _t('basket'),
      cashierCardLabel: _t('cashierCard'),
      storeSceneLabel: _t('storeScene'),
      customerCardLabel: _t('customerCard'),
      scanLaneLabel: _t('scanLane'),
      scanPromptLabel: _t('scanPrompt'),
      customer: _currentCustomer,
      scannedItemIds: _scannedItemIds,
      isScanningStage: _stage == CheckoutStage.scanning,
      characterFloat: _characterFloat,
      onScanItem: _scanItem,
      moneyText: _money,
    );
  }

  Widget _buildRegisterScene() {
    return CashierRegisterPanel(
      registerLabel: _t('register'),
      drawerClosedLabel: _t('drawerClosed'),
      customerTrayLabel: _t('customerTray'),
      trayTotalText: '${_money(_trayTotalCents)} / ${_money(_changeDueCents)}',
      changeTextScale: _changeTextScale,
      changeTextShakeX: _changeTextShakeX,
      drawerRectForSize: _drawerRect,
      trayRectForSize: _trayRect,
      drawerOpen:
          _stage == CheckoutStage.makingChange || _stage == CheckoutStage.checkedOut,
      showTokens:
          _stage == CheckoutStage.makingChange || _stage == CheckoutStage.checkedOut,
      registerTokens: _registerTokens,
        buildToken: (token) => _buildRegisterToken(token),
      drawerScrollOffset: _drawerScrollOffset,
      drawerScrollMaxExtent: _drawerScrollMaxExtent,
      onScrollDrawerBy: _scrollDrawerBy,
      onDrawerScrollSet: (offset) {
        setState(() {
          _drawerScrollOffset = offset;
        });
      },
      onSizeChanged: (size) {
        if (_registerSize != size) {
          _registerSize = size;
          if (_stage == CheckoutStage.makingChange && _registerTokens.isEmpty) {
            _buildRegisterTokens();
          }
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {});
            }
          });
        }
      },
    );
  }

  Widget _buildRegisterToken(MoneyToken token) {
    final bool inDrawer = !token.inTray;
    final Offset visualPosition = _tokenVisualPosition(token);
    final bool isActiveDrag = _activeTokenId == token.id;
    final Rect bounds = inDrawer
        ? _drawerTokenViewportRect(_registerSize)
        : _trayTokenViewportRect(_registerSize);
    final bool hiddenOutsideBounds = visualPosition.dx < bounds.left ||
      visualPosition.dx + _kTokenSize > bounds.right ||
      visualPosition.dy < bounds.top ||
      visualPosition.dy + _kTokenSize > bounds.bottom;

    if (!isActiveDrag && hiddenOutsideBounds) {
      return const SizedBox.shrink();
    }

    final bool isBill = token.cents >= 100;

    return Positioned(
      left: visualPosition.dx,
      top: visualPosition.dy,
      child: GestureDetector(
        onPanStart: (_) {
          if (_stage != CheckoutStage.makingChange) {
            return;
          }
          setState(() {
            _activeTokenId = token.id;
            _dragVisualByTokenId[token.id] = _tokenSettledVisualPosition(token);
          });
        },
        onPanUpdate: (details) {
          if (_stage != CheckoutStage.makingChange) {
            return;
          }
          setState(() {
            final Offset baseVisual =
                _dragVisualByTokenId[token.id] ?? _tokenSettledVisualPosition(token);
            _dragVisualByTokenId[token.id] =
                _clampVisualTokenPosition(baseVisual + details.delta);
          });
        },
        onPanEnd: (details) {
          if (_stage != CheckoutStage.makingChange) {
            return;
          }
          setState(() {
            _applyTokenMomentum(token, details.velocity.pixelsPerSecond);
            _dragVisualByTokenId.remove(token.id);
            _activeTokenId = null;
          });
          _updateChangeAnimations();
        },
        onPanCancel: () {
          setState(() {
            if (_activeTokenId == token.id) {
              _applyTokenMomentum(token, Offset.zero);
              _dragVisualByTokenId.remove(token.id);
            }
            _activeTokenId = null;
          });
          _updateChangeAnimations();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          width: _kTokenSize,
          height: _kTokenSize,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isBill
                  ? [const Color(0xFFB9E6AF), const Color(0xFF76B96D)]
                  : [const Color(0xFFF2D46D), const Color(0xFFDCAF34)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(isBill ? 8 : 22),
            border: Border.all(
              color: token.inTray ? Colors.deepPurple : Colors.brown.shade700,
              width: token.inTray || _activeTokenId == token.id ? 3 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 8,
                offset: const Offset(1, 3),
              ),
            ],
          ),
          child: Center(
            child: Text(
              token.cents >= 100 ? '\$${token.cents ~/ 100}' : '${token.cents}¢',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRightPanel() {
    return CashierRightPanel(
      questionPanelLabel: _t('questionPanel'),
      instructionText: _instructionText(),
      showInstruction: false,
      subtotalLabel: _t('subtotal'),
      paidLabel: _t('paid'),
      changeDueLabel: _t('changeDue'),
      scannedLabel: _t('scanned'),
      remainingLabel: _t('remaining'),
      sessionDoneLabel: _t('sessionDone'),
      customer: _currentCustomer,
      scannedItemIds: _scannedItemIds,
      subtotalCents: _subtotalCents,
      changeDueCents: _changeDueCents,
      isSessionComplete: _stage == CheckoutStage.sessionComplete,
      moneyText: _money,
    );
  }

  Widget _buildBottomControls() {
    return CashierBottomControls(
      replayLabel: _t('replay'),
      hintLabel: _t('hint'),
      openRegisterLabel: _t('openRegister'),
      checkChangeLabel: _t('checkChange'),
      nextCustomerLabel: _t('nextCustomer'),
      restartLabel: _t('restart'),
      onReplay: () => _speak(_instructionText(), userInitiated: true),
      onHint: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_hintText())),
        );
      },
      onOpenRegister: _openRegister,
      onCheckChange: _checkChange,
      onNextCustomer: _nextCustomer,
      onRestart: _startNewSession,
      canOpenRegister: _stage == CheckoutStage.paymentInfo,
      canCheckChange: _stage == CheckoutStage.makingChange,
      canNextCustomer: _stage == CheckoutStage.checkedOut,
    );
  }

  Widget _buildTopInstructionBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.deepOrange.withValues(alpha: 0.24)),
      ),
      child: Text(
        _instructionText(),
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildTopStatusRow() {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 860) {
          return Column(
            children: [
              _buildTopInstructionBanner(),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: _buildTopBadges(),
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: _buildTopInstructionBanner()),
            const SizedBox(width: 10),
            Align(
              alignment: Alignment.centerRight,
              child: _buildTopBadges(),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_t('title')),
        backgroundColor: Colors.deepOrange,
        actions: [
          IconButton(
            onPressed: translateTexts,
            icon: const Icon(Icons.translate),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.home),
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 86,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.5),
                    Colors.white.withValues(alpha: 0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                _buildTopStatusRow(),
                const SizedBox(height: 10),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final bool useStackedLayout = constraints.maxWidth < 980;
                      if (!useStackedLayout) {
                        return Row(
                          children: [
                            Expanded(flex: 4, child: _buildStoreScene()),
                            const SizedBox(width: 10),
                            Expanded(flex: 5, child: _buildRegisterScene()),
                            const SizedBox(width: 10),
                            Expanded(flex: 4, child: _buildRightPanel()),
                          ],
                        );
                      }

                      final double storeHeight =
                          max(220.0, constraints.maxHeight * 0.34);
                      final double registerHeight =
                          max(250.0, constraints.maxHeight * 0.42);
                      final double rightHeight =
                          max(210.0, constraints.maxHeight * 0.30);

                      return ListView(
                        children: [
                          SizedBox(height: storeHeight, child: _buildStoreScene()),
                          const SizedBox(height: 10),
                          SizedBox(height: registerHeight, child: _buildRegisterScene()),
                          const SizedBox(height: 10),
                          SizedBox(height: rightHeight, child: _buildRightPanel()),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                _buildBottomControls(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
