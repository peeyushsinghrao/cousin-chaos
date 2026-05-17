import 'package:cousin_chaos/core/icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../services/supabase_service.dart';
import 'lobby_screen.dart';

class RoomScreen extends StatefulWidget {
  const RoomScreen({super.key});

  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _createRoom() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Enter your name first');
      return;
    }
    if (!SupabaseService.isAvailable) {
      setState(() => _error = 'Multiplayer is not configured yet');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      final room = await SupabaseService.instance.createRoom(
        hostName: name,
        gameMode: 'Truth or Dare',
      );
      if (!mounted) return;
      if (room != null) {
        Navigator.push(context, MaterialPageRoute(
          builder: (_) => LobbyScreen(
            roomId: room['id'],
            roomCode: room['code'],
            playerName: name,
            isHost: true,
          ),
        ));
      }
    } catch (e) {
      setState(() => _error = 'Failed to create room. Check connection.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _joinRoom() async {
    final name = _nameController.text.trim();
    final code = _codeController.text.trim().toUpperCase();
    if (name.isEmpty) {
      setState(() => _error = 'Enter your name first');
      return;
    }
    if (code.length != 6) {
      setState(() => _error = 'Enter a valid 6-character room code');
      return;
    }
    if (!SupabaseService.isAvailable) {
      setState(() => _error = 'Multiplayer is not configured yet');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      final room = await SupabaseService.instance.joinRoom(
        code: code,
        playerName: name,
      );
      if (!mounted) return;
      if (room != null) {
        Navigator.push(context, MaterialPageRoute(
          builder: (_) => LobbyScreen(
            roomId: room['id'],
            roomCode: room['code'],
            playerName: name,
            isHost: false,
          ),
        ));
      } else {
        setState(() => _error = 'Room not found or already started');
      }
    } catch (e) {
      setState(() => _error = 'Failed to join room. Check the code.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF08041A), Color(0xFF0E0624), Color(0xFF08041A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 12, 20, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white70, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      'Multiplayer',
                      style: GoogleFonts.sora(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              _buildFloatingIcon(),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _buildNameField(),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(8),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withAlpha(15)),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white38,
                    indicator: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    labelStyle: GoogleFonts.sora(fontSize: 13, fontWeight: FontWeight.w700),
                    tabs: const [
                      Tab(text: 'Create Room'),
                      Tab(text: 'Join Room'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildCreateTab(),
                    _buildJoinTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingIcon() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.95, end: 1.05),
      duration: const Duration(seconds: 2),
      curve: Curves.easeInOut,
      builder: (_, val, child) => Transform.scale(scale: val, child: child),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: AppColors.primaryGradient,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withAlpha(80),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),
        child: const Icon(Icons.wifi_rounded, color: Colors.white, size: 36),
      ),
    );
  }

  Widget _buildNameField() {
    return TextField(
      controller: _nameController,
      style: GoogleFonts.sora(color: Colors.white, fontSize: 15),
      cursorColor: AppColors.primary,
      textCapitalization: TextCapitalization.words,
      decoration: InputDecoration(
        labelText: 'Your Name',
        labelStyle: GoogleFonts.sora(color: Colors.white38, fontSize: 13),
        prefixIcon: Icon(LucideIcons.user, color: AppColors.primary, size: 18),
        filled: true,
        fillColor: Colors.white.withAlpha(8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withAlpha(20)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withAlpha(20)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.primary.withAlpha(180), width: 1.5),
        ),
      ),
    );
  }

  Widget _buildCreateTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _buildInfoCard(
            icon: LucideIcons.link,
            color: AppColors.primary,
            title: 'Host a game',
            subtitle: 'Create a room and share the code with friends to join from their devices.',
          ),
          const SizedBox(height: 24),
          if (_error != null) _buildError(),
          _buildActionButton(
            label: _loading ? 'Creating...' : 'Create Room',
            icon: LucideIcons.plus,
            gradient: AppColors.primaryGradient,
            onTap: _loading ? null : _createRoom,
          ),
        ],
      ),
    );
  }

  Widget _buildJoinTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          TextField(
            controller: _codeController,
            style: GoogleFonts.sora(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: 8,
            ),
            textAlign: TextAlign.center,
            textCapitalization: TextCapitalization.characters,
            maxLength: 6,
            cursorColor: AppColors.secondary,
            decoration: InputDecoration(
              hintText: 'XXXXXX',
              hintStyle: GoogleFonts.sora(
                color: Colors.white12,
                fontSize: 28,
                fontWeight: FontWeight.w800,
                letterSpacing: 8,
              ),
              counterText: '',
              filled: true,
              fillColor: Colors.white.withAlpha(8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(color: Colors.white.withAlpha(20)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(color: Colors.white.withAlpha(20)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(color: AppColors.secondary.withAlpha(200), width: 2),
              ),
            ),
            onChanged: (v) {
              _codeController.value = _codeController.value.copyWith(
                text: v.toUpperCase(),
                selection: TextSelection.collapsed(offset: v.length),
              );
            },
          ),
          const SizedBox(height: 16),
          if (_error != null) _buildError(),
          const SizedBox(height: 8),
          _buildActionButton(
            label: _loading ? 'Joining...' : 'Join Room',
            icon: LucideIcons.arrowRight,
            gradient: AppColors.secondaryGradient,
            onTap: _loading ? null : _joinRoom,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({required IconData icon, required Color color, required String title, required String subtitle}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha(12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withAlpha(40)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withAlpha(22),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.sora(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                const SizedBox(height: 3),
                Text(subtitle, style: GoogleFonts.sora(color: Colors.white38, fontSize: 12), maxLines: 2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.dareRed.withAlpha(20),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.dareRed.withAlpha(60)),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline_rounded, color: AppColors.dareRed, size: 16),
            const SizedBox(width: 8),
            Expanded(child: Text(_error!, style: GoogleFonts.sora(color: AppColors.dareRed, fontSize: 12))),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({required String label, required IconData icon, required Gradient gradient, required VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: onTap == null ? 0.5 : 1.0,
        child: Container(
          width: double.infinity,
          height: 58,
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withAlpha(60),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Text(label, style: GoogleFonts.sora(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}
