import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../achievements/achievement_service.dart';
import '../analytics/progress_repository.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  Set<String> _unlocked = <String>{};
  late final _sub = AchievementService.instance.unlockedStream.listen((def) {
    setState(() {
      _unlocked.add(def.id);
    });
  });

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await ProgressRepository.instance.init();
    final ids = await ProgressRepository.instance.unlockedAchievementIds();
    if (!mounted) return;
    setState(() {
      _unlocked = ids.toSet();
    });
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final items = AchievementService.all;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.achievements_title)),
      body: items.isEmpty
          ? Center(child: Text(l10n.achievements_none))
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (ctx, i) {
                final def = items[i];
                final isUnlocked = _unlocked.contains(def.id);
                final name = AchievementService.instance.localizeName(l10n, def);
                final desc = AchievementService.instance.localizeDescription(l10n, def);
                final color = isUnlocked
                    ? Theme.of(ctx).colorScheme.primary
                    : Theme.of(ctx).colorScheme.onSurfaceVariant;
                return Card(
                  child: ListTile(
                    leading: Icon(def.icon, color: color),
                    title: Text(
                      name,
                      maxLines: 2,
                      softWrap: true,
                      overflow: TextOverflow.clip, // avoid showing (...)
                    ),
                    subtitle: desc.isEmpty ? null : Text(desc),
                    trailing: isUnlocked
                        ? Icon(Icons.check_circle, color: Theme.of(ctx).colorScheme.primary)
                        : const Icon(Icons.lock_outline),
                  ),
                );
              },
            ),
    );
  }
}
