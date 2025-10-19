import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'quiz_screen.dart';
import '../../app.dart';
import 'learning_mode_screen.dart';
import 'mock_exam_rules_screen.dart';
import 'progress_screen.dart';
import '../data/states.dart';
import '../core/prefs.dart';
import '../analytics/progress_repository.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _selectedStateCode;
  final GlobalKey _menuKey = GlobalKey();
  double get _menuWidth {
    // Keep it compact: at most 200px wide and at most 40% of screen width
    final screenW = MediaQuery.of(context).size.width;
    return math.min(200.0, screenW * 0.4);
  }

  @override
  void initState() {
    super.initState();
    _loadSavedState();
  }

  Future<void> _loadSavedState() async {
    final code = await AppPrefs.getSelectedState();
    if (!mounted) return;
    setState(() {
      _selectedStateCode = code;
    });
  }

  String? get _selectedStateLabel {
    if (_selectedStateCode == null) return null;
    final match = states.firstWhere(
      (s) => s['code'] == _selectedStateCode,
      orElse: () => {},
    );
    return match['label'];
  }

  void _onSelectState(String code) {
    setState(() {
      _selectedStateCode = code;
    });
    AppPrefs.saveSelectedState(code);
    final label = _selectedStateLabel ?? code;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Selected state: $label')),
    );
  }

  RelativeRect _menuPosition() {
    final RenderBox button = _menuKey.currentContext!.findRenderObject() as RenderBox;
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final Offset position = button.localToGlobal(Offset.zero, ancestor: overlay);
    return RelativeRect.fromRect(
      Rect.fromLTWH(position.dx, position.dy + button.size.height, button.size.width, 0),
      Offset.zero & overlay.size,
    );
  }

  Future<void> _showMainMenu() async {
    final selected = await showMenu<String>(
      context: context,
      position: _menuPosition(),
      items: [
        PopupMenuItem(value: 'language', child: SizedBox(width: _menuWidth, child: Text('Language', style: Theme.of(context).textTheme.bodySmall))),
        PopupMenuItem(value: 'state', child: SizedBox(width: _menuWidth, child: Text('State', style: Theme.of(context).textTheme.bodySmall))),
        PopupMenuItem(value: 'theme', child: SizedBox(width: _menuWidth, child: Text('Theme', style: Theme.of(context).textTheme.bodySmall))),
        PopupMenuItem(value: 'reset', child: SizedBox(width: _menuWidth, child: Text('Reset Analyse', style: Theme.of(context).textTheme.bodySmall))),
      ],
    );
    switch (selected) {
      case 'language':
        _showLanguageMenu();
        break;
      case 'state':
        _showStateMenu();
        break;
      case 'theme':
        _showThemeMenu();
        break;
      case 'reset':
        _showResetMenu();
        break;
    }
  }

  Future<void> _showLanguageMenu() async {
    final choice = await showMenu<String>(
      context: context,
      position: _menuPosition(),
      items: [
        PopupMenuItem(
          value: 'back',
          child: SizedBox(
            width: _menuWidth,
            child: Row(
              children: [
                const Icon(Icons.arrow_back, size: 24),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Language',
                    style: Theme.of(context).textTheme.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
        PopupMenuItem(value: 'de', child: SizedBox(width: _menuWidth, child: Text('Deutsch', style: Theme.of(context).textTheme.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis))),
        PopupMenuItem(value: 'en', child: SizedBox(width: _menuWidth, child: Text('English', style: Theme.of(context).textTheme.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis))),
      ],
    );
    if (choice == null) return;
    if (choice == 'back') {
      _showMainMenu();
      return;
    }
    await AppPrefs.saveLocale(choice);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Language set to ${choice.toUpperCase()}')),
    );
    // Return to main menu for continued navigation
    _showMainMenu();
  }

  Future<void> _showStateMenu() async {
    // Build items: Back + all states
    final items = <PopupMenuEntry<String>>[
      PopupMenuItem(
        value: 'back',
        child: SizedBox(
          width: _menuWidth,
          child: Row(
            children: [
              const Icon(Icons.arrow_back, size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'State',
                  style: Theme.of(context).textTheme.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    ];
    for (final s in states) {
      final code = s['code']!;
      final label = s['label']!;
      items.add(PopupMenuItem(value: code, child: SizedBox(width: _menuWidth, child: Text(label, style: Theme.of(context).textTheme.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis))));
    }
    final choice = await showMenu<String>(
      context: context,
      position: _menuPosition(),
      items: items,
    );
    if (choice == null) return;
    if (choice == 'back') {
      _showMainMenu();
      return;
    }
    _onSelectState(choice);
    _showMainMenu();
  }

  Future<void> _showResetMenu() async {
    final choice = await showMenu<String>(
      context: context,
      position: _menuPosition(),
      items: [
        PopupMenuItem(
          value: 'back',
          child: SizedBox(
            width: _menuWidth,
            child: Row(
              children: [
                const Icon(Icons.arrow_back, size: 24),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Reset Analyse',
                    style: Theme.of(context).textTheme.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
        PopupMenuItem(
          value: 'reset_practice',
          child: SizedBox(
            width: _menuWidth,
            child: Text(
              'Lernen/Quiz zurücksetzen',
              style: Theme.of(context).textTheme.bodySmall,
              softWrap: true,
            ),
          ),
        ),
        PopupMenuItem(
          value: 'reset_exam',
          child: SizedBox(
            width: _menuWidth,
            child: Text(
              'Prüfung zurücksetzen',
              style: Theme.of(context).textTheme.bodySmall,
              softWrap: true,
            ),
          ),
        ),
      ],
    );
    if (choice == null) return;
    if (choice == 'back') {
      _showMainMenu();
      return;
    }
    if (choice == 'reset_practice') {
      await ProgressRepository.instance.clearByMode(SessionMode.practice);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Analyse: Lernen/Quiz zurückgesetzt')));
      _showMainMenu();
      return;
    }
    if (choice == 'reset_exam') {
      await ProgressRepository.instance.clearByMode(SessionMode.exam);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Analyse: Prüfung zurückgesetzt')));
      _showMainMenu();
      return;
    }
  }

  Future<void> _showThemeMenu() async {
    final choice = await showMenu<String>(
      context: context,
      position: _menuPosition(),
      items: [
        PopupMenuItem(
          value: 'back',
          child: SizedBox(
            width: _menuWidth,
            child: Row(
              children: [
                const Icon(Icons.arrow_back, size: 24),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Theme',
                    style: Theme.of(context).textTheme.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
        PopupMenuItem(value: 'system', child: SizedBox(width: _menuWidth, child: Text('System', style: Theme.of(context).textTheme.bodySmall))),
        PopupMenuItem(value: 'light', child: SizedBox(width: _menuWidth, child: Text('Light', style: Theme.of(context).textTheme.bodySmall))),
        PopupMenuItem(value: 'dark', child: SizedBox(width: _menuWidth, child: Text('Dark', style: Theme.of(context).textTheme.bodySmall))),
      ],
    );
    if (choice == null) return;
    if (choice == 'back') {
      _showMainMenu();
      return;
    }
    // Update app theme
    final appState = App.of(context);
    if (appState != null) {
      switch (choice) {
        case 'light':
          await appState.setThemeMode(ThemeMode.light);
          break;
        case 'dark':
          await appState.setThemeMode(ThemeMode.dark);
          break;
        default:
          await appState.setThemeMode(ThemeMode.system);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Theme: ${choice[0].toUpperCase()}${choice.substring(1)}')));
      // Do not auto-reopen the menu; reopening immediately can render with stale theme.
      // Let the user open the menu again if needed.
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final onPrimary = colorScheme.onPrimary;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Citizenship Test Quiz"),
        actions: [
          IconButton(
            key: _menuKey,
            tooltip: 'Menu',
            icon: const Icon(Icons.more_vert),
            onPressed: _showMainMenu,
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 900;
          final isMedium = constraints.maxWidth >= 600 && constraints.maxWidth < 900;
          final crossAxisCount = isWide ? 4 : 2;
          final headerHeight = isWide ? 220.0 : 200.0;
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Container(
                  height: headerHeight,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primary,
                        colorScheme.primaryContainer.withValues(alpha: 0.85),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Citizenship Test',
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                        color: onPrimary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Learn, practice and pass the test',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: onPrimary.withValues(alpha: 0.9)),
                                ),
                                const SizedBox(height: 12),
                                if (_selectedStateLabel != null)
                                  _StateChip(label: _selectedStateLabel!, code: _selectedStateCode, onPrimary: onPrimary)
                                else
                                  Text('No state selected', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: onPrimary.withValues(alpha: 0.9))),
                              ],
                            ),
                          ),
                          if (!isMedium && !isWide)
                            const SizedBox(width: 8)
                          else
                            const SizedBox(width: 12),
                          Icon(Icons.school, size: isWide ? 96 : 80, color: onPrimary.withValues(alpha: 0.95)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: isWide ? 1.3 : 1.1,
                  ),
                  delegate: SliverChildListDelegate([
                    _ActionCard(
                      icon: Icons.lightbulb_outline,
                      label: 'Lernen',
                      color: colorScheme.primary,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => LearningModeScreen(
                              stateCode: _selectedStateCode,
                              stateLabel: _selectedStateLabel,
                            ),
                          ),
                        );
                      },
                      semanticsLabel: 'Lernen öffnen',
                    ),
                    _ActionCard(
                      icon: Icons.quiz_outlined,
                      label: 'Quiz',
                      color: colorScheme.tertiary,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const QuizScreen()),
                        );
                      },
                      semanticsLabel: 'Quiz öffnen',
                    ),
                    _ActionCard(
                      icon: Icons.assignment_outlined,
                      label: 'Prüfung',
                      color: colorScheme.secondary,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const MockExamRulesScreen()),
                        );
                      },
                      semanticsLabel: 'Prüfung öffnen',
                    ),
                    // Analyse must remain last
                    _ActionCard(
                      icon: Icons.insights_outlined,
                      label: 'Analyse',
                      color: colorScheme.surfaceTint,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ProgressScreen()),
                        );
                      },
                      semanticsLabel: 'Analyse öffnen',
                    ),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: null,
    );
  }
}

class _StateChip extends StatelessWidget {
  final String label;
  final String? code;
  final Color onPrimary;
  const _StateChip({required this.label, required this.code, required this.onPrimary});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: onPrimary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: onPrimary.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.location_on_outlined, size: 16, color: onPrimary),
          const SizedBox(width: 6),
          Text(
            code == null ? label : label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: onPrimary),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;
  final String semanticsLabel;
  const _ActionCard({required this.icon, required this.label, required this.onTap, required this.color, required this.semanticsLabel});

  @override
  State<_ActionCard> createState() => _ActionCardState();
}

class _ActionCardState extends State<_ActionCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
  final bg = Theme.of(context).brightness == Brightness.dark
    ? Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4)
    : Colors.white;
    final iconColor = widget.color;
    return Semantics(
      button: true,
      label: widget.semanticsLabel,
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        tween: Tween(begin: 1.0, end: _pressed ? 0.98 : 1.0),
        builder: (context, scale, child) {
          return Transform.scale(
            scale: scale,
            child: Material(
              color: bg,
              elevation: 2,
              borderRadius: BorderRadius.circular(16),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: widget.onTap,
                onHighlightChanged: (v) => setState(() => _pressed = v),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: 44,
                        width: 44,
                        decoration: BoxDecoration(
                          color: iconColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(widget.icon, color: iconColor, size: 26),
                      ),
                      Text(
                        widget.label,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Overlay that paints the German flag (black-red-gold) on the right side and
/// fades it towards transparent at the halfway point.
// (German flag overlay widget removed as requested)
