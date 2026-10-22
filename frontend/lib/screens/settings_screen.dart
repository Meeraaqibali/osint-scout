import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme.dart';
import '../api.dart';

class SettingsScreen extends StatefulWidget {
  final String baseUrl;
  final bool isDark;
  final Function(bool) onThemeChanged;

  const SettingsScreen({
    super.key, 
    required this.baseUrl,
    required this.isDark,
    required this.onThemeChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController _ctrl;
  late bool _isDark;
  String _status = 'unknown';
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.baseUrl);
    _isDark = widget.isDark;
  }

  Future<void> _check() async {
    setState(() { _checking = true; _status = 'checking'; });
    final ok = await ApiClient(baseUrl: _ctrl.text.trim()).health();
    if (!mounted) return;
    setState(() { _checking = false; _status = ok ? 'ok' : 'down'; });
  }

  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    await p.setString('baseUrl', _ctrl.text.trim());
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('APPEARANCE', style: TextStyle(fontSize: 11, letterSpacing: 1.5, color: AppColors.textDim, fontWeight: FontWeight.w600)),
          SwitchListTile.adaptive(
            value: _isDark,
            onChanged: (v) {
              setState(() => _isDark = v);
              widget.onThemeChanged(v);
            },
            title: Text(_isDark ? 'Dark Mode' : 'Light Mode', style: const TextStyle(fontSize: 15)),
            secondary: Icon(_isDark ? Icons.dark_mode : Icons.light_mode, color: AppColors.accent),
            contentPadding: EdgeInsets.zero,
          ),
          const Divider(height: 32),
          
          const Text('BACKEND', style: TextStyle(fontSize: 11, letterSpacing: 1.5, color: AppColors.textDim, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextField(
            controller: _ctrl,
            decoration: const InputDecoration(
              hintText: 'https://...',
              prefixIcon: Icon(Icons.link, color: AppColors.textDim),
            ),
          ),
          const SizedBox(height: 10),
          Row(children: [
            OutlinedButton.icon(
              onPressed: _checking ? null : _check,
              icon: _checking ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.refresh, size: 18),
              label: const Text('Test connection'),
            ),
            const SizedBox(width: 10),
            if (_status == 'ok') const _Badge(label: 'Online', color: AppColors.success)
            else if (_status == 'down') const _Badge(label: 'Offline', color: AppColors.danger),
          ]),
          const SizedBox(height: 20),
          FilledButton(onPressed: _save, child: const Text('Save')),
          const SizedBox(height: 32),
          
          const Text('ABOUT', style: TextStyle(fontSize: 11, letterSpacing: 1.5, color: AppColors.textDim, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          const Text(
            'OSINT Scout v0.1.0\nCloud-hosted reconnaissance with AI assist.',
            style: TextStyle(color: AppColors.textDim, height: 1.5, fontSize: 12.5),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
    );
  }
}
