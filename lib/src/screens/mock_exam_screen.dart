import 'dart:async';

import 'package:flutter/material.dart';

import '../core/controller.dart';
import '../core/prefs.dart';
// question model used indirectly via controller
import 'mock_exam_result_screen.dart';

/// Mock exam screen: uses Controller.loadMockExam to prepare a 33-question exam.
/// - 30 general + 3 state (if available)
/// - 60 minute countdown
/// - no immediate feedback; answers are stored in local `answers` list
class MockExamScreen extends StatefulWidget {
  const MockExamScreen({Key? key}) : super(key: key);

  @override
  State<MockExamScreen> createState() => _MockExamScreenState();
}

class _MockExamScreenState extends State<MockExamScreen> {
  Controller? _controller;
  Timer? _timer;
  Duration _remaining = const Duration(minutes: 60);
  bool _submitting = false;

  // local answers: index -> selected answer index (or null)
  List<int?> answers = [];

  @override
  void initState() {
    super.initState();
    AppPrefs.getSelectedState().then((stateCode) {
      _controller = Controller(stateCode: stateCode);
      _startExam();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _startExam() async {
    await _controller!.loadMockExam();
    answers = List<int?>.filled(_controller!.questions.length, null);
    setState(() {});
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _remaining = const Duration(minutes: 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        _remaining = _remaining - const Duration(seconds: 1);
        if (_remaining.inSeconds <= 0) {
          _timer?.cancel();
          _submit(auto: true);
        }
      });
    });
  }

  String _format(Duration d) {
    final min = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final sec = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$min:$sec';
  }

  void _select(int index) {
    setState(() {
      answers[_controller!.currentIndex] = index;
    });
  }

  Future<void> _submit({bool auto = false}) async {
    if (_submitting) return;
    // Confirmation is handled by the caller (e.g. _onAbgebenPressed).
    // If called with auto=true (timer), we skip any prompt and submit directly.

    setState(() => _submitting = true);
    _timer?.cancel();

    // Evaluate
    final total = _controller!.questions.length;
    int correct = 0;
    final results = <int?>[];
    for (var i = 0; i < total; i++) {
      final q = _controller!.questions[i];
      final sel = answers[i];
      results.add(sel);
      if (sel != null && sel == q.correctIndex) correct += 1;
    }

    // Navigate to results; remove this route (so user lands back on home later)
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => MockExamResultScreen(total: total, correct: correct, questions: _controller!.questions, answers: results)),
    );
  }

  void _onAbgebenPressed() async {
    if (_submitting) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) {
        return AlertDialog(
          title: const Text('Prüfung abgeben?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Möchtest du die Prüfung jetzt abgeben? Du kannst danach nicht zurück.'),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(c).pop(true),
                        child: const Text('Ja'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(c).pop(false),
                        child: const Text('Nein'),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );

    if (ok == true) {
      await _submit(auto: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: null,
        body: SafeArea(
          child: (_controller == null || _controller!.isLoading)
              ? const Center(child: CircularProgressIndicator())
              : _controller!.questions.isEmpty
                  ? const Center(child: Text('Keine Fragen verfügbar'))
                  : Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Heading
                          Center(child: Text('Probeprüfung', style: Theme.of(context).textTheme.titleLarge)),
                          const SizedBox(height: 8),
                          // Timer (left) and Abgeben button (right) on the same row
                          Row(
                            children: [
                              // Timer on the left
                              Text(_format(_remaining), style: Theme.of(context).textTheme.titleMedium),
                              const Spacer(),
                              ElevatedButton(
                                onPressed: _submitting ? null : _onAbgebenPressed,
                                child: const Text('Abgeben'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // position label and questions below
                          Text(_controller!.positionLabel(), style: Theme.of(context).textTheme.titleSmall),
                          const SizedBox(height: 8),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Card(
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Text(_controller!.questions[_controller!.currentIndex].text),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  ...List.generate(_controller!.questions[_controller!.currentIndex].answers.length, (i) {
                                    final a = _controller!.questions[_controller!.currentIndex].answers[i];
                                    final sel = answers[_controller!.currentIndex];
                                    final selected = sel == i;
                                    return Card(
                                      color: selected ? Colors.blue.shade100 : null,
                                      child: ListTile(
                                        title: Text(a),
                                        onTap: () => _select(i),
                                      ),
                                    );
                                  }),
                                  const SizedBox(height: 12),
                                ],
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: _controller!.currentIndex > 0 ? () { setState(() { _controller!.previous(); }); } : null,
                                  child: const Text('Zurück'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _controller!.currentIndex < _controller!.questions.length - 1 ? () { setState(() { _controller!.next(); }); } : null,
                                  child: const Text('Weiter'),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
        ),
      ),
    );
  }
}

// result moved to mock_exam_result_screen.dart
