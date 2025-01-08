import 'package:flutter/material.dart';
import '../../models/vo/attachment_vo.dart';

class UserAvatar extends StatelessWidget {
  final AttachmentVO? avatar;
  final double size;
  final VoidCallback? onTap;

  const UserAvatar({
    super.key,
    this.avatar,
    this.size = 48,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colorScheme.secondaryContainer,
        ),
        child: avatar?.file != null
            ? ClipOval(
                child: Image.file(
                  avatar!.file!,
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                ),
              )
            : Icon(
                Icons.person_outline,
                size: size * 0.6,
                color: colorScheme.onSecondaryContainer,
              ),
      ),
    );
  }
}
