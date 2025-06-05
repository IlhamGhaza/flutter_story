// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// import '../providers/auth_provider.dart';
// import '../screens/auth/login_screen.dart';
// import '../screens/auth/register_screen.dart';
// import '../screens/home/presentation/home_screen.dart';
// import '../screens/home/presentation/story_detail_screen.dart';
// import '../screens/home/presentation/add_story_screen.dart';

// class AppRouter {
//   static const String initialRoute = '/';
//   static const String login = '/login';
//   static const String register = '/register';
//   static const String home = '/home';
//   static const String storyDetail = '/story-detail';
//   static const String addStory = '/add-story';

//   static Route<dynamic> onGenerateRoute(RouteSettings settings) {
//     switch (settings.name) {
//       case initialRoute:
//         return MaterialPageRoute(
//           builder: (_) => Consumer<AuthProvider>(
//             builder: (context, auth, _) {
//               if (auth.isLoggedIn) {
//                 return const HomeScreen();
//               }
//               return const LoginScreen();
//             },
//           ),
//         );

//       case login:
//         return MaterialPageRoute(builder: (_) => const LoginScreen());

//       case register:
//         return MaterialPageRoute(builder: (_) => const RegisterScreen());

//       case home:
//         return MaterialPageRoute(builder: (_) => const HomeScreen());

//       case storyDetail:
//         final args = settings.arguments as Map<String, dynamic>;
//         return MaterialPageRoute(
//           builder: (_) => StoryDetailScreen(
//             storyId: args['storyId'] as String,
//             photoUrl: args['photoUrl'] as String,
//           ),
//         );

//       case addStory:
//         return MaterialPageRoute(builder: (_) => const AddStoryPage());

//       default:
//         return MaterialPageRoute(
//           builder: (_) => Scaffold(
//             body: Center(child: Text('No route defined for ${settings.name}')),
//           ),
//         );
//     }
//   }
// }
