import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../services/pack_manager.dart';

class CustomPackScreen extends StatefulWidget {
  const CustomPackScreen({super.key});

  @override
  State<CustomPackScreen> createState() => _CustomPackScreenState();
}

class _CustomPackScreenState extends State<CustomPackScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _truthController = TextEditingController();
  final TextEditingController _dareController = TextEditingController();
  final TextEditingController _packNameController = TextEditingController(text: 'My Custom Pack');

  String? _activePackId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _truthController.dispose();
    _dareController.dispose();
    _packNameController.dispose();
    super.dispose();
  }

  void _createPackIfNeeded() {
    if (_activePackId == null) {
      final packManager = context.read<PackManager>();
      packManager.addCustomPack(_packNameController.text);
      setState(() {
        _activePackId = packManager.customPacks.last.id;
      });
    }
  }

  void _addPrompt(String type) {
    _createPackIfNeeded();
    final controller = type == 'truth' ? _truthController : _dareController;
    if (controller.text.trim().isEmpty) return;

    HapticFeedback.lightImpact();
    context.read<PackManager>().addPromptToCustomPack(
          _activePackId!,
          controller.text.trim(),
          type,
        );
    controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              // App Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'CUSTOM PACK',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryNeon,
                        letterSpacing: 2,
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              // Pack Name
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: _packNameController,
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Pack Name...',
                    hintStyle: GoogleFonts.poppins(color: AppColors.textMuted),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 8),
              // Tab Bar
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.truthBlue, AppColors.truthBlueDark],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15),
                  unselectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 15),
                  labelColor: Colors.white,
                  unselectedLabelColor: AppColors.textMuted,
                  tabs: const [
                    Tab(text: '💙 Truth'),
                    Tab(text: '❤️ Dare'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Tab Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildPromptTab('truth', _truthController, AppColors.truthBlue),
                    _buildPromptTab('dare', _dareController, AppColors.dareRed),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPromptTab(String type, TextEditingController controller, Color accentColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Input Field
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: accentColor.withAlpha(60)),
                  ),
                  child: TextField(
                    controller: controller,
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Type a ${type == 'truth' ? 'truth' : 'dare'}...',
                      hintStyle: GoogleFonts.poppins(color: AppColors.textMuted),
                    ),
                    onSubmitted: (_) => _addPrompt(type),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () => _addPrompt(type),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.add_rounded, color: Colors.white, size: 24),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // List
          Expanded(
            child: Consumer<PackManager>(
              builder: (context, pm, _) {
                if (_activePackId == null) {
                  return Center(
                    child: Text(
                      'Start adding ${type}s!',
                      style: GoogleFonts.poppins(color: AppColors.textMuted, fontSize: 16),
                    ),
                  );
                }
                final packIndex = pm.customPacks.indexWhere((p) => p.id == _activePackId);
                if (packIndex == -1) {
                  return const SizedBox.shrink();
                }
                final prompts = pm.customPacks[packIndex].prompts.where((p) => p.type == type).toList();
                if (prompts.isEmpty) {
                  return Center(
                    child: Text(
                      'No ${type}s yet. Add one above!',
                      style: GoogleFonts.poppins(color: AppColors.textMuted),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: prompts.length,
                  itemBuilder: (context, index) {
                    final prompt = prompts[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.surfaceBright),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              prompt.text,
                              style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              pm.removePromptFromCustomPack(_activePackId!, prompt.id);
                            },
                            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.dareRed, size: 20),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
