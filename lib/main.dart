import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';

import 'services/service_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SafecrossServiceManager.ensureInitialized();
  runApp(const SafeCrossApp());
}

class SafeCrossApp extends StatelessWidget {
  const SafeCrossApp({super.key});

  static const _seed = Color(0xFF1E8054);

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.manropeTextTheme();
    return MaterialApp(
      title: 'SafeCross',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _seed,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F7F4),
        textTheme: textTheme,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _pageController = PageController();

  int _currentIndex = 0;
  bool _cameraGranted = false;
  bool _locationGranted = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _requestCrossPermissions() async {
    final locationStatus = await Permission.locationWhenInUse.request();
    final cameraStatus = await Permission.camera.request();

    setState(() {
      _locationGranted = locationStatus.isGranted || locationStatus.isLimited;
      _cameraGranted = cameraStatus.isGranted || cameraStatus.isLimited;
    });
  }

  Future<void> _ensureLocationPermission() async {
    if (_locationGranted) return;
    final status = await Permission.locationWhenInUse.request();
    setState(() => _locationGranted = status.isGranted || status.isLimited);
  }

  void _handleTabTap(int index) {
    setState(() => _currentIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      const _HomeTab(),
      _CrossTab(
        permissionsGranted: _cameraGranted && _locationGranted,
        onRequestPermissions: _requestCrossPermissions,
      ),
      _ReportTab(onEnsureLocation: _ensureLocationPermission),
      const _SettingsTab(),
    ];

    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const _BrandHeader(),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: pages,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _SafeNavBar(
        currentIndex: _currentIndex,
        onTap: _handleTabTap,
        colorScheme: theme.colorScheme,
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 4),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(Icons.shield_moon, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SafeCross',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'Made with care for pedestrian safety',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SafeNavBar extends StatelessWidget {
  const _SafeNavBar({
    required this.currentIndex,
    required this.onTap,
    required this.colorScheme,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final ColorScheme colorScheme;

  static const _items = [
    _NavItem(Icons.home_outlined, 'Home'),
    _NavItem(Icons.navigation_rounded, 'Cross'),
    _NavItem(Icons.chat_bubble_outline, 'Report'),
    _NavItem(Icons.settings_outlined, 'Setting'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(48),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .08),
              blurRadius: 26,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Row(
          children: List.generate(_items.length, (index) {
            final item = _items[index];
            final isActive = index == currentIndex;
            return Expanded(
              child: GestureDetector(
                onTap: () => onTap(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: isActive
                        ? colorScheme.primary.withValues(alpha: .12)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        item.icon,
                        color: isActive
                            ? colorScheme.primary
                            : Colors.grey[500],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isActive
                              ? colorScheme.primary
                              : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem(this.icon, this.label);

  final IconData icon;
  final String label;
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final insights = const [
      _Insight(
        'Use pedestrian lights',
        'Always wait for the green signal',
        Icons.light_mode,
      ),
      _Insight(
        '3 safe crossings nearby',
        'With active traffic signals',
        Icons.place_outlined,
      ),
      _Insight(
        'High visibility today',
        'Clear weather conditions',
        Icons.wb_sunny_outlined,
      ),
    ];

    final activity = const [
      _ActivityEntry('Mon', .5),
      _ActivityEntry('Tue', .8),
      _ActivityEntry('Wed', .6),
      _ActivityEntry('Thu', .85),
      _ActivityEntry('Fri', .9),
      _ActivityEntry('Sat', .65),
      _ActivityEntry('Sun', .4),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Good evening',
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Stay safe out there',
            style: theme.textTheme.headlineLarge?.copyWith(
              color: Colors.black87,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 20),
          const _SafetyScoreCard(),
          const SizedBox(height: 20),
          _HomeCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Safety insights',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                ...insights.map(
                  (insight) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(
                              alpha: .12,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            insight.icon,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                insight.title,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                insight.subtitle,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const _RiskCard(),
          const SizedBox(height: 20),
          _WalkingPatternCard(entries: activity),
          const SizedBox(height: 20),
          Row(
            children: const [
              Expanded(
                child: _StatCard(
                  label: 'This week',
                  value: '47',
                  subtitle: 'Safe crossings',
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _StatCard(
                  label: 'Total',
                  value: '342',
                  subtitle: 'Safe crossings',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _HomeCard extends StatelessWidget {
  const _HomeCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .05),
            blurRadius: 22,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SafetyScoreCard extends StatelessWidget {
  const _SafetyScoreCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          colors: [Color(0xFF118050), Color(0xFF34C47C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0B5C38).withValues(alpha: .45),
            blurRadius: 32,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.verified_user,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your safety score',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Excellent',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "You've made 47 safe crossings this week. Keep up the great work protecting yourself on the road.",
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withValues(alpha: .9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RiskCard extends StatelessWidget {
  const _RiskCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _HomeCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Current risk factor',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Low',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '25',
                style: theme.textTheme.displaySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Index',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: .25,
              minHeight: 12,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: const [
              _ChipTag('Clear conditions'),
              _ChipTag('Good visibility'),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChipTag extends StatelessWidget {
  const _ChipTag(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _WalkingPatternCard extends StatelessWidget {
  const _WalkingPatternCard({required this.entries});

  final List<_ActivityEntry> entries;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _HomeCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your walking pattern',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: const [
              Expanded(
                child: _PatternStat(label: '8:00 AM', subtitle: 'Peak time'),
              ),
              Expanded(
                child: _PatternStat(label: '7', subtitle: 'Daily avg'),
              ),
              Expanded(
                child: _PatternStat(label: '+12%', subtitle: 'This week'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: entries
                .map(
                  (entry) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                            height: 110 * entry.value,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  theme.colorScheme.primary,
                                  theme.colorScheme.primary.withValues(
                                    alpha: .3,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            entry.label,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _PatternStat extends StatelessWidget {
  const _PatternStat({required this.label, required this.subtitle});

  final String label;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _ActivityEntry {
  const _ActivityEntry(this.label, this.value);

  final String label;
  final double value;
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.subtitle,
  });

  final String label;
  final String value;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _HomeCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

enum CrossingStage { idle, analyzing, wait, safe }

class _CrossTab extends StatefulWidget {
  const _CrossTab({
    required this.permissionsGranted,
    required this.onRequestPermissions,
  });

  final bool permissionsGranted;
  final Future<void> Function() onRequestPermissions;

  @override
  State<_CrossTab> createState() => _CrossTabState();
}

class _CrossTabState extends State<_CrossTab> {
  CrossingStage _stage = CrossingStage.idle;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _startFlow() async {
    if (_stage == CrossingStage.analyzing || _stage == CrossingStage.wait) {
      return;
    }

    if (!widget.permissionsGranted) {
      await widget.onRequestPermissions();
      if (!mounted || !widget.permissionsGranted) {
        return;
      }
    }

    _runSafetySequence();
  }

  void _runSafetySequence() {
    _timer?.cancel();
    setState(() => _stage = CrossingStage.analyzing);
    _timer = Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() => _stage = CrossingStage.wait);
      _timer = Timer(const Duration(seconds: 2), () {
        if (!mounted) return;
        setState(() => _stage = CrossingStage.safe);
        unawaited(_activateAssistFeatures());
      });
    });
  }

  void _reset() {
    _timer?.cancel();
    setState(() => _stage = CrossingStage.idle);
  }

  Future<void> _activateAssistFeatures() async {
    final messenger = ScaffoldMessenger.of(context);
    final success = await SafecrossServiceManager.instance
        .ensureAssistFeaturesEnabled();
    if (!mounted) {
      return;
    }
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Vibration, voice, and flash beacons stay active for you.'
              : 'Enable all SafeCross controls to activate vibration and voice.',
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = _CrossPalette(theme.colorScheme.primary, _stage);
    final copy = _CrossCopy(_stage);
    final VoidCallback primaryAction = _stage == CrossingStage.safe
        ? _reset
        : _startFlow;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      child: Column(
        children: [
          Text(
            'Crossing assistant',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Real-time safety check for pedestrians',
            style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 42),
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: primaryAction,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [palette.outer.withValues(alpha: .15), Colors.white],
                  stops: const [0.1, 1],
                ),
              ),
              child: Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 190,
                  height: 190,
                  decoration: BoxDecoration(
                    color: palette.inner,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: palette.inner.withValues(alpha: .35),
                        blurRadius: 40,
                        offset: const Offset(0, 18),
                      ),
                    ],
                  ),
                  child: Icon(copy.icon, color: Colors.white, size: 60),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            copy.title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            copy.subtitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: primaryAction,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: widget.permissionsGranted
                    ? theme.colorScheme.primary
                    : Colors.grey[400],
              ),
              child: Text(
                _stage == CrossingStage.safe
                    ? 'Check again'
                    : (widget.permissionsGranted
                          ? 'Check crossing safety'
                          : 'Enable camera & location'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CrossPalette {
  _CrossPalette(Color brand, CrossingStage stage)
    : inner = switch (stage) {
        CrossingStage.idle => brand,
        CrossingStage.analyzing => const Color(0xFFF2B15C),
        CrossingStage.wait => const Color(0xFFF5C37E),
        CrossingStage.safe => brand,
      },
      outer = switch (stage) {
        CrossingStage.idle => brand,
        CrossingStage.analyzing => const Color(0xFFFCE1BA),
        CrossingStage.wait => const Color(0xFFFBEAD0),
        CrossingStage.safe => brand,
      };

  final Color inner;
  final Color outer;
}

class _CrossCopy {
  _CrossCopy(this.stage);

  final CrossingStage stage;

  IconData get icon => switch (stage) {
    CrossingStage.idle => Icons.play_arrow_rounded,
    CrossingStage.analyzing => Icons.speed,
    CrossingStage.wait => Icons.schedule,
    CrossingStage.safe => Icons.check,
  };

  String get title => switch (stage) {
    CrossingStage.idle => 'Check crossing safety',
    CrossingStage.analyzing => 'Analyzing signals',
    CrossingStage.wait => 'Please wait',
    CrossingStage.safe => 'Safe to cross',
  };

  String get subtitle => switch (stage) {
    CrossingStage.idle =>
      'Tap the button to confirm surroundings before crossing.',
    CrossingStage.analyzing =>
      'Hold on while we sense traffic noise and look for signals.',
    CrossingStage.wait =>
      'Wait for the signal to change. Stay alert and watch for vehicles.',
    CrossingStage.safe =>
      "Traffic signals indicate it's safe. Look both ways and cross carefully.",
  };
}

class _ReportTab extends StatefulWidget {
  const _ReportTab({required this.onEnsureLocation});

  final Future<void> Function() onEnsureLocation;

  @override
  State<_ReportTab> createState() => _ReportTabState();
}

class _ReportTabState extends State<_ReportTab> {
  final _controller = TextEditingController();
  final _categories = const [
    _ReportCategory(
      'Unsafe signal',
      'Malfunctioning or unclear traffic light',
      Icons.warning_amber_rounded,
      Color(0xFFF7C27C),
    ),
    _ReportCategory(
      'Accident',
      'Recent accident at crossing',
      Icons.shield,
      Color(0xFFF4978E),
    ),
    _ReportCategory(
      'Road hazard',
      'Obstruction or dangerous condition',
      Icons.report_problem,
      Color(0xFFFDD086),
    ),
    _ReportCategory(
      'Construction',
      'Road work affecting pedestrians',
      Icons.engineering,
      Color(0xFFB0B6B9),
    ),
    _ReportCategory(
      'Poor visibility',
      'Lighting or signage issues',
      Icons.lightbulb_outline,
      Color(0xFFF4CA7A),
    ),
    _ReportCategory(
      'Other issue',
      'Different safety concern',
      Icons.location_searching,
      Color(0xFF63C596),
    ),
  ];

  _ReportCategory? _selected;
  bool _submitted = false;
  bool _locationPrompted = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_handleTextChanged);
  }

  void _handleTextChanged() {
    final typedLetters = _controller.text.replaceAll(RegExp(r'\s+'), '');
    if (!_locationPrompted && typedLetters.length >= 2) {
      _locationPrompted = true;
      unawaited(widget.onEnsureLocation());
    }
    setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_handleTextChanged);
    _controller.dispose();
    super.dispose();
  }

  int get _wordCount => _controller.text
      .trim()
      .split(RegExp(r'\s+'))
      .where((word) => word.isNotEmpty)
      .length;

  bool get _canSubmit => _selected != null && _wordCount >= 10;

  Future<void> _handleSubmit() async {
    await widget.onEnsureLocation();
    setState(() => _submitted = true);
  }

  void _reset() {
    setState(() {
      _submitted = false;
      _selected = null;
      _locationPrompted = false;
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_submitted) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: .15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check,
                  size: 56,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Report submitted',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Thank you for helping keep our community safe. We'll review your report shortly.",
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _reset,
                child: const Text('Report another issue'),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Report an issue',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Help us improve safety by reporting concerns',
            style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: _categories
                .map(
                  (category) => _ReportCategoryCard(
                    category: category,
                    isSelected: category == _selected,
                    onTap: () => setState(() => _selected = category),
                  ),
                )
                .toList(),
          ),
          if (_selected != null) ...[
            const SizedBox(height: 24),
            _HomeCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(_selected!.icon, color: Colors.black54),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selected!.title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _selected!.subtitle,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Location',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _LocationCard(theme: theme),
                  const SizedBox(height: 20),
                  Text(
                    'Additional details (required minimum 10 words)',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _controller,
                    minLines: 4,
                    maxLines: 6,
                    decoration: InputDecoration(
                      hintText:
                          'Tell us more about the issue... (at least 10 words)',
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _canSubmit
                        ? 'Looks good! $_wordCount words written.'
                        : 'Write ${10 - _wordCount} more word(s) to enable submit.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: _canSubmit
                          ? theme.colorScheme.primary
                          : Colors.redAccent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _reset,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: FilledButton(
                          onPressed: _canSubmit ? _handleSubmit : null,
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: _canSubmit
                                ? theme.colorScheme.primary
                                : Colors.grey[400],
                            disabledBackgroundColor: Colors.grey[300],
                          ),
                          child: const Text('Submit report'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ReportCategory {
  const _ReportCategory(this.title, this.subtitle, this.icon, this.color);

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
}

class _ReportCategoryCard extends StatelessWidget {
  const _ReportCategoryCard({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  final _ReportCategory category;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 150,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            width: 2,
            color: isSelected ? theme.colorScheme.primary : Colors.transparent,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .05),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: category.color.withValues(alpha: .18),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                category.icon,
                color: category.color.darken(),
                size: 28,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              category.title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              category.subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  const _LocationCard({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Icon(Icons.my_location, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current location',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '123 Main Street, Downtown',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTab extends StatefulWidget {
  const _SettingsTab();

  @override
  State<_SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<_SettingsTab> {
  late bool pushNotifications;
  late bool soundAlerts;
  late bool flashBeacon;
  bool darkMode = false;

  @override
  void initState() {
    super.initState();
    final manager = SafecrossServiceManager.instance;
    pushNotifications = manager.pushNotificationsEnabled;
    soundAlerts = manager.soundAlertsEnabled;
    flashBeacon = manager.flashBeaconEnabled;
  }

  void _updatePushNotifications(bool value) {
    setState(() => pushNotifications = value);
    SafecrossServiceManager.instance.updatePushNotifications(value);
  }

  void _updateSoundAlerts(bool value) {
    setState(() => soundAlerts = value);
    SafecrossServiceManager.instance.updateSoundAlerts(value);
  }

  void _updateFlashBeacon(bool value) {
    setState(() => flashBeacon = value);
    SafecrossServiceManager.instance.updateFlashBeacon(value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Settings',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Customize your safety experience',
            style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          Text(
            'Alerts & notifications',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _SettingToggle(
            icon: Icons.notifications_active_outlined,
            label: 'Push notifications',
            description: 'Get alerts about nearby crossings',
            value: pushNotifications,
            onChanged: _updatePushNotifications,
          ),
          _SettingToggle(
            icon: Icons.volume_up_outlined,
            label: 'Sound alerts',
            description: 'Audio feedback for crossing status',
            value: soundAlerts,
            onChanged: _updateSoundAlerts,
          ),
          _SettingToggle(
            icon: Icons.flash_on,
            label: 'Flash beacon',
            description: 'Blink flashlight when it is safe to cross',
            value: flashBeacon,
            onChanged: _updateFlashBeacon,
          ),
          const SizedBox(height: 24),
          Text(
            'Accessibility',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _SettingToggle(
            icon: Icons.nightlight_round,
            label: 'Dark mode',
            description: 'Use dark theme',
            value: darkMode,
            onChanged: (value) => setState(() => darkMode = value),
          ),
          const SizedBox(height: 24),
          Text(
            'Information',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const _InfoTile(
            icon: Icons.info_outline,
            title: 'About SafeCross',
            subtitle: 'Version 1.0.0',
          ),
          const _InfoTile(
            icon: Icons.help_outline,
            title: 'Help & support',
            subtitle: 'Get assistance',
          ),
          const _InfoTile(
            icon: Icons.mail_outline,
            title: 'Contact us',
            subtitle: 'Send us feedback',
          ),
          const SizedBox(height: 24),
          _HomeCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.verified_user, color: theme.colorScheme.primary),
                    const SizedBox(width: 12),
                    Text(
                      'Your privacy matters',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  "SafeCross is designed with privacy in mind. We don't collect personal information and all data stays on your device.",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Column(
              children: [
                Text(
                  'SafeCross v1.0.0',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  'Made with care for pedestrian safety',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingToggle extends StatelessWidget {
  const _SettingToggle({
    required this.icon,
    required this.label,
    required this.description,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final String description;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .05),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .05),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right),
        ],
      ),
    );
  }
}

class _Insight {
  const _Insight(this.title, this.subtitle, this.icon);

  final String title;
  final String subtitle;
  final IconData icon;
}

extension ColorBrightness on Color {
  Color darken([double amount = .15]) {
    final hsl = HSLColor.fromColor(this);
    final lightness = (hsl.lightness - amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }
}
