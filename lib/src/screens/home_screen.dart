import 'package:flutter/material.dart';
import 'quiz_screen.dart';
import '../data/states.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _selectedStateCode;

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
    final label = _selectedStateLabel ?? code;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Selected state: $label ($code)')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Citizenship Test Quiz"),
        actions: [
          // State selection menu
          PopupMenuButton<String>(
            tooltip: 'Choose state',
            icon: const Icon(Icons.menu),
            onSelected: _onSelectState,
            itemBuilder: (context) {
              return states.map((s) {
                final code = s['code']!;
                final label = s['label']!;
                return PopupMenuItem<String>(
                  value: code,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(child: Text(label)),
                      const SizedBox(width: 8),
                      Text(code, style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.school, size: 80, color: Colors.blue),
              const SizedBox(height: 8),
              if (_selectedStateLabel != null) ...[
                Text('State: ${_selectedStateLabel!} (${_selectedStateCode!})'),
                const SizedBox(height: 32),
              ] else
                const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Learning mode coming soon!")),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    alignment: Alignment.centerLeft,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: const [
                      SizedBox(width: 4),
                      SizedBox(width: 32, child: Icon(Icons.lightbulb_outline, size: 20)),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Start Learning',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const QuizScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    alignment: Alignment.centerLeft,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: const [
                      SizedBox(width: 4),
                      SizedBox(width: 32, child: Icon(Icons.quiz_outlined, size: 20)),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Start Quiz',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Mock exams coming soon!')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    alignment: Alignment.centerLeft,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: const [
                      SizedBox(width: 4),
                      SizedBox(width: 32, child: Icon(Icons.assignment_outlined, size: 20)),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Mock Exams',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
