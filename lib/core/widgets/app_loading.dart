import 'package:flutter/material.dart';

class AppLoading extends StatelessWidget {
  final String? text;

  const AppLoading({
    super.key,
    this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(
            color: Color(0xFF2E7D32),
          ),
          if (text != null) ...[
            const SizedBox(height: 14),
            Text(
              text!,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
              ),
            ),
          ],
        ],
      ),
    );
  }
}