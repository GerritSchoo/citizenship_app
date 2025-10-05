import 'package:flutter/material.dart';
import '../core/prefs.dart';
import '../data/states.dart';
import 'home_screen.dart';

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
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ScaleTransition(
            scale: _scale,
            child: Card(
              elevation: 12,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(children: [
                        Container(
                            decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [theme.colorScheme.primary, theme.colorScheme.secondary.withAlpha(230)]),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.all(10),
                          child: const Icon(Icons.map, color: Colors.white, size: 28),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('Wähle dein Bundesland', style: theme.textTheme.headlineSmall),
                            const SizedBox(height: 4),
                            Text('Dieses Bundesland wird für landesspezifische Fragen genutzt.', style: theme.textTheme.bodyMedium),
                          ]),
                        )
                      ]),
                      const SizedBox(height: 18),
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue: _selectedCode,
                        hint: const Text('Bitte Bundesland wählen'),
                        items: states.map((m) => DropdownMenuItem(
                          value: m['code'],
                          child: Text('${m['label']} (${m['code']})'),
                        )).toList(),
                        onChanged: (v) => setState(() => _selectedCode = v),
                        decoration: const InputDecoration(border: OutlineInputBorder(), prefixIcon: Icon(Icons.location_on)),
                      ),
                      const SizedBox(height: 12),
                      Row(children: [
                        Expanded(
                          child: InputDecorator(
                            decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 6)),
                            child: Row(children: [
                              const Icon(Icons.language, size: 18),
                              const SizedBox(width: 8),
                              Text('Sprache:', style: theme.textTheme.bodyMedium),
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
                            child: _saving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Speichern und fortfahren'),
                          ),
                        )
                      ]),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () {},
                        child: const Text('Später auswählen'),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
