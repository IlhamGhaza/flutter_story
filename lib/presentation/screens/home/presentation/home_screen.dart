import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/state/api_state.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/story_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../../widget/error_widget.dart';
import '../../../widget/loading_shimmer.dart';
import '../../auth/login_screen.dart';
import '../widget/story_card.dart';
import 'add_story_screen.dart';
import 'story_detail_screen.dart';


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
      context.read<StoryProvider>().getStories();
    });
  }

  Future<void> _refreshStories() async {
    await context.read<StoryProvider>().getStories();
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return AlertDialog(
          title: Text(l10n.logout),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<AuthProvider>().logout();
                Navigator.of(context).pushReplacement(
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const LoginPage(),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                  ),
                );
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
      builder: (context) {
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
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: const Text('Bahasa Indonesia'),
                leading: const Text('🇮🇩'),
                onTap: () {
                  context.read<ThemeProvider>().setLanguage('id');
                  Navigator.of(context).pop();
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
            child: _buildStoryList(storyProvider),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const AddStoryPage(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return SlideTransition(
                  position: animation.drive(
                    Tween(begin: const Offset(0.0, 1.0), end: Offset.zero),
                  ),
                  child: child,
                );
              },
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: Text(l10n.addStory),
      ),
    );
  }

  Widget _buildStoryList(StoryProvider storyProvider) {
    final l10n = AppLocalizations.of(context)!;

    switch (storyProvider.storiesState) {
      case ApiLoading():
        return ListView.builder(
          itemCount: 5,
          itemBuilder: (context, index) {
            return LoadingShimmer(
              isLoading: true,
              child: const StoryCardShimmer(),
            );
          },
        );

      case ApiSuccess():
        final stories = storyProvider.stories;
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
                Navigator.of(context).push(
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        StoryDetailPage(story: story),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                  ),
                );
              },
            );
          },
        );

      case ApiError():
        return CustomErrorWidget(
          message: (storyProvider.storiesState as ApiError).message,
          onRetry: _refreshStories,
        );

      default:
        return const SizedBox.shrink();
    }
  }
}
