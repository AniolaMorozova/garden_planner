import 'package:flutter/material.dart';

import '../../data/models/app_user.dart';
import '../di/app_dependencies.dart';

/// перебудовує частину екрана щоразу, коли змінюються дані користувача
/// (вхід, нове імʼя чи фото), тому імʼя й аватар завжди актуальні
class CurrentUserBuilder extends StatefulWidget {
  const CurrentUserBuilder({super.key, required this.builder});

  final Widget Function(BuildContext context, AppUser user) builder;

  @override
  State<CurrentUserBuilder> createState() => _CurrentUserBuilderState();
}

class _CurrentUserBuilderState extends State<CurrentUserBuilder> {
  // потік створюємо один раз, а не в build, щоб не перепідписуватись
  late final Stream<AppUser?> _userStream;
  AppUser? _initialUser;

  @override
  void initState() {
    super.initState();
    _userStream = context.auth.userChanges();
    _initialUser = context.auth.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AppUser?>(
      stream: _userStream,
      initialData: _initialUser,
      builder: (context, snapshot) {
        final user = snapshot.data;
        // після виходу екран ще мить на екрані — нічого не малюємо
        if (user == null) return const SizedBox.shrink();
        return widget.builder(context, user);
      },
    );
  }
}
