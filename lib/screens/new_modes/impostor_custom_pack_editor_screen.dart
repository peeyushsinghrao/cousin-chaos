import 'package:cousin_chaos/core/icons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../models/impostor_word_pack.dart';
import '../../services/impostor_pack_manager.dart';

class ImpostorCustomPackEditorScreen extends StatefulWidget {
  final ImpostorWordPack? pack;

  const ImpostorCustomPackEditorScreen({super.key, this.pack});

  @override
  State<ImpostorCustomPackEditorScreen> createState() => _ImpostorCustomPackEditorScreenState();
}

class _ImpostorCustomPackEditorScreenState extends State<ImpostorCustomPackEditorScreen> {
  late TextEditingController _titleController;
  late TextEditingController _wordController;
  late List<String> _words;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.pack?.title ?? '');
    _wordController = TextEditingController();
    _words = widget.pack?.words.toList() ?? [];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _wordController.dispose();
    super.dispose();
  }

  void _savePack() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a name for your pack.')),
      );
      return;
    }

    if (_words.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one word to your pack.')),
      );
      return;
    }

    final manager = context.read<ImpostorPackManager>();
    if (widget.pack != null) {
      manager.updatePack(widget.pack!.copyWith(title: title, words: _words));
    } else {
      manager.addPack(title, _words);
    }

    Navigator.pop(context);
  }

  void _addWord() {
    final word = _wordController.text.trim();
    if (word.isEmpty) return;
    setState(() {
      _words.add(word);
      _wordController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.pack != null ? 'EDIT PACK' : 'NEW CUSTOM PACK',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.neonPink,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _savePack,
            child: Text(
              'SAVE',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pack Name',
              style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              style: GoogleFonts.poppins(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.surface,
                hintText: 'e.g. Party Secrets',
                hintStyle: TextStyle(color: AppColors.textSecondary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Add Words',
              style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _wordController,
                    style: GoogleFonts.poppins(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.surface,
                      hintText: 'Enter a secret word',
                      hintStyle: TextStyle(color: AppColors.textSecondary),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (_) => _addWord(),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _addWord,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.neonPink,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(LucideIcons.plus, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _words.isEmpty
                  ? Center(
                      child: Text(
                        'Add words to the pack. Each word will be used as a possible secret word for the Impostor game.',
                        style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.builder(
                      itemCount: _words.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppColors.surfaceBright),
                          ),
                          child: ListTile(
                            title: Text(
                              _words[index],
                              style: GoogleFonts.poppins(color: Colors.white),
                            ),
                            trailing: IconButton(
                              icon: const Icon(LucideIcons.x, color: AppColors.neonPink),
                              onPressed: () {
                                setState(() => _words.removeAt(index));
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
