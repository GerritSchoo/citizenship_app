import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'quiz_screen.dart';
import '../../app.dart';
import 'learning_mode_screen.dart';
import 'mock_exam_rules_screen.dart';
import 'progress_screen.dart';
import 'achievements_screen.dart';
import '../data/states.dart';
import '../core/prefs.dart';
import '../analytics/progress_repository.dart';
import '../../l10n/app_localizations.dart';
import 'package:flutter_localized_locales/flutter_localized_locales.dart';

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
  final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.snack_state_selected(label))),
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
  PopupMenuItem(value: 'language', child: SizedBox(width: _menuWidth, child: Text(AppLocalizations.of(context).menu_language, style: Theme.of(context).textTheme.bodySmall))),
  PopupMenuItem(value: 'state', child: SizedBox(width: _menuWidth, child: Text(AppLocalizations.of(context).menu_state, style: Theme.of(context).textTheme.bodySmall))),
  PopupMenuItem(value: 'theme', child: SizedBox(width: _menuWidth, child: Text(AppLocalizations.of(context).menu_theme, style: Theme.of(context).textTheme.bodySmall))),
        PopupMenuItem(value: 'achievements', child: SizedBox(width: _menuWidth, child: Text(AppLocalizations.of(context).menu_achievements, style: Theme.of(context).textTheme.bodySmall))),
  PopupMenuItem(value: 'analyse', child: SizedBox(width: _menuWidth, child: Text(AppLocalizations.of(context).menu_analyse, style: Theme.of(context).textTheme.bodySmall))),
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
      case 'achievements':
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AchievementsScreen()),
        );
        break;
      case 'analyse':
        _showResetMenu();
        break;
    }
  }

  Future<void> _showLanguageMenu() async {
  final messenger = ScaffoldMessenger.of(context);
  final appState = App.of(context);
    final supported = AppLocalizations.supportedLocales;
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
                Expanded(child: Text(AppLocalizations.of(context).menu_language, style: Theme.of(context).textTheme.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis)),
              ],
            ),
          ),
        ),
        ...supported.map((loc) {
          final code = loc.languageCode;
          final name = LocaleNames.of(context)?.nameOf(code) ?? code;
          return PopupMenuItem(
            value: code,
            child: SizedBox(
              width: _menuWidth,
              child: Text(name, style: Theme.of(context).textTheme.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          );
        }),
      ],
    );
    if (choice == null) return;
    if (choice == 'back') {
      if (!mounted) return;
      _showMainMenu();
      return;
    }
    await AppPrefs.saveLocale(choice);
    if (appState != null) {
      await appState.setLocale(Locale(choice));
    }
    if (!mounted) return;
    final code = choice.toLowerCase();
    final label = LocaleNames.of(context)?.nameOf(code) ?? code;
    messenger.showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).snack_lang_set(label))));
    // Do not auto-reopen the menu; close after applying change for immediate UI refresh
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
                Expanded(child: Text(AppLocalizations.of(context).menu_state, style: Theme.of(context).textTheme.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis)),
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
      if (!mounted) return;
      _showMainMenu();
      return;
    }
    _onSelectState(choice);
    // Do not auto-reopen the menu; close after applying change
  }

  Future<void> _showResetMenu() async {
    final messenger = ScaffoldMessenger.of(context);
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
                Expanded(child: Text(AppLocalizations.of(context).menu_analyse, style: Theme.of(context).textTheme.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis)),
              ],
            ),
          ),
        ),
        PopupMenuItem(
          value: 'reset_all',
          child: SizedBox(
            width: _menuWidth,
            child: Text(
              AppLocalizations.of(context).reset_all,
              style: Theme.of(context).textTheme.bodySmall,
              softWrap: true,
            ),
          ),
        ),
        PopupMenuItem(
          value: 'reset_practice',
          child: SizedBox(
            width: _menuWidth,
            child: Text(
              AppLocalizations.of(context).reset_practice,
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
              AppLocalizations.of(context).reset_exam,
              style: Theme.of(context).textTheme.bodySmall,
              softWrap: true,
            ),
          ),
        ),
      ],
    );
    if (choice == null) return;
    if (choice == 'back') {
      if (!mounted) return;
      _showMainMenu();
      return;
    }
    if (choice == 'reset_all') {
      await ProgressRepository.instance.clearAll();
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).snack_reset_all)));
      return;
    }
    if (choice == 'reset_practice') {
      await ProgressRepository.instance.clearByMode(SessionMode.practice);
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).snack_reset_practice)));
      return;
    }
    if (choice == 'reset_exam') {
      await ProgressRepository.instance.clearByMode(SessionMode.exam);
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).snack_reset_exam)));
      return;
    }
  }

  Future<void> _showThemeMenu() async {
    final appState = App.of(context); // capture before awaiting
    final messenger = ScaffoldMessenger.of(context);
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
                    AppLocalizations.of(context).menu_theme,
                    style: Theme.of(context).textTheme.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
  PopupMenuItem(value: 'system', child: SizedBox(width: _menuWidth, child: Text(AppLocalizations.of(context).theme_system, style: Theme.of(context).textTheme.bodySmall))),
  PopupMenuItem(value: 'light', child: SizedBox(width: _menuWidth, child: Text(AppLocalizations.of(context).theme_light, style: Theme.of(context).textTheme.bodySmall))),
  PopupMenuItem(value: 'dark', child: SizedBox(width: _menuWidth, child: Text(AppLocalizations.of(context).theme_dark, style: Theme.of(context).textTheme.bodySmall))),
      ],
    );
    if (choice == null) return;
    if (choice == 'back') {
      if (!mounted) return;
      _showMainMenu();
      return;
    }
    // Update app theme
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
  messenger.showSnackBar(SnackBar(content: Text('${AppLocalizations.of(context).menu_theme}: ${choice == 'system' ? AppLocalizations.of(context).theme_system : choice == 'light' ? AppLocalizations.of(context).theme_light : AppLocalizations.of(context).theme_dark}')));
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
  title: Text(AppLocalizations.of(context).app_title),
        actions: [
          IconButton(
            key: _menuKey,
            tooltip: AppLocalizations.of(context).menu,
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
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
                  child: SizedBox(
                    height: headerHeight,
                    width: double.infinity,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Base blue gradient background
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                colorScheme.primary,
                                colorScheme.primaryContainer.withValues(alpha: 0.85),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                        ),
                        // German flag overlay on the right, fading towards center, diagonal coverage
                        CustomPaint(
                          painter: _GermanFlagGradientPainter(
                            topCoverageFraction: 1 / 3,
                            bottomCoverageFraction: 1 / 2,
                          ),
                        ),
                        // Foreground content
                        SafeArea(
                          bottom: false,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Text column expands to take available space next to the icon
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        AppLocalizations.of(context).home_header_title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                              color: onPrimary,
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        AppLocalizations.of(context).home_header_subtitle,
                                        maxLines: 2,
                                        softWrap: true,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: onPrimary.withValues(alpha: 0.9)),
                                      ),
                                      const SizedBox(height: 12),
                                      if (_selectedStateLabel != null)
                                        _StateChip(label: _selectedStateLabel!, code: _selectedStateCode, onPrimary: onPrimary)
                                      else
                                        Text(
                                          AppLocalizations.of(context).home_no_state,
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: onPrimary.withValues(alpha: 0.9)),
                                        ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: isWide ? 12 : 8),
                                Icon(
                                  Icons.school,
                                  size: isWide ? 96 : (isMedium ? 80 : 64),
                                  color: onPrimary.withValues(alpha: 0.95),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
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
                      label: AppLocalizations.of(context).action_learn,
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
                      semanticsLabel: AppLocalizations.of(context).action_learn_sem,
                    ),
                    _ActionCard(
                      icon: Icons.quiz_outlined,
                      label: AppLocalizations.of(context).action_quiz,
                      color: colorScheme.tertiary,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const QuizScreen()),
                        );
                      },
                      semanticsLabel: AppLocalizations.of(context).action_quiz_sem,
                    ),
                    _ActionCard(
                      icon: Icons.assignment_outlined,
                      label: AppLocalizations.of(context).action_exam,
                      color: colorScheme.secondary,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const MockExamRulesScreen()),
                        );
                      },
                      semanticsLabel: AppLocalizations.of(context).action_exam_sem,
                    ),
                    // Analyse must remain last
                    _ActionCard(
                      icon: Icons.insights_outlined,
                      label: AppLocalizations.of(context).action_analytics,
                      color: colorScheme.surfaceTint,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ProgressScreen()),
                        );
                      },
                      semanticsLabel: AppLocalizations.of(context).action_analytics_sem,
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
                // Remove default splash/highlight to avoid lingering highlight when returning
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                hoverColor: Colors.transparent,
                focusColor: Colors.transparent,
                splashFactory: NoSplash.splashFactory,
                onTap: () {
                  // Ensure pressed state is cleared before navigating away
                  if (mounted) setState(() => _pressed = false);
                  widget.onTap();
                },
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
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
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

/// Custom painter for the German flag overlay (black, red, gold) on the right
/// side of the header, fading towards transparent as it approaches the center.
class _GermanFlagGradientPainter extends CustomPainter {
  /// Fraction of total width covered by the flag at the top edge (0..1).
  final double topCoverageFraction;

  /// Fraction of total width covered by the flag at the bottom edge (0..1).
  final double bottomCoverageFraction;

  const _GermanFlagGradientPainter({
    this.topCoverageFraction = 0.5,
    this.bottomCoverageFraction = 0.5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final topFrac = topCoverageFraction.clamp(0.0, 1.0);
    final bottomFrac = bottomCoverageFraction.clamp(0.0, 1.0);

    double leftXAtY(double y) {
      final t = (y / size.height).clamp(0.0, 1.0);
      final cov = topFrac + (bottomFrac - topFrac) * t; // linear interpolation
      return size.width * (1.0 - cov);
    }

    final stripeHeight = size.height / 3.0;

    void drawStripe(double top, Color color) {
      final topY = top;
      final bottomY = math.min(size.height, top + stripeHeight);
      final leftTop = leftXAtY(topY);
      final leftBottom = leftXAtY(bottomY);

      // Build a slanted quad path for this stripe
      final path = Path()
        ..moveTo(leftTop, topY)
        ..lineTo(size.width, topY)
        ..lineTo(size.width, bottomY)
        ..lineTo(leftBottom, bottomY)
        ..close();

      // Clip to the stripe path and paint a right-to-left fade
      canvas.save();
      canvas.clipPath(path);
      // Compute a gradient that fades along the normal to the slanted left edge
      final midY = (topY + bottomY) * 0.5;
      final leftMidX = (leftTop + leftBottom) * 0.5;
      final edgeDx = leftBottom - leftTop;
      final edgeDy = bottomY - topY; // stripeHeight
      // Perpendicular (normal) vector to the edge
      double nx = edgeDy;
      double ny = -edgeDx;
      final len = math.sqrt(nx * nx + ny * ny);
      if (len > 0) {
        nx /= len;
        ny /= len;
      } else {
        // Fallback to horizontal fade if degenerate
        nx = 1;
        ny = 0;
      }
      final leftMid = Offset(leftMidX, midY);
      final widthToRight = size.width - leftMidX;
      final p0 = leftMid.translate(nx * widthToRight, ny * widthToRight); // opaque at right
      final p1 = leftMid; // transparent at left edge
      final shader = ui.Gradient.linear(
        p0,
        p1,
        [
          color.withValues(alpha: 1.0),
          color.withValues(alpha: 0.0),
        ],
      );
      final paint = Paint()..shader = shader;
      // Fill a rectangle covering the clipped stripe area
      final fillRect = Rect.fromLTRB(math.min(p0.dx, p1.dx), topY, size.width, bottomY);
      canvas.drawRect(fillRect, paint);
      canvas.restore();
    }

    // Draw stripes: black (top), red (middle), gold (bottom)
    drawStripe(0, Colors.black);
    drawStripe(stripeHeight, const Color(0xFFDD0000)); // German flag red
    drawStripe(stripeHeight * 2, const Color(0xFFD4AF37)); // metallic gold
  }

  @override
  bool shouldRepaint(covariant _GermanFlagGradientPainter old) {
    return old.topCoverageFraction != topCoverageFraction || old.bottomCoverageFraction != bottomCoverageFraction;
  }
}
