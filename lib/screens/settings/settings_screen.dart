import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../services/gemini_service.dart';
import '../../state/settings_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_snackbar.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _controller = TextEditingController();
  bool _obscure = true;
  bool _saving = false;
  bool _testing = false;
  bool _initialized = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await ref.read(settingsProvider.notifier).saveKey(_controller.text);
    setState(() => _saving = false);
    if (mounted) AppSnackbar.show(context, 'Gemini API key saved');
  }

  Future<void> _clear() async {
    await ref.read(settingsProvider.notifier).clearKey();
    _controller.clear();
    if (mounted) AppSnackbar.show(context, 'API key removed from this device');
  }

  Future<void> _testKey() async {
    final key = _controller.text.trim();
    if (key.isEmpty) {
      AppSnackbar.show(context, 'Enter a key first.', isError: true);
      return;
    }
    setState(() => _testing = true);
    try {
      await GeminiService().summarize(apiKey: key, rawText: 'Connection test: say hello.');
      if (mounted) AppSnackbar.show(context, 'Key works — connected to Gemini.');
    } on GeminiException catch (e) {
      if (mounted) AppSnackbar.show(context, e.message, isError: true);
    } catch (_) {
      if (mounted) AppSnackbar.show(context, 'Could not verify the key.', isError: true);
    } finally {
      if (mounted) setState(() => _testing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);

    if (!_initialized && !settings.loading) {
      _controller.text = settings.geminiApiKey ?? '';
      _initialized = true;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Text('Gemini API key', style: AppTextStyles.headline),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Caption IQ uses your own free Gemini API key to generate summaries. '
              'It is encrypted and stored only on this device — never uploaded anywhere.',
              style: AppTextStyles.body,
            ),
            const SizedBox(height: AppSpacing.lg),
            TextField(
              controller: _controller,
              obscureText: _obscure,
              autocorrect: false,
              enableSuggestions: false,
              decoration: InputDecoration(
                labelText: 'API key',
                hintText: 'AIza...',
                suffixIcon: IconButton(
                  icon: Icon(_obscure ? Icons.visibility_rounded : Icons.visibility_off_rounded),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            InkWell(
              onTap: () => launchUrl(
                Uri.parse('https://aistudio.google.com/apikey'),
                mode: LaunchMode.externalApplication,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.open_in_new_rounded, size: 16, color: AppColors.primaryDark),
                  const SizedBox(width: 6),
                  Text(
                    'Get a free Gemini API key',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primaryDark),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              label: 'Save key',
              icon: Icons.check_rounded,
              loading: _saving,
              onPressed: _save,
            ),
            const SizedBox(height: AppSpacing.md),
            AppSecondaryButton(
              label: _testing ? 'Testing...' : 'Test connection',
              icon: Icons.bolt_rounded,
              onPressed: _testing ? null : _testKey,
            ),
            const SizedBox(height: AppSpacing.md),
            TextButton(
              onPressed: _clear,
              child: const Text('Remove saved key', style: TextStyle(color: AppColors.destructive)),
            ),
            const SizedBox(height: AppSpacing.xxl),
            const Divider(),
            const SizedBox(height: AppSpacing.lg),
            Text('About', style: AppTextStyles.headline),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Caption IQ reads text from your screenshots entirely on-device with '
              'Google ML Kit — the images themselves are never uploaded. Only the '
              'extracted text and the resulting summaries are saved to your private '
              'history.',
              style: AppTextStyles.body,
            ),
          ],
        ),
      ),
    );
  }
}
