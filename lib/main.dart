import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'utils/supabase_client.dart';
import 'theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/app_settings_provider.dart';
import 'providers/unread_provider.dart';
import 'providers/online_provider.dart';
import 'services/notification_service.dart';

import 'screens/index_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/reset_password_screen.dart';
import 'screens/chat_list_screen.dart';
import 'screens/chat_room_screen.dart';
import 'screens/private_chat_screen.dart';
import 'screens/rooms_screen.dart';
import 'screens/edit_room_screen.dart';
import 'screens/room_members_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/friends_screen.dart';
import 'screens/user_dashboard_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/privacy_screen.dart';
import 'screens/user_profile_screen.dart';
import 'screens/admin_screen.dart';
import 'screens/admin_settings_screen.dart';
import 'screens/not_found_screen.dart';
import 'widgets/protected_route.dart';

// FCM Background Handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Supabase
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  // Timeago Arabic
  timeago.setLocaleMessages('ar', timeago.ArMessages());

  // Status bar style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Notification Service
  await NotificationService.init();

  runApp(const DardashatiApp());
}

class DardashatiApp extends StatelessWidget {
  const DardashatiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AppSettingsProvider()),
        ChangeNotifierProvider(create: (_) => UnreadProvider()),
        ChangeNotifierProvider(create: (_) => OnlineProvider()),
      ],
      child: Consumer2<ThemeProvider, AppSettingsProvider>(
        builder: (context, theme, settings, child) {
          return MaterialApp(
            title: settings.settings.appName,
            debugShowCheckedModeBanner: false,
            locale: const Locale('ar'),
            supportedLocales: const [Locale('ar')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: theme.themeMode,
            builder: (context, child) {
              return Directionality(
                textDirection: TextDirection.rtl,
                child: child!,
              );
            },
            initialRoute: '/',
            onGenerateRoute: (settings) {
              // Public routes
              final publicRoutes = ['/', '/welcome', '/auth', '/reset-password', '/privacy'];

              // Protected routes
              final protectedRoutes = [
                '/chat',
                '/profile',
                '/friends',
                '/rooms',
                '/notifications',
                '/dashboard',
              ];

              // Admin routes
              final adminRoutes = ['/admin', '/admin/settings'];

              if (publicRoutes.contains(settings.name)) {
                return MaterialPageRoute(builder: (_) => _getPage(settings.name!));
              }

              if (protectedRoutes.contains(settings.name) ||
                  settings.name?.startsWith('/chat/') == true ||
                  settings.name?.startsWith('/dm/') == true ||
                  settings.name?.startsWith('/rooms/') == true ||
                  settings.name?.startsWith('/u/') == true) {
                return MaterialPageRoute(
                  builder: (_) => ProtectedRoute(child: _getPage(settings.name!)),
                );
              }

              if (adminRoutes.contains(settings.name)) {
                return MaterialPageRoute(
                  builder: (_) => ProtectedRoute(requireAdmin: true, child: _getPage(settings.name!)),
                );
              }

              return MaterialPageRoute(builder: (_) => const NotFoundScreen());
            },
          );
        },
      ),
    );
  }

  Widget _getPage(String route) {
    switch (route) {
      case '/':
        return const IndexScreen();
      case '/welcome':
        return const WelcomeScreen();
      case '/auth':
        return const AuthScreen();
      case '/reset-password':
        return const ResetPasswordScreen();
      case '/chat':
        return const ChatListScreen();
      case '/rooms':
        return const RoomsScreen();
      case '/profile':
        return const ProfileScreen();
      case '/friends':
        return const FriendsScreen();
      case '/notifications':
        return const NotificationsScreen();
      case '/dashboard':
        return const UserDashboardScreen();
      case '/privacy':
        return const PrivacyScreen();
      case '/admin':
        return const AdminScreen();
      case '/admin/settings':
        return const AdminSettingsScreen();
      default:
        if (route.startsWith('/chat/')) {
          final roomId = route.split('/')[2];
          return ChatRoomScreen(roomId: roomId);
        }
        if (route.startsWith('/dm/')) {
          final roomId = route.split('/')[2];
          return PrivateChatScreen(roomId: roomId);
        }
        if (route.startsWith('/rooms/') && route.endsWith('/edit')) {
          final roomId = route.split('/')[2];
          return EditRoomScreen(roomId: roomId);
        }
        if (route.startsWith('/rooms/') && route.endsWith('/members')) {
          final roomId = route.split('/')[2];
          return RoomMembersScreen(roomId: roomId);
        }
        if (route.startsWith('/u/')) {
          final userId = route.split('/')[2];
          return UserProfileScreen(userId: userId);
        }
        return const NotFoundScreen();
    }
  }
}
