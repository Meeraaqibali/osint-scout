import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../theme.dart';
import '../api.dart';
import 'results_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _controller = TextEditingController();
  bool _analyze = true;
  bool _loading = false;
  List<String> _recents = [];
  String _baseUrl = 'YOUR_CLOUD_URL';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _recents = p.getStringList('recents') ?? [];
      _baseUrl = p.getString('baseUrl') ?? 'YOUR_CLOUD_URL';
    });
  }

  Future<void> _saveRecent(String q) async {
    final p = await SharedPreferences.getInstance();
    final list = [q, ..._recents.where((x) => x != q)].take(8).toList();
    await p.setStringList('recents', list);
    setState(() => _recents = list);
  }

  Future<void> _search([String? q]) async {
    final query = (q ?? _controller.text).trim();
    if (query.isEmpty || _loading) return;
    _controller.text = query;
    FocusScope.of(context).unfocus();
    setState(() => _loading = true);

    try {
      final resp = await ApiClient(baseUrl: _baseUrl).search(query, analyze: _analyze);
      await _saveRecent(query);
      if (!mounted) return;
      Navigator.push(context, MaterialPageRoute(builder: (_) => ResultsScreen(response: resp)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e'), backgroundColor: AppColors.danger));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() => _loading = true);
      try {
        final resp = await ApiClient(baseUrl: _baseUrl).searchImage(File(pickedFile.path));
        if (!mounted) return;
        Navigator.push(context, MaterialPageRoute(builder: (_) => ResultsScreen(response: resp)));
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e'), backgroundColor: AppColors.danger));
      } finally {
        if (mounted) setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 42, height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.accent.withOpacity(0.4)),
                    ),
                    child: const Icon(Icons.radar, color: AppColors.accent),
                  ),
                  const SizedBox(width: 12),
                  const Text('OSINT Scout', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.settings_outlined),
                    onPressed: () async {
                      await Navigator.push(context, MaterialPageRoute(builder: (_) => SettingsScreen(baseUrl: _baseUrl)));
                      _load();
                    },
                  ),
                ],
              ),
              const Spacer(),
              const Text('Reconnaissance,\nreimagined.', style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800, height: 1.1)),
              const SizedBox(height: 8),
              const Text('Search the open web and let AI surface the signal.', style: TextStyle(color: AppColors.textDim, fontSize: 14)),
              const SizedBox(height: 24),
              
              // Updated TextField with Camera
              TextField(
                controller: _controller,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => _search(),
                decoration: InputDecoration(
                  hintText: 'Enter a name, domain, or topic…',
                  prefixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.camera_alt_outlined, color: AppColors.accent),
                        onPressed: () => _pickImage(ImageSource.camera),
                      ),
                      const Icon(Icons.search, color: AppColors.textDim),
                    ],
                  ),
                  suffixIcon: _loading
                      ? const Padding(padding: EdgeInsets.all(14), child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)))
                      : IconButton(icon: const Icon(Icons.arrow_forward, color: AppColors.accent), onPressed: _search),
                ),
              ),
              const SizedBox(height: 8),
              SwitchListTile.adaptive(
                value: _analyze,
                onChanged: (v) => setState(() => _analyze = v),
                title: const Text('AI analysis', style: TextStyle(fontSize: 14)),
                subtitle: const Text('Summarize results and extract entities', style: TextStyle(color: AppColors.textDim, fontSize: 12)),
                contentPadding: EdgeInsets.zero,
                dense: true,
              ),
              if (_recents.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text('RECENT', style: TextStyle(fontSize: 11, letterSpacing: 1.5, color: AppColors.textDim, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _recents.map((q) => ActionChip(
                    label: Text(q, style: const TextStyle(fontSize: 12)),
                    backgroundColor: AppColors.surface,
                    side: BorderSide(color: AppColors.accent.withOpacity(0.2)),
                    onPressed: () => _search(q),
                  )).toList(),
                ),
              ],
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
