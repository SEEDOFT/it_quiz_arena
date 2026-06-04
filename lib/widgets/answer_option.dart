import 'package:flutter/material.dart';

class AnswerOption extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final Color color;

  const AnswerOption({
    super.key,
    required this.text,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,

      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.all(16),

        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),

        child: Text(text, style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}
