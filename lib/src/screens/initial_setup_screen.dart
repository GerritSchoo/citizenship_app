import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../core/prefs.dart';
import '../data/states.dart';
import '../payments/purchase_service.dart';
import 'disclaimer_screen.dart';
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
  String _uiLocale = 'de';
  String _contentLocale = 'de';

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

  static const _premiumContentLangs = {'fr', 'es', 'tr', 'ru', 'uk', 'ar'};

  void _showContentLangPremiumSheet() {
    final isDe = _uiLocale == 'de';
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusLarge)),
      ),
      builder: (ctx) => SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(24, 24, 24, 32 + MediaQuery.viewInsetsOf(ctx).bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_outline, size: 48, color: Theme.of(ctx).colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              isDe ? 'Premium-Funktion' : 'Premium Feature',
              style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              isDe
                  ? 'Fragen-Übersetzungen in AR, ES, FR, RU, TR und UK sind im Premium-Abonnement enthalten. Englisch und Deutsch sind kostenlos.'
                  : 'Question translations in AR, ES, FR, RU, TR and UK are included in Premium. English and German are free.',
              style: Theme.of(ctx).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              isDe
                  ? 'Du kannst jetzt fortfahren und nach dem Start ein Upgrade durchführen.'
                  : 'You can continue now and upgrade after launch.',
              style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                color: Theme.of(ctx).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => Navigator.pop(ctx),
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
              child: Text(isDe ? 'Verstanden' : 'Got it'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirm() async {
    if (_selectedCode == null) return;
    setState(() => _saving = true);
    
    // Use App state to save and sync memory
    final appState = App.of(context);
    if (appState != null) {
      await appState.setSelectedState(_selectedCode!);
      await AppPrefs.saveLocale(_uiLocale); // Can be moved to AppState too, but this is fine
      await AppPrefs.saveContentLocale(_contentLocale);
    
      await appState.setLocale(Locale(_uiLocale));
      await appState.setContentLocale(_contentLocale);
    } else {
      // Fallback if AppState not found (unlikely)
      await AppPrefs.saveSelectedState(_selectedCode!);
      await AppPrefs.saveLocale(_uiLocale);
      await AppPrefs.saveContentLocale(_contentLocale);
    }

    if (!mounted) return;
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const DisclaimerScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDe = _uiLocale == 'de';

    // Localized strings based on CURRENT selection in this screen
    final titleState = isDe ? 'Wähle dein Bundesland' : 'Choose your state';
    final subTitleState = isDe
        ? 'Dieses Bundesland wird für landesspezifische Fragen genutzt.'
        : 'This will be used for state-specific questions.';
    final labelState = isDe ? 'Bitte Bundesland wählen' : 'Please select a state';
    
    final labelAppLang = isDe ? 'App-Sprache' : 'App Language';
    final labelContentLang = isDe ? 'Übersetzungssprache für Fragen' : 'Question Translation Language';
    final labelContentLangHint = isDe
        ? 'In welcher Sprache sollen die Fragen und Antworten angezeigt werden?'
        : 'In which language should the questions and answers be displayed?';
    final labelSave = isDe ? 'Speichern und fortfahren' : 'Save and continue';

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
                                            titleState,
                                            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            subTitleState,
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
                                labelState,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _SetupSelector(
                                icon: Icons.location_on,
                                value: _selectedCode,
                                labelBuilder: (context) => labelState,
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
                                labelAppLang,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _SetupSelector(
                                icon: Icons.language,
                                value: _uiLocale,
                                labelBuilder: (context) => labelAppLang,
                                items: ['de', 'en']
                                    .map((code) {
                                      final name = LocaleNames.of(context)?.nameOf(code) ?? code;
                                      return _SelectorItem(value: code, label: '$name ($code)');
                                    })
                                    .toList(),
                                onChanged: (v) => setState(() => _uiLocale = v ?? 'de'),
                                filledStyle: true,
                              ),
                              const SizedBox(height: 20),
                              Text(
                                labelContentLang,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                labelContentLangHint,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                ),
                              ),
                              const SizedBox(height: 8),
                              _SetupSelector(
                                icon: Icons.translate,
                                value: _contentLocale,
                                labelBuilder: (context) => labelContentLang,
                                items: ['de', 'en', 'tr', 'ru', 'uk', 'ar', 'fr', 'es']
                                    .map((code) {
                                      final name = LocaleNames.of(context)?.nameOf(code) ?? code;
                                      final isPremium = _premiumContentLangs.contains(code);
                                      return _SelectorItem(
                                        value: code,
                                        label: '$name ($code)',
                                        isPremium: isPremium,
                                      );
                                    })
                                    .toList(),
                                onChanged: (v) {
                                  if (v == null) return;
                                  if (_premiumContentLangs.contains(v) && !PurchaseService.instance.isPro) {
                                    _showContentLangPremiumSheet();
                                    return;
                                  }
                                  setState(() => _contentLocale = v);
                                },
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
                            : Text(labelSave),
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
  final bool isPremium;
  const _SelectorItem({required this.value, required this.label, this.isPremium = false});
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
                separatorBuilder: (context, _) => const Divider(height: 1),
                itemBuilder: (ctx, index) {
                  final item = items[index];
                  final isSelected = item.value == value;
                  return ListTile(
                    leading: isSelected
                        ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
                        : const Icon(Icons.circle_outlined),
                    title: Text(item.label),
                    trailing: item.isPremium
                        ? Icon(Icons.lock_outline,
                            size: 18,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.45))
                        : null,
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
