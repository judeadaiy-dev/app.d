import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppSettings {
  final bool maintenanceMode;
  final String appVersion;
  final String welcomeMessage;
  final bool allowRegistration;

  AppSettings({
    required this.maintenanceMode,
    required this.appVersion,
    required this.welcomeMessage,
    required this.allowRegistration,
  });

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      maintenanceMode: json['maintenance_mode']?? false,
      appVersion: json['app_version']?? '1.0.0',
      welcomeMessage: json['welcome_message']?? 'مرحبا بك',
      allowRegistration: json['allow_registration']?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'maintenance_mode': maintenanceMode,
      'app_version': appVersion,
      'welcome_message': welcomeMessage,
      'allow_registration': allowRegistration,
    };
  }
}

class AppSettingsProvider extends ChangeNotifier {
  final SupabaseClient supabase = Supabase.instance.client;
  AppSettings? settings; // تم التأكد من الاسم settings
  bool isLoading = false;

  // الدالة loadSettings موجودة
  Future<void> loadSettings() async {
    try {
      isLoading = true;
      notifyListeners();

      final response = await supabase
        .from('app_settings')
        .select()
        .single();

      settings = AppSettings.fromJson(response);
      isLoading = false;
      notifyListeners();
    } catch (e) {
      // اذا ما لقى جدول، يستخدم القيم الافتراضية
      settings = AppSettings(
        maintenanceMode: false,
        appVersion: '1.0.0',
        welcomeMessage: 'مرحبا بك في التطبيق',
        allowRegistration: true,
      );
      isLoading = false;
      notifyListeners();
      debugPrint('Error loading settings: $e');
    }
  }

  Future<void> updateSettings(AppSettings newSettings) async {
    try {
      await supabase.from('app_settings').upsert(newSettings.toJson());
      settings = newSettings;
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating settings: $e');
      rethrow;
    }
  }
}
