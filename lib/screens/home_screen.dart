import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/work_session_provider.dart';
import '../services/location_service.dart';
import 'settings_screen.dart';
import 'holidays_screen.dart';
import 'leave_request_screen.dart';
import 'leave_approval_screen.dart';
import 'my_leaves_screen.dart';
import 'my_hours_screen.dart';
import 'workers_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  bool _dialogShown = false;

  // Upowa\u017cnieni do zatwierdzania urlop\u00f3w
  static const List<String> approverPhones = [
    '795561356', // Micha\u0142 Polak
    '608651538', // Bart\u0142omiej Drabicki
    '690205199', // Judyta Drabicka
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<WorkSessionProvider>(context, listen: false);
      if ((provider.userPhone == null || provider.userPhone!.isEmpty) && !_dialogShown) {
        _dialogShown = true;
        _showSelectEmployeeDialog();
      }
      provider.addListener(_checkLeaveNotification);
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Od\u015bwie\u017c lokalizacj\u0119 po powrocie do apki
      final provider = Provider.of<WorkSessionProvider>(context, listen: false);
      provider.checkLeaveStatus();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _checkLeaveNotification() {
    if (!mounted) return;
    final provider = Provider.of<WorkSessionProvider>(context, listen: false);
    if (provider.leaveNotification != null) {
      final msg = provider.leaveNotification!;
      provider.clearLeaveNotification();
      _showLeaveNotificationDialog(msg);
    }
  }

  void _showLeaveNotificationDialog(String message) {
    final isApproved = message.contains('ZATWIERDZONY');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1B2838),
        title: Row(
          children: [
            Icon(
              isApproved ? Icons.check_circle : Icons.cancel,
              color: isApproved ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 8),
            const Text('Wniosek urlopowy', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Text(message, style: const TextStyle(color: Colors.white70, fontSize: 16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSelectEmployeeDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1B2838),
        title: const Text('Witaj!', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Wpisz sw\u00f3j numer telefonu w Ustawieniach, aby rozpocz\u0105\u0107 prac\u0119.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()));
            },
            child: const Text('Przejd\u017a do Ustawie\u0144'),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating, duration: const Duration(seconds: 3)),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating, duration: const Duration(seconds: 2)),
    );
  }

  Future<void> _handleStart(WorkSessionProvider provider) async {
    final error = await provider.startWork();
    if (error != null) { _showError(error); } else { _showSuccess('Praca rozpocz\u0119ta \u2713'); }
  }

  Future<void> _handleStop(WorkSessionProvider provider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1B2838),
        title: const Text('Zako\u0144czy\u0107 prac\u0119?', style: TextStyle(color: Colors.white)),
        content: Text('Czas pracy: ${provider.elapsedFormatted}',
            style: const TextStyle(color: Colors.white70, fontSize: 18)),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Nie')),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Tak, ko\u0144cz\u0119'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      final error = await provider.stopWork();
      if (error != null) { _showError(error); } else { _showSuccess('Praca zako\u0144czona \u2713'); }
    }
  }

  Future<void> _handleBreak(WorkSessionProvider provider) async {
    final error = await provider.startBreak();
    if (error != null) { _showError(error); } else { _showSuccess('Przerwa rozpocz\u0119ta'); }
  }

  Future<void> _handleEndBreak(WorkSessionProvider provider) async {
    final error = await provider.endBreak();
    if (error != null) { _showError(error); } else { _showSuccess('Przerwa zako\u0144czona \u2713'); }
  }

  bool _isApprover(String? phone) {
    if (phone == null) return false;
    return approverPhones.contains(phone.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkSessionProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(provider.userPhone ?? 'INTERKLIMA',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            backgroundColor: const Color(0xFF1B2838),
            centerTitle: true,
          ),
          drawer: _buildDrawer(context, provider),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  Image.asset('assets/images/logo_transparent.png', height: 80, fit: BoxFit.contain),
                  const SizedBox(height: 24),

                  // Status lokalizacji
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: provider.locationStatusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: provider.locationStatusColor.withOpacity(0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_getLocationIcon(provider.locationStatus),
                            color: provider.locationStatusColor, size: 20),
                        const SizedBox(width: 8),
                        Text(provider.locationStatusText,
                            style: TextStyle(color: provider.locationStatusColor,
                                fontWeight: FontWeight.w600, fontSize: 14)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Licznik
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B2838),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(
                        color: _getTimerGlowColor(provider).withOpacity(0.2),
                        blurRadius: 20, spreadRadius: 2)],
                    ),
                    child: Column(
                      children: [
                        Text(_getStateLabel(provider.state),
                          style: TextStyle(color: _getStateColor(provider.state),
                            fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 2)),
                        const SizedBox(height: 12),
                        Text(provider.elapsedFormatted,
                          style: TextStyle(
                            color: provider.isIdle ? Colors.white38 : Colors.white,
                            fontSize: 56, fontWeight: FontWeight.w300,
                            fontFamily: 'monospace', letterSpacing: 4)),
                        if (provider.isOnBreak) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.coffee_rounded, color: Colors.orange, size: 20),
                                const SizedBox(width: 8),
                                Text('Przerwa: ${provider.breakElapsedFormatted}',
                                  style: const TextStyle(color: Colors.orange, fontSize: 24,
                                    fontWeight: FontWeight.w600, fontFamily: 'monospace')),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            provider.breakElapsed.inMinutes >= 30
                                ? '\u26A0 Przekroczono 30 min p\u0142atnej przerwy'
                                : 'P\u0142atna przerwa: do 30 min',
                            style: TextStyle(
                              color: provider.breakElapsed.inMinutes >= 30
                                  ? Colors.red.shade300 : Colors.white38,
                              fontSize: 12)),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  if (provider.isSending)
                    const Padding(
                      padding: EdgeInsets.all(24),
                      child: Column(children: [
                        CircularProgressIndicator(color: Color(0xFF4FC3F7)),
                        SizedBox(height: 12),
                        Text('Wysy\u0142anie...', style: TextStyle(color: Colors.white54)),
                      ]),
                    )
                  else
                    _buildButtons(provider),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildButtons(WorkSessionProvider provider) {
    switch (provider.state) {
      case WorkState.idle:
        return _buildActionButton(
          label: 'START PRACY', icon: Icons.play_arrow_rounded,
          color: const Color(0xFF4CAF50), onPressed: () => _handleStart(provider));
      case WorkState.working:
        return Column(children: [
          _buildActionButton(label: 'STOP PRACY', icon: Icons.stop_rounded,
            color: const Color(0xFFE53935), onPressed: () => _handleStop(provider)),
          const SizedBox(height: 16),
          _buildActionButton(label: 'PRZERWA', icon: Icons.pause_rounded,
            color: const Color(0xFFFFA726), onPressed: () => _handleBreak(provider), small: true),
        ]);
      case WorkState.onBreak:
        return Column(children: [
          _buildActionButton(label: 'KONIEC PRZERWY', icon: Icons.play_arrow_rounded,
            color: const Color(0xFFFFA726), onPressed: () => _handleEndBreak(provider)),
          const SizedBox(height: 16),
          _buildActionButton(label: 'STOP PRACY', icon: Icons.stop_rounded,
            color: const Color(0xFFE53935), onPressed: () => _handleStop(provider), small: true),
        ]);
    }
  }

  Widget _buildActionButton({
    required String label, required IconData icon, required Color color,
    required VoidCallback onPressed, bool small = false,
  }) {
    return SizedBox(
      width: double.infinity, height: small ? 56 : 72,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: small ? 24 : 32),
        label: Text(label, style: TextStyle(fontSize: small ? 16 : 20,
            fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color, foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4, shadowColor: color.withOpacity(0.4)),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, WorkSessionProvider provider) {
    return Drawer(
      backgroundColor: const Color(0xFF1B2838),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1B3A5C), Color(0xFF0F1923)],
                begin: Alignment.topLeft, end: Alignment.bottomRight)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Image.asset('assets/images/logo_transparent.png', height: 50),
                const SizedBox(height: 12),
                const Text('Dzia\u0142 Produkcja',
                    style: TextStyle(color: Colors.white70, fontSize: 14)),
              ],
            ),
          ),
          _drawerItem(icon: Icons.beach_access_rounded, title: 'Wniosek urlopowy', onTap: () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => const LeaveRequestScreen()));
          }),
          _drawerItem(icon: Icons.list_alt_rounded, title: 'Moje wnioski', onTap: () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => const MyLeavesScreen()));
          }),
          _drawerItem(icon: Icons.access_time_rounded, title: 'Moje godziny', onTap: () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => const MyHoursScreen()));
          }),
          if (_isApprover(provider.userPhone))
            _drawerItem(icon: Icons.approval_rounded, title: 'Zatwierdzanie urlop\u00f3w', onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const LeaveApprovalScreen()));
            }),
          if (_isApprover(provider.userPhone))
            _drawerItem(icon: Icons.people_rounded, title: 'Lokalizacja pracownik\u00f3w', onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const WorkersListScreen()));
            }),
          _drawerItem(icon: Icons.calendar_month_rounded, title: 'Dni wolne 2026', onTap: () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => const HolidaysScreen()));
          }),
          const Divider(color: Colors.white12),
          _drawerItem(icon: Icons.settings_rounded, title: 'Ustawienia', onTap: () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
          }),
        ],
      ),
    );
  }

  Widget _drawerItem({required IconData icon, required String title, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      onTap: onTap,
    );
  }

  IconData _getLocationIcon(LocationStatus status) {
    switch (status) {
      case LocationStatus.inCompany: return Icons.location_on;
      case LocationStatus.outsideCompany: return Icons.location_off;
      case LocationStatus.gpsDisabled: return Icons.gps_off;
      case LocationStatus.permissionDenied: return Icons.block;
      case LocationStatus.loading: return Icons.my_location;
    }
  }

  String _getStateLabel(WorkState state) {
    switch (state) {
      case WorkState.idle: return 'GOTOWY';
      case WorkState.working: return 'W PRACY';
      case WorkState.onBreak: return 'PRZERWA';
    }
  }

  Color _getStateColor(WorkState state) {
    switch (state) {
      case WorkState.idle: return Colors.white38;
      case WorkState.working: return Colors.green;
      case WorkState.onBreak: return Colors.orange;
    }
  }

  Color _getTimerGlowColor(WorkSessionProvider provider) {
    switch (provider.state) {
      case WorkState.idle: return Colors.blueGrey;
      case WorkState.working: return Colors.green;
      case WorkState.onBreak: return Colors.orange;
    }
  }
}
