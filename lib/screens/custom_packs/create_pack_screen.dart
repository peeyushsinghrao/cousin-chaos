import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_card.dart';
import '../../services/pack_manager.dart';

class CreatePackScreen extends StatefulWidget {
  const CreatePackScreen({super.key});

  @override
  State<CreatePackScreen> createState() => _CreatePackScreenState();
}

class _CreatePackScreenState extends State<CreatePackScreen> {
  final TextEditingController _nameController = TextEditingController();
  final List<TextEditingController> _itemControllers = [];

  @override
  void dispose() {
    _nameController.dispose();
    for (final controller in _itemControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addItemField() {
    setState(() {
      _itemControllers.add(TextEditingController());
    });
  }

  void _savePack() {
    final packName = _nameController.text.trim();
    if (packName.isEmpty || _itemControllers.isEmpty) return;
    final packManager = context.read<PackManager>();
    packManager.addCustomPack(packName);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Create Pack', style: GoogleFonts.sora(color: Colors.white, fontWeight: FontWeight.w800)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          children: [
            GlassCard(
              borderRadius: 24,
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  TextField(
                    controller: _nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Pack name',
                      hintStyle: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary),
                      border: InputBorder.none,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _itemControllers.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GlassCard(
                      borderRadius: 24,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _itemControllers[index],
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: 'Item ${index + 1}',
                                hintStyle: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: AppColors.dareRed),
                            onPressed: () {
                              setState(() {
                                _itemControllers.removeAt(index);
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _addItemField,
              child: GlassCard(
                borderRadius: 28,
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add_rounded, color: Colors.white),
                    const SizedBox(width: 12),
                    Text('ADD ITEM', style: GoogleFonts.sora(color: Colors.white, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _savePack,
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: AppTheme.neonGlow(AppColors.primary),
                ),
                child: Center(
                  child: Text('SAVE PACK',
                      style: GoogleFonts.sora(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
