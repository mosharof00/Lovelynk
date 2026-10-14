import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_color.dart';
import '../../core/utils/logger.dart';
import '../../data/repositories/user_repository.dart';
import 'cached_image.dart';

/// Circular avatar: the photo at [avatarPath] (private `avatars` bucket)
/// when set, otherwise the initials of [name].
class InitialsAvatar extends StatelessWidget {
  const InitialsAvatar({
    super.key,
    required this.name,
    required this.size,
    this.avatarPath,
  });

  final String name;
  final double size;
  final String? avatarPath;

  static String initialsOf(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    if (parts.isEmpty) return '';
    final first = parts.first.characters.first;
    final last = parts.length > 1 ? parts.last.characters.first : '';
    return (first + last).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final path = avatarPath;
    if (path == null || path.isEmpty) return _initials();

    final cached = AvatarUrlCache.peek(path);
    if (cached != null) return _photo(cached, path);

    return FutureBuilder<String?>(
      future: AvatarUrlCache.get(path),
      builder: (context, snapshot) {
        final url = snapshot.data;
        return url == null ? _initials() : _photo(url, path);
      },
    );
  }

  Widget _photo(String url, String path) {
    return CachedImage(
      imgUrl: url,
      cacheKey: path,
      height: size,
      width: size,
      borderRadius: size,
    );
  }

  Widget _initials() {
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

/// Signed avatar URLs, reused until shortly before they expire.
class AvatarUrlCache {
  AvatarUrlCache._();

  static const _ttl = Duration(hours: 23);
  static final _urls = <String, (String, DateTime)>{};
  static final _pending = <String, Future<String?>>{};

  static String? peek(String path) {
    final entry = _urls[path];
    if (entry == null || DateTime.now().isAfter(entry.$2)) return null;
    return entry.$1;
  }

  static Future<String?> get(String path) {
    final cached = peek(path);
    if (cached != null) return Future.value(cached);
    return _pending[path] ??= _fetch(path);
  }

  static Future<String?> _fetch(String path) async {
    try {
      final url = await Get.find<IUserRepository>().avatarUrl(path);
      _urls[path] = (url, DateTime.now().add(_ttl));
      return url;
    } catch (e) {
      Log.w('[Avatar] signed URL failed: $e');
      return null;
    } finally {
      _pending.remove(path);
    }
  }

  static void clear() {
    _urls.clear();
    _pending.clear();
  }
}
