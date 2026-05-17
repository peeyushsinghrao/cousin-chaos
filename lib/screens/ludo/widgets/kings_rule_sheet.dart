import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class KingsRuleSheet extends StatefulWidget {
  final String kingName;
  final void Function(String rule) onConfirm;

  const KingsRuleSheet({
    super.key,
    required this.kingName,
    required this.onConfirm,
  });

  @override
  State<KingsRuleSheet> createState() => _KingsRuleSheetState();
}

class _KingsRuleSheetState extends State<KingsRuleSheet> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: AppColors.neonYellow.withAlpha(60)),
      ),
      padding: EdgeInsets.fromLTRB(
        24, 12, 24, MediaQuery.of(context).viewInsets.bottom + 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(30),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          const Text('👑', style: TextStyle(fontSize: 52)),
          const SizedBox(height: 12),
          Text(
            '${widget.kingName} is KING!',
            style: GoogleFonts.anybody(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.neonYellow,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Declare a rule for the next 3 rounds.',
            style: GoogleFonts.sora(
              fontSize: 13,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _controller,
            maxLength: 60,
            autofocus: true,
            style: GoogleFonts.sora(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'e.g. Everyone speaks in a British accent',
              hintStyle: GoogleFonts.sora(
                color: AppColors.textMuted, fontSize: 13,
              ),
              filled: true,
              fillColor: AppColors.surfaceContainerHigh,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: AppColors.neonYellow.withAlpha(80)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: AppColors.neonYellow.withAlpha(60)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: AppColors.neonYellow, width: 1.5),
              ),
              counterStyle: GoogleFonts.sora(color: AppColors.textMuted, fontSize: 10),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                final rule = _controller.text.trim();
                if (rule.isEmpty) return;
                widget.onConfirm(rule);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.neonYellow,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                'Proclaim Rule 👑',
                style: GoogleFonts.sora(
                  fontWeight: FontWeight.w800, fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
