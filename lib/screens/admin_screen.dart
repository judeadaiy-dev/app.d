import 'package:chat_app/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/app_settings_provider.dart';
import '../widgets/glass_container.dart';
import '../utils/supabase_client.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _appNameController = TextEditingController();
  final _logoUrlController = TextEditingController();

  Map<String, dynamic> _stats = {};
  List<Map<String, dynamic>> _users = [];
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _checkAdmin();
    _loadStats();
    _loadUsers();
    _loadSettings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _appNameController.dispose();
    _logoUrlController.dispose();
    super.dispose();
  }

  void _checkAdmin() {
    if (!context.read<AuthProvider>().isAdmin) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('غير مصرح لك بالدخول'),
            backgroundColor: Colors.red,
          ),
        );
      });
    }
  }

  Future<void> _loadStats() async {
    try {
      final usersCount = await supabase.from('profiles').select('id').count();
      final roomsCount = await supabase.from('rooms').select('id').count();
      final messagesCount = await supabase.from('messages').select('id').count();

      setState(() {
        _stats = {
          'users': usersCount.count,
          'rooms': roomsCount.count,
          'messages': messagesCount.count,
        };
        _loading = false;
      });
    } catch (e) {
      print('Error loading stats: $e');
      setState(() => _loading = false);
    }
  }

  Future<void> _loadUsers() async {
    try {
      final res = await supabase
        .from('profiles')
        .select('id, username, role, created_at, avatar_url')
        .order('created_at', ascending: false)
        .limit(50);

      setState(() => _users = (res as List).cast<Map<String, dynamic>>());
    } catch (e) {
      print('Error loading users: $e');
    }
  }

  void _loadSettings() {
    final settings = context.read<AppSettingsProvider>().settings;
    _appNameController.text = settings?.appName?? '';
    _logoUrlController.text = settings?.appLogoUrl?? '';
  }

  Future<void> _saveSettings() async {
    setState(() => _saving = true);

    try {
      await supabase.from('app_settings').update({
        'app_name': _appNameController.text.trim(),
        'app_logo_url': _logoUrlController.text.trim(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', 1);

      await context.read<AppSettingsProvider>().loadSettings();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حفظ الإعدادات'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _toggleUserRole(String userId, String currentRole) async {
    final newRole = currentRole == 'admin'? 'user' : 'admin';

    try {
      await supabase
        .from('profiles')
        .update({'role': newRole})
        .eq('id', userId);

      _loadUsers();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم تغيير الصلاحية إلى $newRole'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة التحكم'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'الإحصائيات'),
            Tab(text: 'المستخدمين'),
            Tab(text: 'الإعدادات'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildStatsTab(),
          _buildUsersTab(),
          _buildSettingsTab(),
        ],
      ),
    );
  }

  Widget _buildStatsTab() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadStats,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildStatCard(
            'إجمالي المستخدمين',
            '${_stats['users']?? 0}',
            Icons.people_rounded,
            Colors.blue,
          ),
          const SizedBox(height: 16),
          _buildStatCard(
            'إجمالي المحادثات',
            '${_stats['rooms']?? 0}',
            Icons.chat_rounded,
            Colors.green,
          ),
          const SizedBox(height: 16),
          _buildStatCard(
            'إجمالي الرسائل',
            '${_stats['messages']?? 0}',
            Icons.message_rounded,
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return GlassContainer(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontFamily: 'Cairo',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersTab() {
    return RefreshIndicator(
      onRefresh: _loadUsers,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _users.length,
        itemBuilder: (context, index) {
          final user = _users[index];
          final isAdmin = user['role'] == 'admin';

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GlassContainer(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundImage: user['avatar_url']!= null
                      ? NetworkImage(user['avatar_url'])
                        : null,
                    child: user['avatar_url'] == null
                      ? const Icon(Icons.person_rounded)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              user['username']?? 'مستخدم',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Cairo',
                              ),
                            ),
                            if (isAdmin)...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'أدمن',
                                  style: TextStyle(
                                    color: AppColors.primaryForeground,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        Text(
                          'انضم: ${_formatDate(user['created_at'])}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      isAdmin? Icons.admin_panel_settings : Icons.person_outline,
                      color: isAdmin? AppColors.primary : null,
                    ),
                    onPressed: () => _toggleUserRole(user['id'], user['role']),
                    tooltip: isAdmin? 'إزالة أدمن' : 'جعله أدمن',
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'إعدادات التطبيق',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 16),

          GlassContainer(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _appNameController,
                  decoration: const InputDecoration(
                    labelText: 'اسم التطبيق',
                    prefixIcon: Icon(Icons.title_rounded),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _logoUrlController,
                  decoration: const InputDecoration(
                    labelText: 'رابط الشعار',
                    prefixIcon: Icon(Icons.image_rounded),
                    hintText: 'https://example.com/logo.png',
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _saving? null : _saveSettings,
                    child: _saving
                      ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('حفظ الإعدادات'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return '';
    }
  }
}
