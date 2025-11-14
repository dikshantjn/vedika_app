import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/core/auth/presentation/viewmodel/AuthViewModel.dart';
import 'package:vedika_healthcare/core/navigation/AppRoutes.dart';
import 'package:vedika_healthcare/core/auth/presentation/view/userLoginScreen.dart';
import 'package:vedika_healthcare/shared/services/GlobalKeys.dart';

/// A simple guard that ensures the user is authenticated before showing [child].
/// If not authenticated, it navigates to the login screen and passes the intended
/// route and its arguments for post-login redirection.
class AuthGuard extends StatefulWidget {
  final Widget child;
  final String intendedRoute;
  final dynamic intendedArguments;

  const AuthGuard({
    super.key,
    required this.child,
    required this.intendedRoute,
    this.intendedArguments,
  });

  @override
  State<AuthGuard> createState() => _AuthGuardState();
}

class _AuthGuardState extends State<AuthGuard> {
  bool _requested = false;

  Future<void> _ensureAuth() async {
    if (!mounted) return;
    final auth = context.read<AuthViewModel>();
    if (auth.isLoggedIn || _requested) return;
    _requested = true;
    // Pop this protected route first so the previous screen stays visible behind the sheet
    final nav = Navigator.of(context);
    if (nav.canPop()) {
      nav.pop();
    }
    // Present the sheet using the root navigator context to avoid black background
    final rootCtx = navigatorKey.currentContext ?? context;
    await showLoginBottomSheet(
      rootCtx,
      redirectRoute: widget.intendedRoute,
      redirectArgs: widget.intendedArguments,
      dimBackground: true, // sheet uses a light grey overlay (not full black)
    );
    if (!mounted) return;
    // If still not logged in after sheet closes, pop back to previous screen
    if (!auth.isLoggedIn) {
      // no-op; user remains on previous screen
    } else {
      // Logged in: allow build to show the child
      setState(() {});
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final auth = context.watch<AuthViewModel>();
    if (!auth.isLoggedIn) {
      // Defer sheet presentation to next frame
      WidgetsBinding.instance.addPostFrameCallback((_) => _ensureAuth());
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    if (!auth.isLoggedIn) {
      // Render nothing while waiting
      return const SizedBox.shrink();
    }
    return widget.child;
  }
}


