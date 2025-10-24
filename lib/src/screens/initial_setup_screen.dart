import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../core/prefs.dart';
import '../data/states.dart';
import 'home_screen.dart';
import '../../l10n/app_localizations.dart';

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
    _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 420));
    _scale = CurvedAnimation(parent: _anim, curve: Curves.easeOutBack);
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
                                  Text(l10n.setup_choose_state_title, style: theme.textTheme.headlineSmall),
                                  const SizedBox(height: 4),
                                  Text(l10n.setup_choose_state_subtitle, style: theme.textTheme.bodyMedium),
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
                                child: InputDecorator(
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMedium)),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  ),
                                  child: Row(children: [
                                    const Icon(Icons.language, size: 18),
                                    const SizedBox(width: 8),
                                    Text(l10n.setup_language_label, style: theme.textTheme.bodyMedium),
                                    const SizedBox(width: 12),
                                    ChoiceChip(
                                      label: const Text('Deutsch'),
                                      selected: _locale == 'de',
                                      onSelected: (_) => setState(() => _locale = 'de'),
                                    ),
                                    const SizedBox(width: 8),
                                    ChoiceChip(
                                      label: const Text('Englisch'),
                                      selected: _locale == 'en',
                                      onSelected: (_) => setState(() => _locale = 'en'),
                                    ),
                                  ]),
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
