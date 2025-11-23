import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../data/question_repository.dart';
import '../models/question.dart';
import '../core/prefs.dart';
import '../analytics/progress_repository.dart';

class SwipeQuizScreen extends StatefulWidget {
  const SwipeQuizScreen({super.key});

  @override
  State<SwipeQuizScreen> createState() => _SwipeQuizScreenState();
}

class _SwipeQuizScreenState extends State<SwipeQuizScreen> {
  final _repo = QuestionRepository();
  bool _loading = true;
  String? _stateCode;
  late final String _sessionId;
  late final Stopwatch _timer;
  final _items = <_SwipeItem>[];
  int _index = 0;
  int _correct = 0;
  final GlobalKey<_SwipeCardState> _cardKey = GlobalKey<_SwipeCardState>();
  bool _showTranslation = false;

  @override
  void initState() {
    super.initState();
    // Lock orientation to portrait while on the Swipe screen
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _sessionId = 'swipe-${DateTime.now().millisecondsSinceEpoch}';
    _timer = Stopwatch()..start();
    _init();
  }

  @override
  void dispose() {
    // Restore device orientations when leaving this screen
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  Future<void> _init() async {
    await ProgressRepository.instance.init();
    await _repo.init(languageCode: QuestionRepository.defaultLanguageCode);
    _stateCode = await AppPrefs.getSelectedState();

    // Build pool of questions: general (+ state if selected)
    final pool = <Question>[];
    pool.addAll(_repo.generalQuestions);
    if (_stateCode != null) {
      pool.addAll(_repo.getStateQuestions(_stateCode!));
    }
    // Shuffle and limit to keep session brisk
    pool.shuffle();
    final selected = pool.take(math.min(30, pool.length)).toList();

    for (final q in selected) {
      // Build one card per question with 50% chance correct vs incorrect
      final isMatch = math.Random().nextBool();
      final answerIndex = isMatch
          ? q.correctIndex
          : _randomWrongIndex(q.answers.length, q.correctIndex);
      _items.add(_SwipeItem(question: q, answerIndex: answerIndex, isState: _isStateQuestion(q)));
    }

    // Start a session in analytics (best-effort)
    await ProgressRepository.instance.startSession(
      sessionId: _sessionId,
      mode: SessionMode.practice,
      totalQuestions: _items.length,
    );

    if (!mounted) return;
    setState(() => _loading = false);
  }

  bool _isStateQuestion(Question q) {
    // Heuristic: if stateCode is selected and this question exists in that list
    if (_stateCode == null) return false;
    final list = _repo.getStateQuestions(_stateCode!);
    return list.any((x) => x.id == q.id);
  }

  int _randomWrongIndex(int len, int correct) {
    if (len <= 1) return 0;
    final r = math.Random();
    int idx;
    do {
      idx = r.nextInt(len);
    } while (idx == correct);
    return idx;
  }

  bool get _done => !_loading && _index >= _items.length;

  void _onDecision(bool guessIsMatch, {required int timeMs}) async {
    if (_done) return;
    final item = _items[_index];
    final q = item.question;
    final isMatch = item.answerIndex == q.correctIndex;
    final isCorrect = guessIsMatch == isMatch;

    if (isCorrect) _correct++;

    // Log attempt (best-effort)
    await ProgressRepository.instance.logAttempt(
      sessionId: _sessionId,
      questionId: q.id,
      topicId: q.topicId,
      isState: item.isState,
      mode: SessionMode.practice,
      selectedIndex: item.answerIndex,
      correctIndex: q.correctIndex,
      isCorrect: isCorrect,
      skipped: false,
      timeToAnswerMs: timeMs,
    );

    setState(() => _index++);
    if (_index >= _items.length) {
      _timer.stop();
      await ProgressRepository.instance.finishSession(
        sessionId: _sessionId,
        correctCount: _correct,
        duration: _timer.elapsed,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    if (_loading) {
      return const Scaffold(body: SafeArea(child: Center(child: CircularProgressIndicator())));
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.quiz_mode_swipe_tf),
        actions: [
          if (locale.languageCode != 'de')
            IconButton(
              tooltip: 'DE',
              icon: Icon(_showTranslation ? Icons.translate : Icons.translate_outlined),
              onPressed: () => setState(() => _showTranslation = !_showTranslation),
            ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Make the card fill almost the entire screen (respecting page padding)
            final maxCardWidth = constraints.maxWidth;
            final width = constraints.maxWidth;
            final current = _done ? null : _items[_index];
            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxCardWidth, maxHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _done
                      ? _Results(correct: _correct, total: _items.length)
                      : Column(
                          children: [
                            // Card fills available space
                            Expanded(
                              child: Stack(
                                children: [
                                  if (_index + 1 < _items.length)
                                    // Preview of the next card underneath
                                    Positioned.fill(
                                      child: Transform.scale(
                                        scale: 0.98,
                                        child: Transform.translate(
                                          offset: const Offset(0, 8),
                                          child: _StaticCard(
                                            item: _items[_index + 1],
                                            width: width,
                                            showTranslation: _showTranslation && locale.languageCode != 'de',
                                          ),
                                        ),
                                      ),
                                    ),
                                  // Top interactive card
                                  Positioned.fill(
                                    child: _SwipeCard(
                                      item: current!,
                                      width: width,
                                      showTranslation: _showTranslation && locale.languageCode != 'de',
                                      onDecision: (guess, timeMs) => _onDecision(guess, timeMs: timeMs),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Bottom action buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _CircleAction(
                                  icon: Icons.close,
                                  color: Colors.red,
                                  onTap: () => _cardKey.currentState?.triggerProgrammatic(false),
                                ),
                                const SizedBox(width: 24),
                                _CircleAction(
                                  icon: Icons.check,
                                  color: Colors.green,
                                  onTap: () => _cardKey.currentState?.triggerProgrammatic(true),
                                ),
                              ],
                            ),
                          ],
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

class _SwipeItem {
  final Question question;
  final int answerIndex; // index into question.answers (+ answerImages)
  final bool isState;
  const _SwipeItem({required this.question, required this.answerIndex, required this.isState});
}

class _StaticCard extends StatelessWidget {
  final _SwipeItem item;
  final double width;
  final bool showTranslation;
  const _StaticCard({required this.item, required this.width, required this.showTranslation});

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).brightness == Brightness.dark
        ? Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.25)
        : Colors.white;
    final q = item.question;
    final idx = item.answerIndex;
    final hasAnswerImage = q.hasAnswerImages;
    final String? answerImage = hasAnswerImage ? q.answerImages![idx] : null;
    return Material(
      color: bg,
      elevation: 2,
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      clipBehavior: Clip.antiAlias,
      child: Container(
        width: width,
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, dims) {
            final theme = Theme.of(context);
            // Always use German as base text where available
            final String baseQuestionText = q.originalDeText ?? q.text;
            final bool showOverlay = showTranslation && Localizations.localeOf(context).languageCode != 'de';
            final String translatedQuestionText = q.text;
            final overlayGap = showOverlay ? 8.0 : 0.0;
            final double gap = 12;
            // Dynamically size the question and answer regions so the question text is always fully visible
    return Builder(builder: (context) {
      final maxH = dims.maxHeight;
      final dir = Directionality.of(context);
                  final questionStyle = theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700);
                  final tp = TextPainter(
                    text: TextSpan(text: baseQuestionText, style: questionStyle),
                    textAlign: TextAlign.left,
                    textDirection: dir,
                    maxLines: null,
                  )..layout(maxWidth: dims.maxWidth);
                  final qH = tp.height;

                  double overlayH = 0;
                  if (showOverlay) {
                    final overlayStyle = theme.textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                    );
                    final overlayTp = TextPainter(
                      text: TextSpan(text: translatedQuestionText, style: overlayStyle),
                      textAlign: TextAlign.left,
                      textDirection: dir,
                      maxLines: null,
                    )..layout(maxWidth: dims.maxWidth);
                    overlayH = overlayTp.height + overlayGap;
                  }

                  const double dividerH = 1;
                  // Gaps: after image (if any), after question (+ optional overlay), before and after divider
                  double gaps = 0;
                  if (q.hasContextImage) gaps += gap;
                  gaps += gap; // after question
                  gaps += overlayH; // space for overlay if needed
                  gaps += gap; // before divider already counted; keep spacing symmetry
                  // Base context image height as before
                  double imgH = q.hasContextImage ? (maxH * 0.28).clamp(140, 260) : 0;

                  double usedTop = imgH + qH + gaps + dividerH;
                  double answerH = maxH - usedTop;
                  if (answerH < 0) {
                    // Shrink image first to make room for full question
                    final canReduce = imgH;
                    final need = -answerH;
                    final reduceBy = need.clamp(0, canReduce);
                    imgH -= reduceBy;
                    usedTop = imgH + qH + gaps + dividerH;
                    answerH = maxH - usedTop;
                    if (answerH < 0) {
                      // If still negative, allow answer area to shrink to zero
                      answerH = 0;
                    }
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (q.hasContextImage && imgH > 0) ...[
                        SizedBox(
                          height: imgH,
                          width: double.infinity,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                            child: Image.asset(q.image!, fit: BoxFit.contain),
                          ),
                        ),
                        SizedBox(height: gap),
                      ],
                      SizedBox(
                        height: qH,
                        child: Text(
                          baseQuestionText,
                          softWrap: true,
                          style: questionStyle,
                        ),
                      ),
                      if (showOverlay) ...[
                        const SizedBox(height: 8),
                        Text(
                          translatedQuestionText,
                          softWrap: true,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontStyle: FontStyle.italic,
                            color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                      SizedBox(height: gap),
                      Divider(color: theme.dividerColor.withValues(alpha: 0.3), height: dividerH),
                      SizedBox(height: gap),
                      SizedBox(
                        height: answerH,
                        child: Center(
                          child: answerImage != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                                  child: Image.asset(
                                    answerImage,
                                    fit: BoxFit.contain,
                                    width: dims.maxWidth,
                                    height: double.infinity,
                                  ),
                                )
                              : Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  child: _AutoSizeAnswer(
                                    text: q.answers[idx],
                                    style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
                                  ),
                                ),
                        ),
                      ),
                    ],
                  );
            });
          },
        ),
      ),
    );
  }
}

class _SwipeCard extends StatefulWidget {
  final _SwipeItem item;
  final double width;
  final bool showTranslation;
  final void Function(bool guessIsMatch, int timeMs) onDecision;
  const _SwipeCard({required this.item, required this.width, required this.showTranslation, required this.onDecision});

  @override
  State<_SwipeCard> createState() => _SwipeCardState();
}

class _SwipeCardState extends State<_SwipeCard> with SingleTickerProviderStateMixin {
  double _drag = 0; // -1..1
  late final Stopwatch _watch;
  late final AnimationController _progCtrl;
  late Animation<Offset> _progOffset;
  bool? _pendingGuess;
  int? _pendingElapsed;
  bool _exiting = false;

  @override
  void initState() {
    super.initState();
    _watch = Stopwatch()..start();
    _progCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 220));
    _progOffset = const AlwaysStoppedAnimation<Offset>(Offset.zero);
  }

  @override
  void dispose() {
    _progCtrl.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _SwipeCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // When the card content changes (next item), reset animations/state so the new card starts clean
    if (oldWidget.item.question.id != widget.item.question.id ||
        oldWidget.item.answerIndex != widget.item.answerIndex) {
      if (_exiting) {
        _progCtrl.reset();
        _progOffset = const AlwaysStoppedAnimation<Offset>(Offset.zero);
        _drag = 0;
        _exiting = false;
      }
      _watch
        ..reset()
        ..start();
    }
  }

  Future<void> triggerProgrammatic(bool guessIsMatch) async {
    if (_progCtrl.isAnimating) return;
    // Kick a slide animation in target direction (+x = right, -x = left)
    final dir = guessIsMatch ? 1.0 : -1.0;
    _drag = dir; // shows overlay icon during animation
    _watch.stop();
    _progCtrl.reset();
    _progOffset = _progCtrl.drive(
      Tween<Offset>(begin: Offset.zero, end: Offset(dir * 2.0, 0.0)).chain(
        CurveTween(curve: Curves.easeOut),
      ),
    );
    setState(() {});
    await _progCtrl.forward();
    // Mark exiting and notify parent; the next build will reset state in didUpdateWidget
    _exiting = true;
    widget.onDecision(guessIsMatch, _watch.elapsedMilliseconds);
  }

  @override
  Widget build(BuildContext context) {
    // Use an opaque surface color so the bottom card is only visible where the top card has moved away
    final bg = Theme.of(context).colorScheme.surface;

    final q = widget.item.question;
    final idx = widget.item.answerIndex;
    final hasAnswerImage = q.hasAnswerImages;
    final String? answerImage = hasAnswerImage ? q.answerImages![idx] : null;

    return Dismissible(
      key: ValueKey('${q.id}_$idx'),
      direction: DismissDirection.horizontal,
      onUpdate: (details) {
        final dir = details.direction == DismissDirection.startToEnd ? 1.0 : -1.0;
        setState(() => _drag = (details.progress * dir).clamp(-1.0, 1.0));
      },
      confirmDismiss: (direction) async {
        // Defer grading until onDismissed so the reveal animation shows the next card beneath
        _pendingGuess = direction == DismissDirection.startToEnd; // right = True
        _watch.stop();
        _pendingElapsed = _watch.elapsedMilliseconds;
        return true;
      },
      onDismissed: (_) {
        final guess = _pendingGuess ?? false;
        final elapsed = _pendingElapsed ?? _watch.elapsedMilliseconds;
        _pendingGuess = null;
        _pendingElapsed = null;
        // Grade now that the card is off-screen. Do not call setState here.
        _exiting = true;
        widget.onDecision(guess, elapsed);
      },
      child: Transform.rotate(
        angle: _drag * 0.08,
        child: SlideTransition(
          position: _progOffset,
          child: _buildCardBody(context, bg, q, idx, answerImage),
        ),
      ),
    );
  }

  Widget _buildCardBody(BuildContext context, Color bg, Question q, int idx, String? answerImage) {
    // Base texts: always prefer German originals when available
    final String baseQuestionText = q.originalDeText ?? q.text;
    final String baseAnswerText =
        q.originalDeAnswers != null && q.originalDeAnswers!.length == q.answers.length
            ? q.originalDeAnswers![idx]
            : q.answers[idx];
    final bool showOverlay = widget.showTranslation && Localizations.localeOf(context).languageCode != 'de';
    final String translatedQuestionText = q.text;
    final String translatedAnswerText = q.answers[idx];

    return Material(
      color: bg,
      elevation: 6,
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      clipBehavior: Clip.antiAlias,
      child: Container(
        width: widget.width,
        padding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            Positioned.fill(
              child: LayoutBuilder(
                builder: (context, dims) {
                  final theme = Theme.of(context);
                  final double gap = 12;
                  return LayoutBuilder(
                    builder: (context, innerDims) {
                      final maxH = innerDims.maxHeight;
                      final dir = Directionality.of(context);
                      final questionStyle = theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700);

                      // Measure question + optional overlay to size image nicely, but allow scrolling overall.
                      final tp = TextPainter(
                        text: TextSpan(text: baseQuestionText, style: questionStyle),
                        textAlign: TextAlign.left,
                        textDirection: dir,
                        maxLines: null,
                      )..layout(maxWidth: innerDims.maxWidth);
                      final qH = tp.height;

                      // If needed later, we could also pre-measure the overlay text.

                      // Use a bit more space for the context image now that content can scroll.
                      double imgH = q.hasContextImage ? (maxH * 0.35).clamp(160, 280) : 0;

                      return Scrollbar(
                        thumbVisibility: true,
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (q.hasContextImage && imgH > 0) ...[
                                SizedBox(
                                  height: imgH,
                                  width: double.infinity,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                                    child: Image.asset(q.image!, fit: BoxFit.contain),
                                  ),
                                ),
                                SizedBox(height: gap),
                              ],
                              SizedBox(
                                height: qH,
                                child: Text(
                                  baseQuestionText,
                                  softWrap: true,
                                  style: questionStyle,
                                ),
                              ),
                              if (showOverlay) ...[
                                const SizedBox(height: 8),
                                Text(
                                  translatedQuestionText,
                                  softWrap: true,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontStyle: FontStyle.italic,
                                    color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                                  ),
                                ),
                              ],
                              SizedBox(height: gap),
                              Divider(color: theme.dividerColor.withValues(alpha: 0.3), height: 1),
                              SizedBox(height: gap),
                              Center(
                                child: answerImage != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                                        child: Image.asset(
                                          answerImage,
                                          fit: BoxFit.contain,
                                          width: innerDims.maxWidth,
                                        ),
                                      )
                                    : Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 8),
                                            child: _AutoSizeAnswer(
                                              text: baseAnswerText,
                                              style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
                                            ),
                                          ),
                                          if (showOverlay) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              translatedAnswerText,
                                              textAlign: TextAlign.center,
                                              style: theme.textTheme.bodySmall?.copyWith(
                                                fontStyle: FontStyle.italic,
                                                color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                              ),
                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            // Overlay decision icons must render ABOVE content (after Positioned.fill)
            if (_drag > 0)
              Positioned(
                top: 8,
                left: 8,
                child: Opacity(
                  opacity: _drag.clamp(0, 1),
                  child: const Icon(Icons.check_circle, color: Colors.green, size: 140),
                ),
              ),
            if (_drag < 0)
              Positioned(
                top: 8,
                right: 8,
                child: Opacity(
                  opacity: (-_drag).clamp(0, 1),
                  child: const Icon(Icons.cancel, color: Colors.red, size: 140),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// _DragChip removed: replaced by large overlay icons during swipe

class _Results extends StatelessWidget {
  final int correct;
  final int total;
  const _Results({required this.correct, required this.total});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final ratio = total == 0 ? 0.0 : correct / total;
    final bg = Theme.of(context).brightness == Brightness.dark
        ? Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4)
        : Colors.white;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(l10n.swipe_results_title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Text(l10n.swipe_results_summary(correct, total), style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 16),
        Material(
          color: bg,
          elevation: 2,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: LinearProgressIndicator(value: ratio),
          ),
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.check),
            label: Text(l10n.done_btn),
          ),
        )
      ],
    );
  }
}

class _CircleAction extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _CircleAction({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final neutralBg = theme.brightness == Brightness.dark
        ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.25)
        : Colors.white;
    return Material(
      color: neutralBg,
      elevation: 2,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Icon(icon, color: color, size: 40),
        ),
      ),
    );
  }
}

class _AutoSizeAnswer extends StatelessWidget {
  final String text;
  final TextStyle? style;
  const _AutoSizeAnswer({required this.text, this.style});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxW = constraints.maxWidth;
        final maxH = constraints.maxHeight;
        final dir = Directionality.of(context);

  // Reasonable bounds to avoid overly large text
  double low = 12;
  double high = 32; // tighter cap so short answers don't appear oversized
        double best = low;
        final baseStyle = (style ?? const TextStyle());
        List<String> words = text.split(RegExp(r"\s+"));
        for (int i = 0; i < 12; i++) {
          final mid = (low + high) / 2;
          final tp = TextPainter(
            text: TextSpan(text: text, style: baseStyle.copyWith(fontSize: mid)),
            textAlign: TextAlign.center,
            textDirection: dir,
            maxLines: null,
          )..layout(maxWidth: maxW);
          final h = tp.height;
          // Ensure no single word would need to break across lines
          bool wordsFit = true;
          for (final w in words) {
            if (w.isEmpty) continue;
            final wp = TextPainter(
              text: TextSpan(text: w, style: baseStyle.copyWith(fontSize: mid)),
              textAlign: TextAlign.left,
              textDirection: dir,
              maxLines: 1,
            )..layout();
            if (wp.width > maxW) {
              wordsFit = false;
              break;
            }
          }

          if (h <= maxH && wordsFit) {
            best = mid;
            low = mid;
          } else {
            high = mid;
          }
        }

        return Text(
          text,
          textAlign: TextAlign.center,
          softWrap: true,
          style: baseStyle.copyWith(fontSize: best),
        );
      },
    );
  }
}
