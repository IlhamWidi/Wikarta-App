import 'package:flutter/material.dart';
import 'glassmorph_card.dart';

class GlassmorphButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final bool loading;

  const GlassmorphButton({
    Key? key,
    required this.text,
    required this.onTap,
    this.loading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: GlassmorphCard(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: loading
              ? SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.3),
                )
              : Text(
                  text,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                ),
        ),
      ),
    );
  }
}