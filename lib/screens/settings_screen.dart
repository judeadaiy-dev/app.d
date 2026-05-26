import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/app_settings_provider.dart';
import '../widgets/glass_container.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isAdmin = auth.isAdmin;

    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // قسم الحساب
          _buildSectionTitle(context, 'الحساب'),
          const SizedBox(height: 12),
          
          GlassContainer(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _buildSettingTile(
                  context,
                  icon: Icons.person_outline_rounded,
                  title: 'الملف الشخصي',
                  subtitle: 'تعديل معلوماتك وصورتك',
                  onTap: () {
                    Navigator.of(context).pushNamed('/profile');
                  },
                ),
                const Divider(height: 1),
                _buildSettingTile(
                  context,
                  icon: Icons.lock_outline_rounded,
                  title: 'الخصوصية والأمان',
                  subtitle: 'كلمة المرور والتحقق',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('قريباً')),
                    );
                  },
                ),
                const Divider(height: 1),
                _buildSettingTile(
                  context,
                  icon: Icons.notifications_outlined,
                  title: 'الإشعارات',
                  subtitle: 'إدارة التنبيهات',
                  onTap: () {
                    Navigator.of(context).pushNamed('/notifications');
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // قسم المظهر
          _buildSectionTitle(context, 'المظهر'),
          const SizedBox(height: 12),

          GlassContainer(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _buildSettingTile(
                  context,
                  icon: Icons.palette_outlined,
                  title: 'الثيم',
                  subtitle: 'فاتح / داكن / تلقائي',
                  trailing: Consumer<AppSettingsProvider>(
                    builder: (context, settings, _) {
                      return DropdownButton<String>(
                        value: 'auto',
                        underline: const SizedBox(),
                        items: const [
                          DropdownMenuItem(value: 'light', child: Text('فاتح')),
                          DropdownMenuItem(value: 'dark', child: Text('داكن')),
                          DropdownMenuItem(value: 'auto', child: Text('تلقائي')),
                        ],
                        onChanged: (value) {
                          // تحديث الثيم
                        },
                      );
                    },
                  ),
                ),
                const Divider(height: 1),
                _buildSettingTile(
                  context,
                  icon: Icons.image_outlined,
                  title: 'خلفية المحادثة',
                  subtitle: 'تغيير خلفية الشات',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('قريباً')),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // قسم الإدارة - للأدمن فقط
          if (isAdmin) ...[
            _buildSectionTitle(context, 'الإدارة'),
            const SizedBox(height: 12),
            
            GlassContainer(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _buildSettingTile(
                    context,
                    icon: Icons.dashboard_rounded,
                    title: 'لوحة التحكم',
                    subtitle: 'إدارة التطبيق والمستخدمين',
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'أدمن',
                        style: TextStyle(
                          color: AppColors.primaryForeground,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    onTap: () {
                      Navigator.of(context).pushNamed('/admin');
                    },
                  ),
                  const Divider(height: 1),
                  _buildSettingTile(
                    context,
                    icon: Icons.settings_suggest_rounded,
                    title: 'إعدادات التطبيق',
                    subtitle: 'تغيير الشعار والاسم',
                    onTap: () {
                      Navigator.of(context).pushNamed('/admin');
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // قسم المساعدة
          _buildSectionTitle(context, 'المساعدة والدعم'),
          const SizedBox(height: 12),

          GlassContainer(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _buildSettingTile(
                  context,
                  icon: Icons.help_outline_rounded,
                  title: 'مركز المساعدة',
                  subtitle: 'الأسئلة الشائعة',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('قريباً')),
                    );
                  },
                ),
                const Divider(height: 1),
                _buildSettingTile(
                  context,
                  icon: Icons.info_outline_rounded,
                  title: 'حول التطبيق',
                  subtitle: 'الإصدار 1.0.0',
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: 'تطبيق المحادثة',
                      applicationVersion: '1.0.0',
                      applicationIcon: const Icon(Icons.chat_bubble_rounded, size: 48),
                      children: [
                        const Text('تطبيق محادثة مبني بـ Flutter و Supabase'),
                      ],
                    );
                  },
                ),
                const Divider(height: 1),
                _buildSettingTile(
                  context,
                  icon: Icons.logout_rounded,
                  title: 'تسجيل الخروج',
                  subtitle: 'الخروج من الحساب',
                  textColor: Colors.red,
                  onTap: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('تسجيل الخروج'),
                        content: const Text('هل أنت متأكد؟'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('إلغاء'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                            child: const Text('خروج'),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true && context.mounted) {
                      await context.read<AuthProvider>().signOut();
                      Navigator.of(context).pushNamedAndRemoveUntil('/welcome', (r) => false);
                    }
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        fontFamily: 'Cairo',
      ),
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    Color? textColor,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontFamily: 'Cairo',
          color: textColor,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 13,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontFamily: 'Cairo',
        ),
      ),
      trailing: trailing?? const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}
