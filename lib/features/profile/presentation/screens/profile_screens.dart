import 'package:flutter/material.dart';
import 'package:VayToday/core/theme/app_colors.dart';
import 'package:VayToday/features/auth/data/auth_session_storage.dart';
import 'package:VayToday/features/auth/domain/models/auth_user_model.dart';
import 'package:VayToday/features/auth/presentation/screens/login_screen.dart';
import 'package:VayToday/features/other/presentation/screens/other_screen.dart';
import 'package:VayToday/features/profile/data/profile_repository.dart';
import 'package:VayToday/features/profile/presentation/screens/saved_companies_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthSessionStorage _sessionStorage = AuthSessionStorage();
  final ProfileRepository _profileRepository = ProfileRepository();

  late Future<bool> _isAuthorizedFuture;
  Future<AuthUserModel?>? _profileFuture;

  @override
  void initState() {
    super.initState();
    _isAuthorizedFuture = _sessionStorage.isAuthorized();
  }

  void _refreshAuthorization() {
    setState(() {
      _isAuthorizedFuture = _sessionStorage.isAuthorized();
      _profileFuture = null;
    });
  }

  void _retryProfile() {
    setState(() {
      _profileFuture = _profileRepository.getUserProfile();
    });
  }

  Future<void> _logout() async {
    await _sessionStorage.clear();
    _refreshAuthorization();
  }

  Future<void> _openOtherScreen() async {
    final accountDeleted = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => const OtherScreen()));

    if (!mounted || accountDeleted != true) return;
    _refreshAuthorization();
  }

  void _openSavedCompanies() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const SavedCompaniesScreen()));
  }

  Future<void> _openEditUsernameDialog(AuthUserModel? user) async {
    final updatedUser = await showDialog<AuthUserModel?>(
      context: context,
      builder: (_) => _EditUsernameDialog(
        initialUsername: _editableUsername(user),
        profileRepository: _profileRepository,
      ),
    );

    if (!mounted || updatedUser == null) return;

    setState(() {
      _profileFuture = Future.value(updatedUser);
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Имя обновлено')));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isAuthorizedFuture,
      builder: (context, snapshot) {
        final isAuthorized = snapshot.data ?? false;

        if (!isAuthorized) {
          return LoginScreen(onAuthorized: _refreshAuthorization);
        }

        return Scaffold(
          backgroundColor: AppColors.white,
          body: SafeArea(
            child: FutureBuilder<AuthUserModel?>(
              future: _profileFuture ??= _profileRepository.getUserProfile(),
              builder: (context, profileSnapshot) {
                if (profileSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (profileSnapshot.hasError || profileSnapshot.data == null) {
                  return _ProfileLoadError(
                    message: profileSnapshot.error is ProfileApiException
                        ? (profileSnapshot.error! as ProfileApiException)
                              .message
                        : 'Не удалось загрузить профиль',
                    onRetry: _retryProfile,
                  );
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const SizedBox(width: 42),
                          Expanded(
                            child: Text(
                              'Профиль',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(
                                    color: Colors.black,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                          ),
                          IconButton(
                            onPressed: _openOtherScreen,
                            icon: const Icon(
                              Icons.menu_rounded,
                              size: 34,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 36),
                      const _ProfileAvatar(),
                      const SizedBox(height: 22),
                      GestureDetector(
                        onTap: () =>
                            _openEditUsernameDialog(profileSnapshot.data),
                        child: Text(
                          _displayName(profileSnapshot.data),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                color: Colors.black,
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Нажмите, чтобы изменить профиль',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey.shade500,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 46),
                      _ProfileActionTile(
                        title: 'Сохраненные компании',
                        icon: Icons.bookmark_border_rounded,
                        iconColor: Colors.grey.shade600,
                        textColor: Colors.black,
                        backgroundColor: const Color(0xFFF7F7F9),
                        onTap: _openSavedCompanies,
                      ),
                      const SizedBox(height: 18),
                      _ProfileActionTile(
                        title: 'Выйти из аккаунта',
                        icon: Icons.logout_rounded,
                        iconColor: const Color(0xFFFF6B00),
                        textColor: const Color(0xFFFF6B00),
                        backgroundColor: const Color(0xFFFFEFE5),
                        onTap: _logout,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  String _displayName(AuthUserModel? user) {
    final username = user?.username.trim() ?? '';

    if (username.isEmpty || username.contains('@')) {
      return 'Пользователь';
    }

    return username;
  }

  String _editableUsername(AuthUserModel? user) {
    final username = user?.username.trim() ?? '';

    if (username.isEmpty || username.contains('@')) {
      return '';
    }

    return username;
  }
}

class _ProfileLoadError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ProfileLoadError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              color: AppColors.textSecondary,
              size: 42,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 180,
              child: ElevatedButton(
                onPressed: onRetry,
                child: const Text('Повторить'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EditUsernameDialog extends StatefulWidget {
  final String initialUsername;
  final ProfileRepository profileRepository;

  const _EditUsernameDialog({
    required this.initialUsername,
    required this.profileRepository,
  });

  @override
  State<_EditUsernameDialog> createState() => _EditUsernameDialogState();
}

class _EditUsernameDialogState extends State<_EditUsernameDialog> {
  late final TextEditingController _usernameController;
  bool _isSaving = false;

  bool get _canSave {
    return _usernameController.text.trim().isNotEmpty && !_isSaving;
  }

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.initialUsername);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _saveUsername() async {
    if (!_canSave) return;

    setState(() => _isSaving = true);

    try {
      final updatedUser = await widget.profileRepository.updateUsername(
        _usernameController.text.trim(),
      );

      if (!mounted) return;

      Navigator.of(context).pop(updatedUser);
    } on ProfileApiException catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
      setState(() => _isSaving = false);
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Не удалось обновить имя')));
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: const Text(
        'Изменить имя',
        style: TextStyle(
          color: AppColors.authText,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
      ),
      content: TextField(
        controller: _usernameController,
        autofocus: true,
        textInputAction: TextInputAction.done,
        maxLength: 32,
        decoration: const InputDecoration(
          hintText: 'Ваше имя',
          counterText: '',
        ),
        onChanged: (_) => setState(() {}),
        onSubmitted: (_) => _saveUsername(),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          child: const Text('Отмена'),
        ),
        ElevatedButton(
          onPressed: _canSave ? _saveUsername : null,
          child: _isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Сохранить'),
        ),
      ],
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 146,
      height: 146,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 146,
            height: 146,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFF0F0F4),
            ),
            child: const Icon(
              Icons.person_rounded,
              size: 112,
              color: Color(0xFFC8CAD2),
            ),
          ),
          Positioned(
            right: 6,
            bottom: 12,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.14),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Icon(
                Icons.add_rounded,
                color: Color(0xFF686868),
                size: 28,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileActionTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Color textColor;
  final Color backgroundColor;
  final VoidCallback onTap;

  const _ProfileActionTile({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.textColor,
    required this.backgroundColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Ink(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: 22),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, color: iconColor, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
