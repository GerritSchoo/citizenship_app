# Citizenship App — Design Document

## Overview

A Flutter quiz app for the German citizenship test (Einbürgerungstest). Users practice the 310 general questions plus 10 state-specific questions for their Bundesland. The app is free with limited usage; a Premium subscription unlocks full access.

---

## Tech Stack

| Layer | Choice |
|---|---|
| Framework | Flutter SDK ^3.9.2, Material Design 3 |
| State management | `AppState` (root `StatefulWidget`) + `Controller` (`ChangeNotifier`) + `PurchaseService.isProNotifier` (`ValueNotifier`) |
| Navigation | Imperative Navigator 1.0 |
| UI localisation | Flutter gen-l10n ARB — DE + EN |
| Question localisation | JSON overlay — DE, EN, TR, RU, UK, AR, FR, ES |
| Database | SQLite via `sqflite` (`attempts`, `exam_sessions` tables) |
| Firebase | Core, Analytics, Crashlytics, Remote Config |
| Payments | `in_app_purchase ^3.3.0` |
| Review prompt | `in_app_review ^2.0.9` |
| Platforms | Android, iOS, Web, Windows, macOS, Linux |

---

## Premium System

### Products

| ID | Type |
|---|---|
| `citizenship_premium_monthly` | Auto-renewing subscription |
| `citizenship_premium_lifetime` | Non-consumable one-time purchase |

### Free vs. Premium

| Feature | Free | Premium |
|---|---|---|
| Quiz sessions | 10 total | Unlimited |
| Mock exams | 3 total | Unlimited |
| State-specific questions | Locked | All 16 Bundesländer |
| Question translation languages | DE + EN | + TR, RU, UK, AR, FR, ES |
| All quiz modes (Timer, Topics, Mistakes) | Available | Available |

### Limits stored in `SharedPreferences`

- `quizTrialCount` — incremented per quiz session start; NOT cleared by `clearAll()` (bypass protection)
- `examTrialCount` — incremented per mock exam start; NOT cleared by `clearAll()`
- `reviewRequested` — one-time flag; set after first in-app review request

---

## Content Language (Question Translation)

Questions and answers can be displayed in 8 languages. The language order reflects immigrant population size in Germany:

1. **DE** — German (free)
2. **EN** — English (free)
3. **TR** — Turkish (premium)
4. **RU** — Russian (premium)
5. **UK** — Ukrainian (premium)
6. **AR** — Arabic (premium)
7. **FR** — French (premium)
8. **ES** — Spanish (premium)

**Fallback rule:** If the user has a premium language saved but their subscription has lapsed, the app silently falls back to `'en'` at startup (`app.dart` init).

---

## Premium Gates — Implementation

### Quiz session limit (`quiz_mode_screen.dart`)
- `_kQuizFreeLimit = 10`
- Info banner: "X of 10 free sessions used" (blue → red at limit)
- At limit: bottom sheet with lock icon + "Unlock Premium" `FilledButton` + "Not now" `TextButton`

### State questions (`learning_mode_screen.dart`, `quiz_topics_screen.dart`)
- State tile shows `Icons.lock_outline` when `!isPro`
- Tap shows `_showStatePremiumSheet()` bottom sheet

### Mock exam limit (`mock_exam_rules_screen.dart`)
- `_kExamFreeLimit = 3`
- Bottom sheet with same pattern

### Content language — initial setup (`initial_setup_screen.dart`)
- Lock icon shown as trailing widget on premium languages in the picker list
- Selecting a premium language when `!isPro` shows an informational sheet: "English and German are free. You can continue now and upgrade after launch." + "Got it" (no forced paywall during onboarding)

### Content language — in-app menu (`home_screen.dart`)
- Small lock icon next to premium languages in the popup menu (shown when `!isPro`)
- Selecting a premium language when `!isPro` shows a bottom sheet with "Unlock Premium" + "Not now"

---

## Bottom Sheet Pattern (all gates)

```dart
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
        Icon(Icons.lock_outline, size: 48, ...),
        // title, body, FilledButton("Unlock Premium"), TextButton("Not now")
      ],
    ),
  ),
);
```

Navigate to paywall: `Navigator.push(context, MaterialPageRoute(builder: (_) => const PaywallScreen()))`.

---

## Paywall Screen (`paywall_screen.dart`)

Gradient header with `Icons.workspace_premium`. Four benefits:

| Icon | Benefit |
|---|---|
| `quiz_outlined` | Unlimited quiz sessions |
| `flag_outlined` | State-specific questions (all 16 Bundesländer) |
| `assignment_outlined` | Unlimited mock exams |
| `translate_outlined` | Questions in 6 languages (AR, ES, FR, RU, TR, UK) |

---

## In-App Review (`review_service.dart`)

`ReviewService.instance.requestReviewIfAppropriate()` is called:
- After passing a mock exam (2s delay, `mock_exam_result_screen.dart`)

Guards:
1. Check `AppPrefs.getReviewRequested()` — only runs once per install
2. Check `InAppReview.instance.isAvailable()`
3. Call `InAppReview.instance.requestReview()`, then set `reviewRequested = true`

---

## Localisation

### UI strings (`lib/l10n/`)
ARB files for DE and EN. Key premium-related strings:

| Key | EN | DE |
|---|---|---|
| `unlock_premium` | Unlock Premium | Premium freischalten |
| `not_now` | Not now | Nicht jetzt |
| `paywall_benefit_quiz` | Unlimited quiz sessions | Unbegrenzte Quiz-Sessions |
| `paywall_benefit_state` | State-specific questions (all 16 Bundesländer) | Bundesland-Fragen (alle 16 Bundesländer) |
| `paywall_benefit_exam` | Unlimited mock exams | Unbegrenzte Probeprüfungen |
| `paywall_benefit_translations` | Questions in 6 languages (AR, ES, FR, RU, TR, UK) | Fragen in 6 Sprachen (AR, ES, FR, RU, TR, UK) |
| `quiz_sessions_remaining` | {count} of {limit} free sessions used | — |
| `menu_subscribe` | Premium | Premium |

### Question content (`assets/i18n/`)
JSON files per language: `questions_de.json`, `questions_en.json`, `questions_tr.json`, `questions_ru.json`, `questions_uk.json`, `questions_ar.json`, `questions_fr.json`, `questions_es.json`

---

## Future: RevenueCat Migration

Planned replacement of `in_app_purchase` with `purchases_flutter`:
- Replace `PurchaseService` with RevenueCat SDK
- Use `PaywallView` for the paywall screen
- Entitlement-based `isPro` check instead of manual product verification
