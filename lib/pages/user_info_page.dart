import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';

import '../manager/l10n_manager.dart';
import '../providers/user_provider.dart';
import '../widgets/common/common_app_bar.dart';
import '../widgets/common/common_dialog.dart';
import '../widgets/common/common_text_form_field.dart';
import '../widgets/common/user_avatar.dart';
import '../theme/theme_spacing.dart';
import '../utils/toast_util.dart';

class UserInfoPage extends StatelessWidget {
  const UserInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _UserInfoPageView();
  }
}

class _UserInfoPageView extends StatelessWidget {
  const _UserInfoPageView();

  Future<void> _pickImage(BuildContext context) async {
    final provider = context.read<UserProvider>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final result = await CommonDialog.show<ImageSource>(
      context: context,
      title: L10nManager.l10n.selectIcon,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Icons.photo_camera, color: colorScheme.primary),
            title: Text(L10nManager.l10n.takePhoto),
            onTap: () => Navigator.pop(context, ImageSource.camera),
          ),
          ListTile(
            leading: Icon(Icons.photo_library, color: colorScheme.primary),
            title: Text(L10nManager.l10n.chooseFromGallery),
            onTap: () => Navigator.pop(context, ImageSource.gallery),
          ),
        ],
      ),
    );
    if (result == null) return;
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: result,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );

    if (pickedFile == null) return;
    if (context.mounted) {
      final file = File(pickedFile.path);
      await provider.updateAvatar(file);
      if (context.mounted) {
        ToastUtil.showSuccess(L10nManager.l10n.modifySuccess(L10nManager.l10n.avatar));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UserProvider>();
    final theme = Theme.of(context);
    final spacing = theme.spacing;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: CommonAppBar(
          title: Text(L10nManager.l10n.userInfo),
          actions: [
            if (provider.user != null && !provider.loading)
              IconButton(
                onPressed: () => _showChangePasswordDialog(context),
                icon: const Icon(Icons.lock_outline),
                tooltip: L10nManager.l10n.changePassword,
              ),
          ],
        ),
        body: provider.loading
            ? const Center(child: CircularProgressIndicator())
            : provider.error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          provider.error!,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.error,
                          ),
                        ),
                        SizedBox(height: spacing.formItemSpacing),
                        FilledButton(
                          onPressed: provider.refreshUserInfo,
                          child: Text(L10nManager.l10n.retry),
                        ),
                      ],
                    ),
                  )
                : provider.user == null
                    ? Center(
                        child: Text(L10nManager.l10n.noData),
                      )
                    : SingleChildScrollView(
                        padding: spacing.formPadding,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: UserAvatar(
                                avatar: provider.user?.avatar,
                                size: 80,
                                onTap: () => _pickImage(context),
                              ),
                            ),
                            SizedBox(height: spacing.formGroupSpacing),
                            CommonTextFormField(
                              initialValue: provider.user?.username,
                              labelText: L10nManager.l10n.username,
                              enabled: false,
                              prefixIcon: Icon(
                                Icons.person_outline,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            SizedBox(height: spacing.formItemSpacing),
                            // 昵称
                            CommonTextFormField(
                              initialValue: provider.user?.nickname,
                              labelText: L10nManager.l10n.nickname,
                              prefixIcon: Icon(
                                Icons.account_box_outlined,
                                color: theme.colorScheme.primary,
                              ),
                              onSaved: (value) {
                                if (value?.isNotEmpty ?? false) {
                                  provider.updateUserInfo(nickname: value);
                                }
                              },
                            ),
                            SizedBox(height: spacing.formItemSpacing),
                            // 邮箱
                            CommonTextFormField(
                              initialValue: provider.user?.email,
                              labelText: L10nManager.l10n.email,
                              prefixIcon: Icon(
                                Icons.email_outlined,
                                color: theme.colorScheme.primary,
                              ),
                              onSaved: (value) {
                                if (value?.isNotEmpty ?? false) {
                                  provider.updateUserInfo(email: value);
                                }
                              },
                            ),
                            SizedBox(height: spacing.formItemSpacing),
                            // 手机号
                            CommonTextFormField(
                              initialValue: provider.user?.phone,
                              labelText: L10nManager.l10n.phone,
                              prefixIcon: Icon(
                                Icons.phone_outlined,
                                color: theme.colorScheme.primary,
                              ),
                              onSaved: (value) {
                                if (value?.isNotEmpty ?? false) {
                                  provider.updateUserInfo(phone: value);
                                }
                              },
                            ),
                            SizedBox(height: spacing.formItemSpacing),
                            // 邀请码
                            CommonTextFormField(
                              initialValue: provider.user?.inviteCode,
                              labelText: L10nManager.l10n.inviteCode,
                              enabled: false,
                              prefixIcon: Icon(
                                Icons.qr_code_outlined,
                                color: theme.colorScheme.primary,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  Icons.refresh_outlined,
                                  color: theme.colorScheme.primary,
                                ),
                                tooltip: L10nManager.l10n.reset,
                                onPressed: () {
                                  // TODO: 实现重置邀请码功能
                                },
                              ),
                              onTap: () {
                                if (provider.user?.inviteCode.isNotEmpty ?? false) {
                                  Clipboard.setData(ClipboardData(text: provider.user!.inviteCode));
                                  ToastUtil.showSuccess(L10nManager.l10n.copySuccess);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
      ),
    );
  }

  Future<void> _showChangePasswordDialog(BuildContext context) async {
    final theme = Theme.of(context);
    final spacing = theme.spacing;
    final formKey = GlobalKey<FormState>();
    String oldPassword = '';
    String newPassword = '';

    final result = await CommonDialog.show(
      context: context,
      title: L10nManager.l10n.changePassword,
      showCloseButton: false,
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CommonTextFormField(
              labelText: L10nManager.l10n.oldPassword,
              prefixIcon: Icon(
                Icons.lock_outline,
                color: theme.colorScheme.primary,
              ),
              obscureText: true,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return L10nManager.l10n.required;
                }
                return null;
              },
              onSaved: (value) => oldPassword = value ?? '',
            ),
            SizedBox(height: spacing.formItemSpacing),
            CommonTextFormField(
              labelText: L10nManager.l10n.newPassword,
              prefixIcon: Icon(
                Icons.lock_outline,
                color: theme.colorScheme.primary,
              ),
              obscureText: true,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return L10nManager.l10n.required;
                }
                if (value!.length < 6) {
                  return L10nManager.l10n.passwordTooShort;
                }
                newPassword = value;
                return null;
              },
            ),
            SizedBox(height: spacing.formItemSpacing),
            CommonTextFormField(
              labelText: L10nManager.l10n.confirmPassword,
              prefixIcon: Icon(
                Icons.lock_outline,
                color: theme.colorScheme.primary,
              ),
              obscureText: true,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return L10nManager.l10n.required;
                }
                if (value != newPassword) {
                  return L10nManager.l10n.passwordNotMatch;
                }
                return null;
              },
            ),
            SizedBox(height: spacing.formGroupSpacing),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () {
                    if (formKey.currentState?.validate() ?? false) {
                      formKey.currentState?.save();
                      Navigator.pop(context, true);
                    }
                  },
                  child: Text(L10nManager.l10n.save),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    if (result ?? false) {
      final provider = context.read<UserProvider>();
      try {
        final result = await provider.changePassword(
          oldPassword: oldPassword,
          newPassword: newPassword,
        );
        if (context.mounted) {
          if (result.ok) {
            ToastUtil.showSuccess(L10nManager.l10n.modifySuccess(L10nManager.l10n.password));
          } else {
            ToastUtil.showError(result.message ?? L10nManager.l10n.modifyFailed(L10nManager.l10n.password, ''));
          }
        }
      } catch (e) {
        if (context.mounted) {
          ToastUtil.showError(L10nManager.l10n.updateFailed);
        }
      }
    }
  }
}
