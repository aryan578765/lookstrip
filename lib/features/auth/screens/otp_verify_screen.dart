import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lookstrip/core/theme/app_colors.dart';
import 'package:lookstrip/core/theme/app_shapes.dart';
import 'package:lookstrip/core/providers/auth_provider.dart';
import 'package:lookstrip/features/auth/screens/profile_setup_screen.dart';
import 'package:lookstrip/features/shell/main_shell.dart';

class OtpVerifyScreen extends ConsumerStatefulWidget {
  final String phone;

  const OtpVerifyScreen({super.key, required this.phone});

  @override
  ConsumerState<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends ConsumerState<OtpVerifyScreen> {
  final _controllers = List.generate(6, (_) => TextEditingController());
  final _focusNodes = List.generate(6, (_) => FocusNode());
  bool _isVerifying = false;
  int _resendTimer = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
    // Auto-focus first field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _focusNodes[0].requestFocus();
    });
  }

  void _startResendTimer() {
    _resendTimer = 30;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (_resendTimer > 0) {
        setState(() => _resendTimer--);
      } else {
        t.cancel();
      }
    });
  }

  void _onOtpChanged(int index, String value) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    // Auto-submit on last digit
    final otp = _controllers.map((c) => c.text).join();
    if (otp.length == 6) {
      _verifyOtp(otp);
    }
  }

  Future<void> _verifyOtp(String otp) async {
    if (_isVerifying) return;
    setState(() => _isVerifying = true);
    final success = await ref
        .read(authProvider.notifier)
        .verifyOtp(widget.phone, otp);
    if (!mounted) return;
    setState(() => _isVerifying = false);

    if (success) {
      final user = ref.read(currentUserProvider);
      final isComplete = user?.isProfileComplete ?? false;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => isComplete
              ? MainShell(key: mainShellKey)
              : const ProfileSetupScreen(),
        ),
        (_) => false,
      );
    } else {
      // Clear fields on error
      for (var c in _controllers) {
        c.clear();
      }
      _focusNodes[0].requestFocus();
    }
  }

  Future<void> _resendOtp() async {
    await ref.read(authProvider.notifier).sendOtp(widget.phone);
    if (!mounted) return;
    _startResendTimer();
  }

  String get _maskedPhone {
    if (widget.phone.length > 4) {
      return '${widget.phone.substring(0, widget.phone.length - 4).replaceAll(RegExp(r'\d'), 'X')}${widget.phone.substring(widget.phone.length - 4)}';
    }
    return widget.phone;
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppShapes.screenPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppShapes.spaceMd),

              // ─── Back button ───
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(AppShapes.radiusMd),
                  ),
                  child: const Icon(
                    Icons.arrow_back_rounded,
                    color: AppColors.onSurface,
                    size: 20,
                  ),
                ),
              ),

              const SizedBox(height: AppShapes.spaceLg),

              // ─── Title ───
              Text(
                'Verify OTP',
                style: GoogleFonts.dmSerifDisplay(
                  fontSize: 30,
                  color: AppColors.onSurface,
                ),
              ),

              const SizedBox(height: AppShapes.spaceSm),

              Text(
                'Code sent to $_maskedPhone',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: AppShapes.spaceXl),

              // ─── OTP Input Fields ───
              Row(
                children: List.generate(6, (i) {
                  return Expanded(
                    child: Container(
                      height: 56,
                      margin: EdgeInsets.only(right: i < 5 ? 6 : 0),
                      child: TextField(
                        controller: _controllers[i],
                        focusNode: _focusNodes[i],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        style: GoogleFonts.dmSans(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          counterText: '',
                          filled: true,
                          fillColor: _focusNodes[i].hasFocus
                              ? AppColors.surfaceContainer
                              : AppColors.surfaceContainerHigh,
                          contentPadding: EdgeInsets.zero,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppShapes.radiusMd,
                            ),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppShapes.radiusMd,
                            ),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                              width: 2,
                            ),
                          ),
                        ),
                        onChanged: (v) => _onOtpChanged(i, v),
                      ),
                    ),
                  );
                }),
              ),

              // ─── Error ───
              if (authState.error != null) ...[
                const SizedBox(height: AppShapes.spaceMd),
                Center(
                  child: Text(
                    authState.error!,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppColors.error),
                  ),
                ),
              ],

              const SizedBox(height: AppShapes.spaceLg),

              // ─── Verifying indicator ───
              if (_isVerifying)
                const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.primary,
                    ),
                  ),
                ),

              const SizedBox(height: AppShapes.spaceLg),

              // ─── Resend ───
              Center(
                child: _resendTimer > 0
                    ? Text(
                        'Resend code in ${_resendTimer}s',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.onSurfaceMuted,
                        ),
                      )
                    : TextButton(
                        onPressed: _resendOtp,
                        child: const Text('Resend code'),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
