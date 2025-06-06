import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/state/api_state.dart';
import '../../../../data/models/story_model.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/story_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../../routes/app_router.dart';
import '../../../widget/error_widget.dart' as custom_error_widget;
import '../../../widget/loading_shimmer.dart';

import '../widget/story_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.isLoggedIn && authProvider.currentUser?.token != null) {
        context.read<StoryProvider>().getStories();
      }
    });
  }

  Future<void> _refreshStories() async {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.isLoggedIn && authProvider.currentUser?.token != null) {
      await context.read<StoryProvider>().getStories();
    }
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        final l10n = AppLocalizations.of(dialogContext)!;
        return AlertDialog(
          title: Text(l10n.logout),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => dialogContext.pop(),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<AuthProvider>().logout();
                dialogContext.pop(); // Pop dialog after logout action
              },
              child: Text(l10n.logout),
            ),
          ],
        );
      },
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Select Language'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('English'),
                leading: const Text('🇺🇸'),
                onTap: () {
                  context.read<ThemeProvider>().setLanguage('en');
                  dialogContext.pop();
                },
              ),
              ListTile(
                title: const Text('Bahasa Indonesia'),
                leading: const Text('🇮🇩'),
                onTap: () {
                  context.read<ThemeProvider>().setLanguage('id');
                  dialogContext.pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.stories),
        actions: [
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return IconButton(
                icon: Icon(
                  themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                ),
                onPressed: () => themeProvider.toggleTheme(),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: _showLanguageDialog,
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    const Icon(Icons.logout),
                    const SizedBox(width: 8),
                    Text(l10n.logout),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'logout') {
                _logout();
              }
            },
          ),
        ],
      ),
      body: Consumer<StoryProvider>(
        builder: (context, storyProvider, child) {
          return RefreshIndicator(
            onRefresh: _refreshStories,
            child: _buildStoryList(storyProvider, l10n),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push(AppRouter.addStoryPath);
        },
        icon: const Icon(Icons.add),
        label: Text(l10n.addStory),
      ),
    );
  }

  Widget _buildStoryList(StoryProvider storyProvider, AppLocalizations l10n) {
    final storiesState = storyProvider.storiesState;

    if (storiesState is ApiLoading) {
      return ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) {
          return const LoadingShimmer(
            isLoading: true,
            child: StoryCardShimmer(),
          );
        },
      );
    }

    if (storiesState is ApiSuccess<List<Story>>) {
      final stories = storiesState.data;
      if (stories.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.auto_stories_outlined,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                l10n.noStoriesFound,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        itemCount: stories.length,
        itemBuilder: (context, index) {
          final story = stories[index];
          return StoryCard(
            story: story,
            onTap: () {
              context.push(
                Uri(
                  path: AppRouter.storyDetailPath
                      .replaceFirst(':storyId', story.id),
                ).toString(),
                extra: story,
              );
            },
          );
        },
      );
    }

    if (storiesState is ApiError) {
      return custom_error_widget.CustomErrorWidget(
        message:  (storyProvider.storiesState as ApiError).message,
        onRetry: _refreshStories,
      );
    }

    return const Center(child: Text("Welcome! Pull to refresh stories."));
  }
}
