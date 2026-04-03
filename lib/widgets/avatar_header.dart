import 'package:flutter/material.dart';

class AvatarHeader extends StatelessWidget {
  const AvatarHeader({super.key, required this.userName, required this.partnerName});

  final String userName;
  final String partnerName;

  Widget _avatar(String label, List<Color> colors) {
    return Column(
      children: [
        Container(
          width: 78,
          height: 78,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: colors),
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 12)],
          ),
          child: const Icon(Icons.face_retouching_natural, size: 42),
        ),
        const SizedBox(height: 8),
        Text(label),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _avatar(userName, const [Color(0xFF42A5F5), Color(0xFF7E57C2)]),
        const Icon(Icons.favorite, color: Colors.pinkAccent),
        _avatar(partnerName, const [Color(0xFFEC407A), Color(0xFFFF7043)]),
      ],
    );
  }
}
