import 'package:flutter/material.dart';

import '../../core/theme/app_color.dart';
import 'cached_image.dart';

/// Circular avatar: the photo when [imageUrl] is set, otherwise initials.
class InitialsAvatar extends StatelessWidget {
  const InitialsAvatar({
    super.key,
    required this.name,
    required this.size,
    this.imageUrl,
  });

  final String name;
  final double size;
  final String? imageUrl;

  static String initialsOf(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    if (parts.isEmpty) return '';
    final first = parts.first.characters.first;
    final last = parts.length > 1 ? parts.last.characters.first : '';
    return (first + last).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    if (url != null && url.isNotEmpty) {
      return CachedImage(
        imgUrl: url,
        height: size,
        width: size,
        borderRadius: size,
      );
    }

    final initials = initialsOf(name);
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: AppColor.primaryLight,
        shape: BoxShape.circle,
      ),
      child: initials.isEmpty
          ? Icon(
              Icons.person_rounded,
              size: size * 0.5,
              color: AppColor.primary.withValues(alpha: 0.7),
            )
          : Text(
              initials,
              style: TextStyle(
                fontSize: size * 0.36,
                fontWeight: FontWeight.w700,
                color: AppColor.primary,
              ),
            ),
    );
  }
}
