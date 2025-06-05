// lib/presentation/screens/home/presentation/add_story_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart'; // Import GoRouter

import '../../../../core/state/api_state.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../providers/story_provider.dart';
import '../../../widget/loading_shimmer.dart';

class AddStoryPage extends StatefulWidget {
  const AddStoryPage({super.key});

  @override
  State<AddStoryPage> createState() => _AddStoryPageState();
}

class _AddStoryPageState extends State<AddStoryPage> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _imagePicker = ImagePicker();
  File? _selectedImage;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    // final l10n = AppLocalizations.of(context)!; // Tidak digunakan di sini

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _uploadStory() {
    if (_formKey.currentState!.validate() && _selectedImage != null) {
      context.read<StoryProvider>().addStory(
            _descriptionController.text.trim(),
            _selectedImage!,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.addStory),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            context.read<StoryProvider>().resetAddStoryState();
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/'); // Fallback ke home jika tidak bisa pop
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onTap: _showImageSourceDialog,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey,
                      style: BorderStyle.solid,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            _selectedImage!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_a_photo,
                              size: 48,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              l10n.selectImage,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: l10n.description,
                  alignLabelWithHint: true,
                  hintText: 'Tell your story...',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a description';
                  }
                  if (value.trim().length < 10) {
                    return 'Description must be at least 10 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              Consumer<StoryProvider>(
                builder: (context, storyProvider, child) {
                  // Listener untuk navigasi setelah upload berhasil
                  if (storyProvider.addStoryState is ApiSuccess) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.storyUploadSuccess),
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                          ),
                        );
                        storyProvider.resetAddStoryState(); // Reset state dulu
                        if (context.canPop()) {
                          context.pop(); // Baru pop
                        } else {
                          context.go('/'); // Fallback
                        }
                      }
                    });
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      LoadingShimmer(
                        isLoading: storyProvider.addStoryState is ApiLoading,
                        child: ElevatedButton(
                          onPressed:
                              (storyProvider.addStoryState is ApiLoading ||
                                      _selectedImage == null)
                                  ? null
                                  : _uploadStory,
                          child: storyProvider.addStoryState is ApiLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Text(l10n.uploadStory),
                        ),
                      ),
                      if (_selectedImage == null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Please select an image first',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      if (storyProvider.addStoryState is ApiError) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.errorContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            (storyProvider.addStoryState as ApiError).message,
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onErrorContainer,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                      // Hapus navigasi eksplisit di sini, sudah ditangani di atas
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
