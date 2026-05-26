import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // نفس viewport meta: user-scalable=no, maximum-scale=1.0
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // theme-color: #ffffff
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.white,
    statusBarIconBrightness: Brightness.dark, // default
    systemNavigationBarColor: Colors.white,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));

  runApp(const DardashatiApp());
}

class DardashatiApp extends StatelessWidget {
  const DardashatiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // title: دردشاتي | تطبيق دردشة عربي
      title: 'دردشاتي | تطبيق دردشة عربي',
      debugShowCheckedModeBanner: false,
      
      // lang="ar" dir="rtl"
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      
      // Theme مطابق للـ tailwind.config.js
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light, // darkMode: ["class"] = manual
      
      // <div id="root"></div> → هذا الهوم
      home: const RootScreen(),
    );
  }
}

class RootScreen extends StatelessWidget {
  const RootScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // هنا نحط اول صفحة بعدين
    return const Scaffold(
      body: Center(
        child: Text(
          'دردشاتي',
          style: TextStyle(fontFamily: 'Tajawal', fontSize: 24),
        ),
      ),
    );
  }
}
