import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../core/prefs.dart';
import '../data/states.dart';
import 'home_screen.dart';
import '../../app.dart';
import 'package:flutter_localized_locales/flutter_localized_locales.dart';

class InitialSetupScreen extends StatefulWidget {
  const InitialSetupScreen({super.key});

  @override
  State<InitialSetupScreen> createState() => _InitialSetupScreenState();
}

class _InitialSetupScreenState extends State<InitialSetupScreen> with SingleTickerProviderStateMixin {
  String? _selectedCode;
  bool _saving = false;
  String _locale = 'de';

  late final AnimationController _anim;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
  _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 360));
  // Keep scale <= 1.0 to avoid overshoot-caused pixel overflows on small screens
  _scale = Tween(begin: 0.94, end: 1.0).animate(CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic));
    _anim.forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    if (_selectedCode == null) return;
    setState(() => _saving = true);
    await AppPrefs.saveSelectedState(_selectedCode!);
    await AppPrefs.saveLocale(_locale);
    if (!mounted) return;

    // Also update the running app's locale so the language switches immediately
    final appState = App.of(context);
    if (appState != null) {
      await appState.setLocale(Locale(_locale));
    }

    if (!mounted) return;
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  // Main content scrolls, button stays pinned at bottom
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ScaleTransition(
                                scale: _scale,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            theme.colorScheme.primary,
                                            theme.colorScheme.secondary.withAlpha(220),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                                      ),
                                      padding: const EdgeInsets.all(12),
                                      child: const Icon(Icons.map, color: Colors.white, size: 28),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Wähle dein Bundesland',
                                            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            'Dieses Bundesland wird für landesspezifische Fragen genutzt.',
                                            style: theme.textTheme.bodyMedium?.copyWith(
                                              color:
                                                  theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 28),
                              Text(
                                'Bitte Bundesland wählen',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _SetupSelector(
                                icon: Icons.location_on,
                                value: _selectedCode,
                                labelBuilder: (context) => 'Bitte Bundesland wählen',
                                items: states
                                    .map((m) => _SelectorItem(
                                          value: m['code'] as String,
                                          label: '${m['label']} (${m['code']})',
                                        ))
                                    .toList(),
                                onChanged: (v) => setState(() => _selectedCode = v),
                                filledStyle: true,
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'Sprache:',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _SetupSelector(
                                icon: Icons.language,
                                value: _locale,
                                labelBuilder: (context) => 'Sprache:',
                                items: ['de', 'en']
                                    .map((code) {
                                      final name = LocaleNames.of(context)?.nameOf(code) ?? code;
                                      return _SelectorItem(value: code, label: '$name ($code)');
                                    })
                                    .toList(),
                                onChanged: (v) => setState(() => _locale = v ?? 'de'),
                                filledStyle: true,
                              ),
                              const SizedBox(height: 32),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Bottom primary action, visually more prominent
                  SizedBox(
                    width: double.infinity,
                    child: SizedBox(
                      height: 56,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          textStyle: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                          ),
                        ),
                        onPressed: (_selectedCode == null || _saving) ? null : _confirm,
                        child: _saving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Text('Speichern und fortfahren'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SelectorItem {
  final String value;
  final String label;
  const _SelectorItem({required this.value, required this.label});
}

class _SetupSelector extends StatelessWidget {
  final IconData icon;
  final String? value;
  final List<_SelectorItem> items;
  final ValueChanged<String?> onChanged;
  final String Function(BuildContext) labelBuilder;
  final bool filledStyle;

  const _SetupSelector({
    required this.icon,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.labelBuilder,
    this.filledStyle = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = (value == null || items.isEmpty)
      ? labelBuilder(context)
      : items.firstWhere((e) => e.value == value, orElse: () => items.first).label;

    return InkWell(
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      onTap: () async {
        final selected = await showModalBottomSheet<String>(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusLarge)),
          ),
          builder: (ctx) {
            return SafeArea(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: items.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (ctx, index) {
                  final item = items[index];
                  final isSelected = item.value == value;
                  return ListTile(
                    leading: isSelected
                        ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
                        : const Icon(Icons.circle_outlined),
                    title: Text(item.label),
                    onTap: () => Navigator.of(ctx).pop(item.value),
                  );
                },
              ),
            );
          },
        );
        if (selected != null) onChanged(selected);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          color: filledStyle ? theme.colorScheme.primary : theme.colorScheme.surface,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: filledStyle ? theme.colorScheme.onPrimary : theme.colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: (filledStyle
                        ? theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onPrimary)
                        : theme.textTheme.bodyMedium)
                    ?.copyWith(fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: filledStyle ? theme.colorScheme.onPrimary : theme.iconTheme.color,
            ),
          ],
        ),
      ),
    );
  }
}
