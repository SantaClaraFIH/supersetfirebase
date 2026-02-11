import 'package:flutter/material.dart';
import 'dart:ui';
import 'util.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:supersetfirebase/utils/logout_util.dart';
import 'package:provider/provider.dart';
import 'package:supersetfirebase/provider/user_pin_provider.dart';
import 'package:supersetfirebase/gamescreen/mathmingle/analytics_engine.dart';

class StudyMaterialScreen extends StatefulWidget {
  const StudyMaterialScreen({super.key});

  @override
  _StudyMaterialScreenState createState() => _StudyMaterialScreenState();
}

class _StudyMaterialScreenState extends State<StudyMaterialScreen> {
  late final PageController _pageController;
  int currentPage = 0;
  Map<String, List<String>> translations = {};
  bool isLoading = true;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.3);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int? chapter = ModalRoute.of(context)?.settings.arguments as int?;
    String userPin = Provider.of<UserPinProvider>(context, listen: false).pin;

    if (chapter == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('Error: Chapter not provided.')),
      );
    }

    if (isLoading) {
      loadTranslations(chapter);
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    String getChapterTitle() {
      switch (chapter) {
        case 1:
          return 'N U M B E R S';
        case 2:
          return 'F O U N D A T I O N S';
        case 3:
          return 'S H A P E S';
        case 4:
          return 'S Y M B O L S';
        case 5:
          return 'G E O M E T R I C S';
        default:
          return 'Unknown Chapter';
      }
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Stack(
          alignment: Alignment.center,
          children: [
            AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              automaticallyImplyLeading: false,
            ),
            Positioned(
              left: 16,
              top: 12,
              child: Builder(
                builder: (context) {
                  final screenWidth = MediaQuery.of(context).size.width;
                  final double buttonSize = screenWidth < 600 ? 30 : 50;
                  final double iconSize = screenWidth < 600 ? 18 : 28;
                  return SizedBox(
                    width: buttonSize,
                    height: buttonSize,
                    child: FloatingActionButton(
                      heroTag: "backButton",
                      onPressed: () => Navigator.pop(context),
                      foregroundColor: Colors.black,
                      backgroundColor: Colors.lightBlue,
                      shape: const CircleBorder(),
                      child: Icon(Icons.arrow_back_rounded, size: iconSize),
                    ),
                  );
                },
              ),
            ),
            Positioned(
              top: 12,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Builder(
                    builder: (context) {
                      final screenWidth = MediaQuery.of(context).size.width;
                      final double fontSize = screenWidth < 600 ? 12 : 14;
                      final double horizontalPadding =
                          screenWidth < 600 ? 10 : 12;
                      final double verticalPadding = screenWidth < 600 ? 6 : 6;
                      final double borderRadius = screenWidth < 600 ? 10 : 12;
                      final double maxWidth = screenWidth < 600 ? 80 : 120;
                      return Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: horizontalPadding,
                          vertical: verticalPadding,
                        ),
                        constraints: BoxConstraints(maxWidth: maxWidth),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(borderRadius),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            'PIN: $userPin',
                            style: TextStyle(
                              fontSize: fontSize,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'V O C A B U L A R Y',
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width > 700
                          ? 30
                          : MediaQuery.of(context).size.width / 30,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: SizedBox(
        width: MediaQuery.of(context).size.height > 700 ? 56 : 40,
        height: MediaQuery.of(context).size.height > 700 ? 56 : 40,
        child: FloatingActionButton(
          heroTag: "logoutButton",
          onPressed: () => logout(context),
          backgroundColor: Colors.blue,
          child: Icon(
            Icons.logout_rounded,
            size: MediaQuery.of(context).size.height > 700 ? 28 : 20,
            color: Colors.white,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Stack(
        children: [
          Image.asset(
            'assets/Mathmingle/study_material.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              color: Colors.pinkAccent.withOpacity(0.05),
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              16.0,
              MediaQuery.of(context).size.height > 300 ? 100.0 : 70.0,
              16.0,
              16.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'C H A P T E R  $chapter - ${getChapterTitle()}',
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width > 700
                        ? 40
                        : MediaQuery.of(context).size.width / 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: translations["spanish"]?.length ?? 0,
                    onPageChanged: (int page) {
                      setState(() {
                        currentPage = page;
                      });
                    },
                    itemBuilder: (context, index) {
                      return AnimatedBuilder(
                        animation: _pageController,
                        builder: (context, child) {
                          // fallback to page 0 before dimensions are available
                          double page = (_pageController.hasClients &&
                                  _pageController.position.haveDimensions)
                              ? _pageController.page!
                              : _pageController.initialPage.toDouble();
                          final diff = (page - index).abs();
                          final value = (1 - (diff * 0.3)).clamp(0.0, 1.0);
                          return Transform.scale(
                            scale: value,
                            child: Opacity(
                              opacity: value,
                              child: child,
                            ),
                          );
                        },
                        child: buildFlashcard(
                          translations["english"]?[index] ?? '',
                          translations["spanish"]?[index] ?? '',
                          chapter,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                if (currentPage == 0)
                  _buildNavButton('N E X T', () {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                    );
                    setState(() {
                      currentPage++;
                    });
                    if (chapter != null &&
                        translations["spanish"] != null &&
                        translations["spanish"]!.length > currentPage) {
                      _playAudio(
                          translations["spanish"]![currentPage], chapter);
                    }
                  }),
                if (currentPage > 0 &&
                    currentPage < (translations["spanish"]?.length ?? 1) - 1)
                  _buildNavButton('Next', () {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                    );
                    setState(() {
                      currentPage++;
                    });
                    if (chapter != null &&
                        translations["spanish"] != null &&
                        translations["spanish"]!.length > currentPage) {
                      _playAudio(
                          translations["spanish"]![currentPage], chapter);
                    }
                  }),
                if (currentPage == (translations["spanish"]?.length ?? 1) - 1)
                  _buildNavButton('E X I T', () {
                    Navigator.pop(context);
                  }, isExit: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> loadTranslations(int chapter) async {
    final data = await loadJsonData(chapter);
    setState(() {
      translations = data;
      isLoading = false;
    });
    // Play audio for the first card
    if (translations["spanish"] != null &&
        translations["spanish"]!.isNotEmpty) {
      _playAudio(translations["spanish"]![0], chapter);
    }
  }

  Widget _buildNavButton(String label, VoidCallback onPressed,
      {bool isExit = false}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
              MediaQuery.of(context).size.width > 700 ? 20.0 : 15.0),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width > 700 ? 30 : 20,
          vertical: MediaQuery.of(context).size.width > 700 ? 15 : 10,
        ),
      ),
      onPressed: onPressed,
      child: Text(
        label,
        style: TextStyle(
          fontSize: MediaQuery.of(context).size.width > 700 ? 25 : 18,
          color: isExit ? Colors.red : Colors.blue,
          fontWeight: isExit ? FontWeight.bold : FontWeight.bold,
        ),
      ),
    );
  }

  Widget buildFlashcard(String spanish, String english, int chapter) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isLargeScreen = screenWidth > 1000;

    return Center(
      child: Container(
        constraints: BoxConstraints(
          maxWidth: isLargeScreen ? screenWidth * 0.8 : screenWidth,
          minHeight: isLargeScreen ? 100 : screenHeight * 0.2,
          maxHeight: isLargeScreen ? screenHeight * 0.9 : screenHeight * 0.5,
        ),
        margin: EdgeInsets.symmetric(
          horizontal: isLargeScreen ? 10 : 5,
          vertical: isLargeScreen ? 20 : 10,
        ),
        padding: EdgeInsets.all(isLargeScreen ? 20 : 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: isLargeScreen
            ? _buildLargeScreenContent(spanish, english, chapter)
            : _buildSmallScreenContent(spanish, english, chapter),
      ),
    );
  }

  Widget _buildLargeScreenContent(String spanish, String english, int chapter) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    english,
                    style: const TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.volume_up, size: 30, color: Colors.blue),
                onPressed: () => _playAudio(english, chapter),
              ),
            ],
          ),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              spanish,
              style: TextStyle(
                fontSize: 30,
                color: Colors.grey[600],
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallScreenContent(String spanish, String english, int chapter) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final minCardHeight = 120.0;
        final preferredHeight = constraints.maxHeight * 0.3;
        final cardHeight =
            preferredHeight.clamp(minCardHeight, double.infinity);
        return SizedBox(
          height: cardHeight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          english,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                          maxLines: 2,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.volume_up,
                          size: 20, color: Colors.blue),
                      onPressed: () => _playAudio(english, chapter),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    spanish,
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.grey,
                    ),
                    maxLines: 2,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _playAudio(String english, int chapter) {
    final fileName = english.toLowerCase().replaceAll("/", "_");
    _audioPlayer.play(AssetSource('Mathmingle/audio/$fileName.mp3'));
    AnalyticsEngine.logAudioButtonClick_MathMingle(english, chapter);
  }
}
