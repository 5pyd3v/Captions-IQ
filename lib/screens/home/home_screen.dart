import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../state/scan_controller.dart';
import '../../state/settings_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/image_grid_tile.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _picker = ImagePicker();
  bool _picking = false;

  Future<void> _pickImages() async {
    if (_picking) return;
    setState(() => _picking = true);
    try {
      final List<XFile> picked = await _picker.pickMultiImage(imageQuality: 92);
      if (picked.isEmpty) return;
      final files = picked.map((x) => File(x.path)).toList();
      ref.read(scanControllerProvider.notifier).addImages(files);
    } catch (_) {
      if (mounted) {
        AppSnackbar.show(context, 'Could not open the photo picker.', isError: true);
      }
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  void _startScan() {
    final hasKey = ref.read(settingsProvider).hasKey;
    if (!hasKey) {
      AppSnackbar.show(context, 'Add your Gemini API key in Settings first.', isError: true);
      context.push('/settings');
      return;
    }
    context.push('/processing');
  }

  @override
  Widget build(BuildContext context) {
    final scanState = ref.watch(scanControllerProvider);
    final images = scanState.images;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Caption IQ'),
        actions: [
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.tune_rounded),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: SafeArea(
        child: images.isEmpty
            ? Center(
                child: EmptyState(
                  icon: Icons.document_scanner_rounded,
                  title: 'Scan your caption screenshots',
                  message:
                      'Add 1 to 100+ screenshots. Caption IQ reads the text on-device, then turns it into a clear summary in English and Roman Urdu.',
                  action: SizedBox(
                    width: 220,
                    child: AppButton(
                      label: _picking ? 'Opening...' : 'Add screenshots',
                      icon: Icons.add_photo_alternate_rounded,
                      loading: _picking,
                      onPressed: _pickImages,
                    ),
                  ),
                ),
              )
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.sm,
                      AppSpacing.lg,
                      AppSpacing.sm,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${images.length} screenshot${images.length == 1 ? '' : 's'} selected',
                            style: AppTextStyles.title,
                          ),
                        ),
                        TextButton(
                          onPressed: () => ref.read(scanControllerProvider.notifier).clear(),
                          child: const Text('Clear all'),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        0,
                        AppSpacing.lg,
                        AppSpacing.lg,
                      ),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: AppSpacing.sm,
                        mainAxisSpacing: AppSpacing.sm,
                        childAspectRatio: 0.72,
                      ),
                      itemCount: images.length + 1,
                      itemBuilder: (context, index) {
                        if (index == images.length) {
                          return AddMoreTile(onTap: _pickImages);
                        }
                        return ImageGridTile(
                          file: images[index],
                          index: index,
                          onRemove: () =>
                              ref.read(scanControllerProvider.notifier).removeImageAt(index),
                        );
                      },
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.md,
                      AppSpacing.lg,
                      AppSpacing.lg,
                    ),
                    decoration: const BoxDecoration(
                      color: AppColors.surface,
                      border: Border(top: BorderSide(color: AppColors.divider)),
                    ),
                    child: SafeArea(
                      top: false,
                      child: AppButton(
                        label:
                            'Scan ${images.length} screenshot${images.length == 1 ? '' : 's'}',
                        icon: Icons.auto_awesome_rounded,
                        onPressed: _startScan,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
