import 'package:flutter/material.dart';

class AnimatedViewToggle extends StatelessWidget {
  const AnimatedViewToggle({
    super.key,
    required this.partnerView,
    required this.onToggle,
  });

  final bool partnerView;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(4),
        width: 220,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white12,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Stack(
          children: [
            AnimatedAlign(
              duration: const Duration(milliseconds: 300),
              alignment: partnerView ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 105,
                decoration: BoxDecoration(
                  color: Colors.deepPurpleAccent,
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text('User View'),
                Text('Partner View'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
