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

  Future<void> _logout() async {
    await _sessionStorage.clear();
    _refreshAuthorization();
  }

  void _openOtherScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const OtherScreen()),
    );
  }

  void _openSavedCompanies() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SavedCompaniesScreen()),
    );
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
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
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
                      Text(
                        _displayName(profileSnapshot.data),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              color: Colors.black,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
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
                      const SizedBox(height: 18),
                      _ProfileActionTile(
                        title: 'Удалить аккаунт',
                        icon: Icons.delete_outline_rounded,
                        iconColor: const Color(0xFFFF1717),
                        textColor: const Color(0xFFFF1717),
                        backgroundColor: const Color(0xFFFFEAED),
                        onTap: () {},
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
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Ink(
          height: 68,
          padding: const EdgeInsets.symmetric(horizontal: 22),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: 26),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: iconColor,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
