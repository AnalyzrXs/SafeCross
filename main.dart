import 'package:flutter/material.dart';

void main() {
  runApp(const SafeCrossApp());
}

class SafeCrossApp extends StatelessWidget {
  const SafeCrossApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seedColor = Color(0xFF0E7C4F);
    return MaterialApp(
      title: 'SafeCross',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F7F4),
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.light,
        ),
        textTheme: Typography.englishLike2021.apply(
          fontFamily: 'Roboto',
        ),
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
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _buildBody()),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.traffic_outlined), selectedIcon: Icon(Icons.traffic), label: 'Cross'),
          NavigationDestination(icon: Icon(Icons.report_outlined), selectedIcon: Icon(Icons.report), label: 'Report'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return const _HomeTab();
      case 1:
        return const _PlaceholderTab(title: 'Cross');
      case 2:
        return const _PlaceholderTab(title: 'Report');
      case 3:
        return const _PlaceholderTab(title: 'Settings');
      default:
        return const _HomeTab();
    }
  }
}

class _PlaceholderTab extends StatelessWidget {
  const _PlaceholderTab({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '$title screen coming soon',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final insights = const [
      'Use pedestrian lights',
      '3 safe crossings nearby',
      'High visibility today',
    ];
    final weeklyActivity = const [
      ('Mon', .45),
      ('Tue', .7),
      ('Wed', .6),
      ('Thu', .8),
      ('Fri', .9),
      ('Sat', .5),
      ('Sun', .35),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Good evening',
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.grey[700],
                fontWeight: FontWeight.w600,
              )),
          const SizedBox(height: 4),
          Text(
            'Stay safe out there',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 24),
          _SafetyScoreCard(theme: theme),
          const SizedBox(height: 20),
          _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Safety insights',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                ...insights.map(
                  (insight) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.check_rounded, color: theme.colorScheme.primary),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            insight,
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
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
          _CurrentRiskCard(theme: theme),
          const SizedBox(height: 20),
          _WalkingPatternCard(theme: theme, weeklyActivity: weeklyActivity),
          const SizedBox(height: 20),
          _StatisticsRow(theme: theme),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  static Widget _buildCard({required Widget child, Color? color}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color ?? Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SafetyScoreCard extends StatelessWidget {
  const _SafetyScoreCard({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0E7C4F), Color(0xFF1FC77A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0E7C4F).withOpacity(.35),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.shield, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Your Safety Score',
                    style: theme.textTheme.titleMedium?.copyWith(color: Colors.white70)),
                const SizedBox(height: 4),
                Text('Excellent',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    )),
                const SizedBox(height: 12),
                Text(
                  "You've made 47 safe crossings this week. Keep watching signals and maintaining visibility!",
                  style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white.withOpacity(.9)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CurrentRiskCard extends StatelessWidget {
  const _CurrentRiskCard({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return _HomeTab._buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Current risk factor',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('Low',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    )),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('25',
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  )),
              const SizedBox(width: 8),
              Text('Safe index', style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey[600])),
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
            spacing: 12,
            runSpacing: 8,
            children: const [
              _RiskTag(label: 'Clear conditions'),
              _RiskTag(label: 'Good visibility'),
            ],
          ),
        ],
      ),
    );
  }
}

class _RiskTag extends StatelessWidget {
  const _RiskTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(.08),
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
  const _WalkingPatternCard({required this.theme, required this.weeklyActivity});

  final ThemeData theme;
  final List<(String, double)> weeklyActivity;

  @override
  Widget build(BuildContext context) {
    return _HomeTab._buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Walking pattern',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _PatternStat(label: 'Peak time', value: '8:00 AM'),
              _PatternStat(label: 'Daily avg', value: '7'),
              _PatternStat(label: 'Weekly change', value: '+12%'),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: weeklyActivity
                .map(
                  (entry) => Expanded(
                    child: _ActivityBar(label: entry.$1, value: entry.$2),
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
  const _PatternStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600])),
        const SizedBox(height: 4),
        Text(value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            )),
      ],
    );
  }
}

class _ActivityBar extends StatelessWidget {
  const _ActivityBar({required this.label, required this.value});

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 120 * value,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary.withOpacity(.2),
                  theme.colorScheme.primary,
                ],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              )),
        ],
      ),
    );
  }
}

class _StatisticsRow extends StatelessWidget {
  const _StatisticsRow({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _HomeTab._buildCard(
            color: Colors.white,
            child: _StatCardContent(
              label: 'This week',
              value: '47',
              subtitle: 'Safe crossings',
              theme: theme,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _HomeTab._buildCard(
            color: Colors.white,
            child: _StatCardContent(
              label: 'Total',
              value: '342',
              subtitle: 'Safe crossings',
              theme: theme,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatCardContent extends StatelessWidget {
  const _StatCardContent({
    required this.label,
    required this.value,
    required this.subtitle,
    required this.theme,
  });

  final String label;
  final String value;
  final String subtitle;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600])),
        const SizedBox(height: 8),
        Text(value,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            )),
        const SizedBox(height: 4),
        Text(subtitle, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
