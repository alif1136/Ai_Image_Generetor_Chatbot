import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  final String Function() getApiKey;
  final ValueChanged<String> onApiKeyChanged;

  const SettingsScreen({super.key, required this.getApiKey, required this.onApiKeyChanged});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _keyController;
  bool _obscureKey = true;
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _keyController = TextEditingController(text: widget.getApiKey());
  }

  void _saveKey() {
    final key = _keyController.text.trim();
    widget.onApiKeyChanged(key);
    setState(() => _isSaved = true);
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Row(children: [
        Icon(Icons.check_circle, color: Colors.white, size: 18),
        SizedBox(width: 8),
        Text('API key saved successfully'),
      ]),
      backgroundColor: AppTheme.accent,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _isSaved = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // API Key card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: AppTheme.surfaceCard,
                borderRadius: BorderRadius.circular(20), border: Border.all(color: AppTheme.surfaceVariant)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.key_rounded, color: AppTheme.primary, size: 20)),
                const SizedBox(width: 12),
                const Text('OpenAI API Key',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.onSurface)),
              ]),
              const SizedBox(height: 16),
              TextField(
                controller: _keyController,
                obscureText: _obscureKey,
                style: const TextStyle(color: AppTheme.onSurface, fontSize: 14, letterSpacing: 1),
                decoration: InputDecoration(
                  hintText: 'sk-...',
                  prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppTheme.onSurfaceMuted, size: 18),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureKey ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: AppTheme.onSurfaceMuted, size: 18),
                    onPressed: () => setState(() => _obscureKey = !_obscureKey),
                  ),
                ),
                onChanged: (_) { if (_isSaved) setState(() => _isSaved = false); },
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveKey,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: _isSaved ? AppTheme.accent : AppTheme.primary),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(_isSaved ? Icons.check_rounded : Icons.save_outlined, size: 18),
                    const SizedBox(width: 8),
                    Text(_isSaved ? 'Saved!' : 'Save API Key'),
                  ]),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 24),
          // Info card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.08), borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.primary.withOpacity(0.2))),
            child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Icon(Icons.info_outline_rounded, color: AppTheme.primary, size: 18),
                SizedBox(width: 8),
                Text('How to get an API key',
                    style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600, fontSize: 14)),
              ]),
              SizedBox(height: 12),
              _StepItem(step: '1', text: 'Go to platform.openai.com'),
              SizedBox(height: 6),
              _StepItem(step: '2', text: 'Sign in or create an account'),
              SizedBox(height: 6),
              _StepItem(step: '3', text: 'Navigate to API Keys section'),
              SizedBox(height: 6),
              _StepItem(step: '4', text: 'Create a new secret key and paste it above'),
            ]),
          ),
          const SizedBox(height: 24),
          // About card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: AppTheme.surfaceCard,
                borderRadius: BorderRadius.circular(20), border: Border.all(color: AppTheme.surfaceVariant)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('About AI Studio',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.onSurface)),
              const SizedBox(height: 16),
              _aboutRow(Icons.chat_bubble_outline_rounded, 'Chat', 'GPT-4o Mini'),
              const SizedBox(height: 12),
              _aboutRow(Icons.auto_awesome_outlined, 'Image Generation', 'DALL-E 3'),
              const SizedBox(height: 12),
              _aboutRow(Icons.phone_android_rounded, 'Platform', 'Flutter'),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _aboutRow(IconData icon, String label, String value) {
    return Row(children: [
      Icon(icon, color: AppTheme.primary, size: 18),
      const SizedBox(width: 12),
      Text(label, style: const TextStyle(color: AppTheme.onSurfaceMuted, fontSize: 14)),
      const Spacer(),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: AppTheme.surfaceVariant, borderRadius: BorderRadius.circular(8)),
        child: Text(value, style: const TextStyle(color: AppTheme.onSurface, fontSize: 12, fontWeight: FontWeight.w500)),
      ),
    ]);
  }

  @override
  void dispose() { _keyController.dispose(); super.dispose(); }
}

class _StepItem extends StatelessWidget {
  final String step;
  final String text;
  const _StepItem({required this.step, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(width: 20, height: 20,
          decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
          child: Center(child: Text(step,
              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)))),
      const SizedBox(width: 10),
      Expanded(child: Text(text, style: const TextStyle(color: AppTheme.onSurfaceMuted, fontSize: 13, height: 1.4))),
    ]);
  }
}