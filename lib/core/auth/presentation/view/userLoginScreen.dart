import 'package:flutter/material.dart';
import 'dart:ui' show ImageFilter; 
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/core/auth/presentation/view/VerifyOtpWidget.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:vedika_healthcare/core/navigation/AppRoutes.dart';
import 'package:vedika_healthcare/core/auth/presentation/viewmodel/AuthViewModel.dart';
import 'package:sms_autofill/sms_autofill.dart';

class UserLoginScreen extends StatefulWidget {
  @override
  _userLoginScreenState createState() => _userLoginScreenState();
}

// Public helper to show login bottom sheet without navigating to a new route
Future<void> showLoginBottomSheet(
  BuildContext context, {
  String? redirectRoute,
  dynamic redirectArgs,
  bool dimBackground = true,
}) async {
  final formKey = GlobalKey<FormState>();
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    useRootNavigator: true,
    barrierColor: Colors.black.withOpacity(0.60),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) {
      return _LoginBottomSheetContent(
        formKey: formKey,
        redirectRoute: redirectRoute,
        redirectArgs: redirectArgs,
        // When shown directly (no intermediate login screen route), do not pop underlying page
        closeLoginRouteAfterSheet: false,
        onDismissByLogin: () {},
      );
    },
  );
}

class _userLoginScreenState extends State<UserLoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _navigatedAfterLogin = false;
  bool _sheetDismissedByLogin = false;

  @override
  void initState() {
    super.initState();
    // Show bottom sheet after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showLoginBottomSheet();
    });
  }

  void _showLoginBottomSheet() {
    final routeArgs = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useRootNavigator: true,
    barrierColor: Colors.black.withOpacity(0.12), // light grey overlay to suggest overlap
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return _LoginBottomSheetContent(
          formKey: _formKey,
          redirectRoute: routeArgs != null ? routeArgs['redirectRoute'] as String? : null,
          redirectArgs: routeArgs != null ? routeArgs['redirectArgs'] : null,
          closeLoginRouteAfterSheet: true, // pop the login route when used via /login
          onDismissByLogin: () {
            _sheetDismissedByLogin = true;
          },
        );
      },
    ).whenComplete(() {
      if (!mounted) return;
      // If user dismissed manually, close the login route; if dismissed by login flow,
      // navigation handler will manage popping and routing.
      if (!_sheetDismissedByLogin) {
        final navigator = Navigator.of(context);
        if (navigator.canPop()) {
          navigator.pop();
        }
      }
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Empty shell; actual UI presented as bottom sheet
      backgroundColor: Colors.transparent,
    );
  }
}

class _LoginBottomSheetContent extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final String? redirectRoute;
  final dynamic redirectArgs;
  final bool closeLoginRouteAfterSheet;
  final VoidCallback onDismissByLogin;

  const _LoginBottomSheetContent({
    required this.formKey,
    required this.onDismissByLogin,
    this.redirectRoute,
    this.redirectArgs,
    this.closeLoginRouteAfterSheet = true,
  });

  @override
  State<_LoginBottomSheetContent> createState() => _LoginBottomSheetContentState();
}

class _LoginBottomSheetContentState extends State<_LoginBottomSheetContent> {
  late final TextEditingController _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;
    return AnimatedPadding(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: viewInsets),
      child: Consumer<AuthViewModel>(
        builder: (context, auth, _) {
          // Handle post-login redirection
          if (auth.isLoggedIn) {
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              if (!mounted) return;
              widget.onDismissByLogin();
              // Capture redirect before closing
              final vm = Provider.of<AuthViewModel>(context, listen: false);
              final routeName = (vm.redirectRoute != null && vm.redirectRoute!.isNotEmpty)
                  ? vm.redirectRoute!
                  : (widget.redirectRoute != null && widget.redirectRoute!.isNotEmpty
                      ? widget.redirectRoute!
                      : AppRoutes.home);
              final args = vm.redirectArguments ?? widget.redirectArgs;
              final rootNav = Navigator.of(context, rootNavigator: true);
              if (rootNav.canPop()) rootNav.pop();
              await Future.delayed(const Duration(milliseconds: 60));
              if (!mounted) return;
              if (widget.closeLoginRouteAfterSheet) {
                final nav = Navigator.of(context);
                if (nav.canPop()) nav.pop();
              }
              await Future.delayed(const Duration(milliseconds: 10));
              // Avoid stacking an extra MainScreen when bottom sheet was launched from Home
              final shouldNavigate = widget.closeLoginRouteAfterSheet || routeName != AppRoutes.home;
              if (shouldNavigate) {
                rootNav.pushNamed(routeName, arguments: args);
              }
            });
          }

          return Material(
            type: MaterialType.transparency,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                IntrinsicHeight(
                  child: Container(
                    constraints: BoxConstraints(
                      maxHeight: size.height * 0.92,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: SafeArea(
                      top: false,
                      child: Form(
                        key: widget.formKey,
                        child: Stack(
                          children: [
                            SingleChildScrollView(
                              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Center(
                                    child: Container(
                                      width: 38,
                                      height: 4,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade300,
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: ColorPalette.primaryColor.withOpacity(0.1),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(6),
                                          child: Image.asset('assets/logo/Logo.png', fit: BoxFit.contain),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        'Vedika.Health',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800,
                                          color: ColorPalette.primaryColor,
                                        ),
                                      ),
                                      const Spacer(),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Sign in to continue",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Consumer<AuthViewModel>(
                                    builder: (context, vm, child) {
                                      return AnimatedSwitcher(
                                        duration: const Duration(milliseconds: 250),
                                        child: !vm.isOtpSent
                                            ? _PhoneStep(
                                                phoneController: _phoneController,
                                                onContinue: () {
                                                  if (widget.formKey.currentState!.validate()) {
                                                    vm.startPhoneAuth(
                                                      "+91${_phoneController.text}",
                                                      route: widget.redirectRoute,
                                                      args: widget.redirectArgs,
                                                    );
                                                  }
                                                },
                                                errorMessage: vm.errorMessage,
                                              )
                                            : _OtpStep(infoMessage: vm.infoMessage),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                            Consumer<AuthViewModel>(
                              builder: (context, vm, _) {
                                if (!vm.isVerifying) return const SizedBox.shrink();
                                return Positioned.fill(
                                  child: Container(
                                    color: Colors.black.withOpacity(0.25),
                                    child: Center(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: BackdropFilter(
                                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(0.9),
                                              borderRadius: BorderRadius.circular(16),
                                              border: Border.all(color: Colors.white.withOpacity(0.6)),
                                            ),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  height: 56,
                                                  width: 56,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: ColorPalette.primaryColor,
                                                  ),
                                                  child: const Padding(
                                                    padding: EdgeInsets.all(12),
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: 3,
                                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 12),
                                                Text(
                                                  "Signing you in...",
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w700,
                                                    color: ColorPalette.primaryColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Floating close button similar to Blood Bank sheets
                Positioned(
                  right: 16,
                  top: -50,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.close, size: 24, color: Colors.black87),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PhoneStep extends StatelessWidget {
  final TextEditingController phoneController;
  final VoidCallback onContinue;
  final String? errorMessage;

  const _PhoneStep({
    required this.phoneController,
    required this.onContinue,
    required this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AuthViewModel>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: Colors.grey.shade50,
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                decoration: BoxDecoration(
                  border: Border(right: BorderSide(color: Colors.grey.shade200)),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(14),
                    bottomLeft: Radius.circular(14),
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      "+91",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: ColorPalette.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(Icons.arrow_drop_down, color: ColorPalette.primaryColor, size: 18),
                  ],
                ),
              ),
              Expanded(
                child: TextFormField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: "Enter Contact number",
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return "Please enter your Contact number";
                    if (value.length != 10) return "Enter a valid 10-digit Contact number";
                    return null;
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: vm.isLoading ? null : onContinue,
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorPalette.primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: vm.isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                  )
                : const Text(
                    "Continue",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ),
        if (errorMessage != null) ...[
          const SizedBox(height: 10),
          Text(errorMessage!, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
        ],
        const SizedBox(height: 8),
        Center(
          child: TextButton(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.vendor),
            child: Text(
              "Login as Vendor",
              style: TextStyle(
                color: ColorPalette.primaryColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _OtpStep extends StatelessWidget {
  final String? infoMessage;
  const _OtpStep({this.infoMessage});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (infoMessage != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.withOpacity(0.25)),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle_outline, color: Colors.green, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    infoMessage!,
                    style: TextStyle(color: Colors.green.shade700, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
        VerifyOtpWidget(),
      ],
    );
  }
}
