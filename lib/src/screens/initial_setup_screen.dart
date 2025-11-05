import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../core/prefs.dart';
import '../data/states.dart';
import 'home_screen.dart';
import '../../l10n/app_localizations.dart';
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
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: ScaleTransition(
                  scale: _scale,
                  child: Card(
                    elevation: 12,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMedium)),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 640, minHeight: constraints.maxHeight * 0.75),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(children: [
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(colors: [theme.colorScheme.primary, theme.colorScheme.secondary.withAlpha(230)]),
                                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                                ),
                                padding: const EdgeInsets.all(10),
                                child: const Icon(Icons.map, color: Colors.white, size: 28),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text(
                                    l10n.setup_choose_state_title,
                                    style: theme.textTheme.headlineSmall,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: true,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    l10n.setup_choose_state_subtitle,
                                    style: theme.textTheme.bodyMedium,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: true,
                                  ),
                                ]),
                              )
                            ]),
                            const SizedBox(height: 18),
                            DropdownButtonFormField<String>(
                              isExpanded: true,
                              initialValue: _selectedCode,
                              hint: Text(l10n.setup_state_hint),
                              items: states
                                  .map((m) => DropdownMenuItem(
                                        value: m['code'],
                                        child: Text('${m['label']} (${m['code']})'),
                                      ))
                                  .toList(),
                              onChanged: (v) => setState(() => _selectedCode = v),
                              decoration: InputDecoration(
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMedium)),
                                prefixIcon: const Icon(Icons.location_on),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  isExpanded: true,
                                  value: _locale,
                                  hint: Text(l10n.setup_language_label),
                                  items: AppLocalizations.supportedLocales
                                      .map((loc) {
                                        final code = loc.languageCode;
                                        final name = LocaleNames.of(context)?.nameOf(code) ?? code;
                                        return DropdownMenuItem(
                                          value: code,
                                          child: Text('$name ($code)'),
                                        );
                                      })
                                      .toList(),
                                  onChanged: (v) => setState(() => _locale = v ?? 'de'),
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMedium)),
                                    prefixIcon: const Icon(Icons.language),
                                  ),
                                ),
                              )
                            ]),
                            const SizedBox(height: 16),
                            Row(children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: (_selectedCode == null || _saving) ? null : _confirm,
                                  child: _saving
                                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                      : Text(l10n.setup_save_continue),
                                ),
                              )
                            ]),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: () {},
                              child: Text(l10n.setup_choose_later),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
