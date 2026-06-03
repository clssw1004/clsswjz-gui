import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import '../manager/l10n_manager.dart';
import '../providers/user_provider.dart';
import '../theme/theme_radius.dart';
import '../theme/theme_spacing.dart';
import '../utils/toast_util.dart';
import '../widgets/common/common_app_bar.dart';
import '../widgets/common/common_dialog.dart';
import '../widgets/common/common_text_form_field.dart';
import '../widgets/common/user_avatar.dart';

class UserInfoPage extends StatelessWidget {
  const UserInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _UserInfoPageView();
  }
}

class _UserInfoPageView extends StatefulWidget {
  const _UserInfoPageView();

  @override
  State<_UserInfoPageView> createState() => _UserInfoPageViewState();
}

class _UserInfoPageViewState extends State<_UserInfoPageView> {
  final _formKey = GlobalKey<FormState>();
  final List<bool> _sectionVisible = List.filled(4, false);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (int i = 0; i < _sectionVisible.length; i++) {
        Future.delayed(Duration(milliseconds: 80 * i), () {
          if (mounted) setState(() => _sectionVisible[i] = true);
        });
      }
    });
  }

  // ── 头像选择 ──

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
        ToastUtil.showSuccess(
            L10nManager.l10n.modifySuccess(L10nManager.l10n.avatar));
      }
    }
  }

  // ── 修改密码 ──

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
              prefixIcon: Icon(Icons.lock_outline,
                  color: theme.colorScheme.primary),
              obscureText: true,
              validator: (value) {
                if (value?.isEmpty ?? true) return L10nManager.l10n.required;
                return null;
              },
              onSaved: (value) => oldPassword = value ?? '',
            ),
            SizedBox(height: spacing.formItemSpacing),
            CommonTextFormField(
              labelText: L10nManager.l10n.newPassword,
              prefixIcon: Icon(Icons.lock_outline,
                  color: theme.colorScheme.primary),
              obscureText: true,
              validator: (value) {
                if (value?.isEmpty ?? true) return L10nManager.l10n.required;
                if (value!.length < 6) return L10nManager.l10n.passwordTooShort;
                newPassword = value;
                return null;
              },
            ),
            SizedBox(height: spacing.formItemSpacing),
            CommonTextFormField(
              labelText: L10nManager.l10n.confirmPassword,
              prefixIcon: Icon(Icons.lock_outline,
                  color: theme.colorScheme.primary),
              obscureText: true,
              validator: (value) {
                if (value?.isEmpty ?? true) return L10nManager.l10n.required;
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
                  child: Text(
                      MaterialLocalizations.of(context).cancelButtonLabel),
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
            ToastUtil.showSuccess(L10nManager.l10n.passwordChanged);
          } else {
            ToastUtil.showError(
                result.message ?? L10nManager.l10n.modifyFailed(
                    L10nManager.l10n.password, ''));
          }
        }
      } catch (e) {
        if (context.mounted) {
          ToastUtil.showError(L10nManager.l10n.updateFailed);
        }
      }
    }
  }

  // ── 保存 ──

  void _handleSave() {
    _formKey.currentState?.save();
    ToastUtil.showSuccess(L10nManager.l10n.saveSuccess);
  }

  // ── 入场动画包裹 ──

  Widget _buildAnimatedSection(int index, Widget child) {
    return AnimatedOpacity(
      opacity: _sectionVisible[index] ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
      child: child,
    );
  }

  // ── 区块标题 ──

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(height: 1, color: color.withAlpha(20)),
        ),
      ],
    );
  }

  // ── Hero 头像区域 ──

  Widget _buildAvatarSection(
      ThemeData theme, ColorScheme colorScheme, UserProvider provider) {
    final user = provider.user!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          theme.extension<ThemeRadius>()?.radius ?? 12,
        ),
        color: colorScheme.surfaceContainerHighest.withAlpha(30),
      ),
      child: Column(
        children: [
          UserAvatar(
            avatar: user.avatar,
            size: 96,
            onTap: () => _pickImage(context),
          ),
          const SizedBox(height: 16),
          Text(
            user.nickname,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: colorScheme.primary.withAlpha(15),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              user.username,
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── 账户信息区块 ──

  Widget _buildAccountSection(
      ThemeData theme, ColorScheme colorScheme, UserProvider provider) {
    final user = provider.user!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          icon: Icons.assignment_outlined,
          title: L10nManager.l10n.basicInfo,
          color: colorScheme.primary,
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withAlpha(40),
            borderRadius: BorderRadius.circular(
              theme.extension<ThemeRadius>()?.radius ?? 12,
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              CommonTextFormField(
                initialValue: user.username,
                labelText: L10nManager.l10n.username,
                enabled: false,
                prefixIcon: Icon(Icons.person_outline,
                    color: colorScheme.primary),
              ),
              const SizedBox(height: 12),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: CommonTextFormField(
                      initialValue: user.inviteCode,
                      labelText: L10nManager.l10n.inviteCode,
                      enabled: false,
                      prefixIcon: Icon(Icons.qr_code_outlined,
                          color: colorScheme.primary),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.copy_outlined, size: 20),
                          tooltip: L10nManager.l10n.copySuccess,
                          onPressed: () {
                            if (user.inviteCode.isNotEmpty) {
                              Clipboard.setData(
                                  ClipboardData(text: user.inviteCode));
                              ToastUtil.showSuccess(
                                  L10nManager.l10n.copySuccess);
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh_outlined, size: 20),
                          tooltip: L10nManager.l10n.reset,
                          onPressed: () {
                            // TODO: 实现重置邀请码功能
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── 个人信息区块 ──

  Widget _buildPersonalSection(
      ThemeData theme, ColorScheme colorScheme, UserProvider provider) {
    final user = provider.user!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          icon: Icons.person_outline,
          title: L10nManager.l10n.editUserInfo,
          color: colorScheme.primary,
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withAlpha(40),
            borderRadius: BorderRadius.circular(
              theme.extension<ThemeRadius>()?.radius ?? 12,
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              CommonTextFormField(
                initialValue: user.nickname,
                labelText: L10nManager.l10n.nickname,
                prefixIcon: Icon(Icons.account_box_outlined,
                    color: colorScheme.primary),
                onSaved: (value) {
                  if (value?.isNotEmpty ?? false) {
                    provider.updateUserInfo(nickname: value);
                  }
                },
              ),
              const SizedBox(height: 12),
              CommonTextFormField(
                initialValue: user.email,
                labelText: L10nManager.l10n.email,
                prefixIcon:
                    Icon(Icons.email_outlined, color: colorScheme.primary),
                onSaved: (value) {
                  if (value?.isNotEmpty ?? false) {
                    provider.updateUserInfo(email: value);
                  }
                },
              ),
              const SizedBox(height: 12),
              CommonTextFormField(
                initialValue: user.phone,
                labelText: L10nManager.l10n.phone,
                prefixIcon:
                    Icon(Icons.phone_outlined, color: colorScheme.primary),
                onSaved: (value) {
                  if (value?.isNotEmpty ?? false) {
                    provider.updateUserInfo(phone: value);
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── 安全设置区块 ──

  Widget _buildSecuritySection(
      ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          icon: Icons.shield_outlined,
          title: L10nManager.l10n.changePassword,
          color: colorScheme.primary,
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withAlpha(40),
            borderRadius: BorderRadius.circular(
              theme.extension<ThemeRadius>()?.radius ?? 12,
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colorScheme.primary.withAlpha(15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.lock_outline,
                color: colorScheme.primary,
                size: 22,
              ),
            ),
            title: Text(
              L10nManager.l10n.changePassword,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              L10nManager.l10n.optional,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            trailing: Icon(
              Icons.chevron_right_rounded,
              color: colorScheme.onSurfaceVariant,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                theme.extension<ThemeRadius>()?.radius ?? 12,
              ),
            ),
            onTap: () => _showChangePasswordDialog(context),
          ),
        ),
      ],
    );
  }

  // ── 底部保存按钮 ──

  Widget _buildSaveButton(ThemeData theme, ColorScheme colorScheme) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: _handleSave,
        icon: const Icon(Icons.save_outlined),
        label: Text(L10nManager.l10n.save),
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  // ── 页面主体 ──

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UserProvider>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final spacing = theme.spacing;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: CommonAppBar(
          title: Text(L10nManager.l10n.userInfo),
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
                            color: colorScheme.error,
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
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 区块 0: 头像
                              _buildAnimatedSection(
                                0,
                                _buildAvatarSection(
                                    theme, colorScheme, provider),
                              ),

                              SizedBox(height: spacing.formGroupSpacing),

                              // 区块 1: 账户信息
                              _buildAnimatedSection(
                                1,
                                _buildAccountSection(
                                    theme, colorScheme, provider),
                              ),

                              SizedBox(height: spacing.formGroupSpacing),

                              // 区块 2: 个人信息
                              _buildAnimatedSection(
                                2,
                                _buildPersonalSection(
                                    theme, colorScheme, provider),
                              ),

                              SizedBox(height: spacing.formGroupSpacing),

                              // 区块 3: 安全设置
                              _buildAnimatedSection(
                                3,
                                _buildSecuritySection(theme, colorScheme),
                              ),

                              SizedBox(height: spacing.formGroupSpacing),

                              // 保存按钮
                              _buildAnimatedSection(
                                3,
                                _buildSaveButton(theme, colorScheme),
                              ),

                              SizedBox(height: spacing.formGroupSpacing),
                            ],
                          ),
                        ),
                      ),
      ),
    );
  }
}
