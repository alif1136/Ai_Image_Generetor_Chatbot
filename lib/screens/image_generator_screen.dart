import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../services/openai_service.dart';
import '../theme/app_theme.dart';
import '../widgets/api_key_banner.dart';

class ImageGeneratorScreen extends StatefulWidget {
  final String Function() getApiKey;
  final VoidCallback onGoToSettings;

  const ImageGeneratorScreen({super.key, required this.getApiKey, required this.onGoToSettings});

  @override
  State<ImageGeneratorScreen> createState() => _ImageGeneratorScreenState();
}

class _ImageGeneratorScreenState extends State<ImageGeneratorScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _promptController = TextEditingController();
  String? _imageUrl;
  bool _isLoading = false;
  String? _errorMessage;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
  }

  Future<void> _generateImage() async {
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) return;
    final apiKey = widget.getApiKey();
    if (apiKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add your OpenAI API key in Settings'), backgroundColor: AppTheme.error),
      );
      return;
    }
    setState(() { _isLoading = true; _errorMessage = null; _imageUrl = null; });
    _fadeController.reset();
    try {
      final service = OpenAIService(apiKey: apiKey);
      final url = await service.generateImage(prompt);
      setState(() { _imageUrl = url; _isLoading = false; });
      _fadeController.forward();
    } catch (e) {
      setState(() { _errorMessage = e.toString().replaceFirst('Exception: ', ''); _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Image Generator')),
      body: Column(
        children: [
          if (widget.getApiKey().isEmpty) ApiKeyBanner(onGoToSettings: widget.onGoToSettings),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                // Header
                Row(children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [AppTheme.primary, AppTheme.accent],
                          begin: Alignment.topLeft, end: Alignment.bottomRight),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.auto_awesome, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('DALL-E 3 Image AI',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.onSurface)),
                    Text('Turn your words into stunning images',
                        style: TextStyle(fontSize: 12, color: AppTheme.onSurfaceMuted)),
                  ]),
                ]),
                const SizedBox(height: 24),
                // Prompt card
                Container(
                  decoration: BoxDecoration(color: AppTheme.surfaceCard,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.surfaceVariant)),
                  padding: const EdgeInsets.all(16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('YOUR PROMPT',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                            color: AppTheme.onSurfaceMuted, letterSpacing: 1.2)),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _promptController,
                      minLines: 3, maxLines: 6,
                      style: const TextStyle(color: AppTheme.onSurface, fontSize: 15, height: 1.5),
                      decoration: const InputDecoration(
                        hintText: 'Describe the image you want to create...',
                        filled: false, border: InputBorder.none, contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: 16),
                // Generate button
                ElevatedButton(
                  onPressed: _isLoading ? null : _generateImage,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    backgroundColor: AppTheme.primary,
                    disabledBackgroundColor: AppTheme.surfaceVariant,
                  ),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    if (_isLoading) ...[
                      const SpinKitThreeBounce(color: AppTheme.primary, size: 16),
                      const SizedBox(width: 12),
                      const Text('Generating...', style: TextStyle(color: AppTheme.onSurfaceMuted)),
                    ] else ...[
                      const Icon(Icons.bolt_rounded, size: 20),
                      const SizedBox(width: 8),
                      const Text('Generate Image',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ],
                  ]),
                ),
                const SizedBox(height: 28),
                _buildImageArea(),
                const SizedBox(height: 24),
                _buildExamplePrompts(),
                const SizedBox(height: 20),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageArea() {
    if (_isLoading) {
      return Container(
        height: 340,
        decoration: BoxDecoration(color: AppTheme.surfaceCard,
            borderRadius: BorderRadius.circular(20), border: Border.all(color: AppTheme.surfaceVariant)),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const SpinKitPulse(color: AppTheme.primary, size: 48),
          const SizedBox(height: 20),
          const Text('Creating your masterpiece...',
              style: TextStyle(color: AppTheme.onSurface, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          const Text('This may take a few seconds',
              style: TextStyle(color: AppTheme.onSurfaceMuted, fontSize: 13)),
        ]),
      );
    }
    if (_errorMessage != null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: AppTheme.error.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.error.withOpacity(0.3))),
        child: Row(children: [
          const Icon(Icons.error_outline, color: AppTheme.error, size: 24),
          const SizedBox(width: 12),
          Expanded(child: Text(_errorMessage!, style: const TextStyle(color: AppTheme.error, fontSize: 13))),
        ]),
      );
    }
    if (_imageUrl != null) {
      return FadeTransition(
        opacity: _fadeAnimation,
        child: Column(children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: CachedNetworkImage(
              imageUrl: _imageUrl!,
              placeholder: (_, __) => Container(height: 340, color: AppTheme.surfaceCard,
                  child: const Center(child: SpinKitPulse(color: AppTheme.primary, size: 40))),
              errorWidget: (_, __, ___) => Container(height: 340, color: AppTheme.surfaceCard,
                  child: const Icon(Icons.broken_image, color: AppTheme.onSurfaceMuted, size: 48)),
              fit: BoxFit.cover, width: double.infinity,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _generateImage,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Regenerate'),
              style: OutlinedButton.styleFrom(foregroundColor: AppTheme.primary,
                  side: const BorderSide(color: AppTheme.primary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12)),
            ),
          ),
        ]),
      );
    }
    return Container(
      height: 240,
      decoration: BoxDecoration(color: AppTheme.surfaceCard,
          borderRadius: BorderRadius.circular(20), border: Border.all(color: AppTheme.surfaceVariant)),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.image_outlined, size: 52, color: AppTheme.onSurfaceMuted.withOpacity(0.5)),
        const SizedBox(height: 12),
        const Text('Your image will appear here',
            style: TextStyle(color: AppTheme.onSurfaceMuted, fontSize: 14)),
      ]),
    );
  }

  Widget _buildExamplePrompts() {
    final examples = [
      ('Cyberpunk city at night', Icons.location_city_rounded),
      ('Magical forest with glowing mushrooms', Icons.forest_rounded),
      ('Astronaut on alien planet', Icons.rocket_launch_rounded),
      ('Oil painting of a cozy café', Icons.local_cafe_rounded),
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('EXAMPLE PROMPTS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
          color: AppTheme.onSurfaceMuted, letterSpacing: 1.2)),
      const SizedBox(height: 12),
      ...examples.map((e) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _promptController.text = e.$1,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(color: AppTheme.surfaceVariant, borderRadius: BorderRadius.circular(12)),
            child: Row(children: [
              Icon(e.$2, color: AppTheme.primary, size: 18),
              const SizedBox(width: 12),
              Expanded(child: Text(e.$1, style: const TextStyle(color: AppTheme.onSurface, fontSize: 14))),
              const Icon(Icons.arrow_forward_ios_rounded, color: AppTheme.onSurfaceMuted, size: 14),
            ]),
          ),
        ),
      )),
    ]);
  }

  @override
  void dispose() {
    _promptController.dispose();
    _fadeController.dispose();
    super.dispose();
  }
}