import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lookstrip/core/theme/app_colors.dart';
import 'package:lookstrip/core/theme/app_shapes.dart';
import 'package:lookstrip/core/providers/auth_provider.dart';
import 'package:lookstrip/features/auth/screens/otp_verify_screen.dart';

class PhoneInputScreen extends ConsumerStatefulWidget {
  const PhoneInputScreen({super.key});

  @override
  ConsumerState<PhoneInputScreen> createState() => _PhoneInputScreenState();
}

class _PhoneInputScreenState extends ConsumerState<PhoneInputScreen> {
  final _phoneController = TextEditingController();
  String _selectedCode = '+91';
  bool _isSending = false;

  // Country code → (flag, name, max digits)
  static const _countries = {
    '+91': ('🇮🇳', 'India', 10),
    '+1': ('🇺🇸', 'USA / Canada', 10),
    '+44': ('🇬🇧', 'United Kingdom', 10),
    '+971': ('🇦🇪', 'UAE', 9),
    '+61': ('🇦🇺', 'Australia', 9),
    '+81': ('🇯🇵', 'Japan', 10),
    '+33': ('🇫🇷', 'France', 9),
    '+49': ('🇩🇪', 'Germany', 11),
    '+86': ('🇨🇳', 'China', 11),
    '+65': ('🇸🇬', 'Singapore', 8),
    '+55': ('🇧🇷', 'Brazil', 11),
    '+7': ('🇷🇺', 'Russia', 10),
    '+82': ('🇰🇷', 'South Korea', 10),
    '+39': ('🇮🇹', 'Italy', 10),
    '+34': ('🇪🇸', 'Spain', 9),
  };

  int get _maxDigits => _countries[_selectedCode]?.$3 ?? 10;
  String get _flag => _countries[_selectedCode]?.$1 ?? '🌍';

  bool get _isPhoneValid {
    final phone = _phoneController.text.trim();
    // Minimum 6 digits, max depends on country
    return phone.length >= 6 && phone.length <= _maxDigits;
  }

  Future<void> _sendOtp() async {
    if (!_isPhoneValid || _isSending) return;

    setState(() => _isSending = true);
    final fullPhone = '$_selectedCode${_phoneController.text.trim()}';
    final success = await ref.read(authProvider.notifier).sendOtp(fullPhone);
    if (!mounted) return;
    setState(() => _isSending = false);

    if (success) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => OtpVerifyScreen(phone: fullPhone)),
      );
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppShapes.screenPadding,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppShapes.space3xl),

                      // ─── Icon ───
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(
                            AppShapes.radiusLg,
                          ),
                        ),
                        child: const Center(
                          child: Text('📱', style: TextStyle(fontSize: 32)),
                        ),
                      ),

                      const SizedBox(height: AppShapes.spaceLg),

                      // ─── Title ───
                      Text(
                        'Enter your\nphone number',
                        style: GoogleFonts.dmSerifDisplay(
                          fontSize: 30,
                          color: AppColors.onSurface,
                          height: 1.2,
                        ),
                      ),

                      const SizedBox(height: AppShapes.spaceSm),

                      Text(
                        'We\'ll send a verification code to confirm',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),

                      const SizedBox(height: AppShapes.spaceXl),

                      // ─── Phone input row ───
                      Row(
                        children: [
                          // Country code dropdown
                          GestureDetector(
                            onTap: () => _showCountryPicker(context),
                            child: Container(
                              height: AppShapes.inputHeight,
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppShapes.spaceMd,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainerHigh,
                                borderRadius: BorderRadius.circular(
                                  AppShapes.radiusMd,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _flag,
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    _selectedCode,
                                    style: Theme.of(context).textTheme.bodyLarge
                                        ?.copyWith(color: AppColors.onSurface),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.arrow_drop_down,
                                    color: AppColors.onSurfaceVariant,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(width: AppShapes.spaceSm),

                          // Phone number field
                          Expanded(
                            child: SizedBox(
                              height: AppShapes.inputHeight,
                              child: TextField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(
                                      color: AppColors.onSurface,
                                      letterSpacing: 1.5,
                                    ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(_maxDigits),
                                ],
                                decoration: InputDecoration(
                                  hintText: '$_maxDigits digits',
                                ),
                                onChanged: (_) => setState(() {}),
                                onSubmitted: (_) => _sendOtp(),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // ─── Digit counter ───
                      Padding(
                        padding: const EdgeInsets.only(top: AppShapes.spaceXs),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            '${_phoneController.text.length} / $_maxDigits',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: _isPhoneValid
                                      ? AppColors.primary
                                      : AppColors.onSurfaceMuted,
                                ),
                          ),
                        ),
                      ),

                      // ─── Error ───
                      if (authState.error != null) ...[
                        const SizedBox(height: AppShapes.spaceSm),
                        Text(
                          authState.error!,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.error),
                        ),
                      ],

                      const SizedBox(height: AppShapes.spaceMd),

                      // ─── Info ───
                      Container(
                        padding: const EdgeInsets.all(AppShapes.spaceMd),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(
                            AppShapes.radiusMd,
                          ),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Text('🔒', style: TextStyle(fontSize: 20)),
                            const SizedBox(width: AppShapes.spaceSm),
                            Expanded(
                              child: Text(
                                'A 6-digit code will be sent via SMS to verify your number',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: AppColors.onSurfaceVariant,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),

                      // ─── Send OTP Button ───
                      SizedBox(
                        width: double.infinity,
                        height: AppShapes.buttonHeight,
                        child: ElevatedButton(
                          onPressed: _isSending || !_isPhoneValid
                              ? null
                              : _sendOtp,
                          child: _isSending
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: AppColors.onPrimary,
                                  ),
                                )
                              : const Text('Send OTP'),
                        ),
                      ),

                      const SizedBox(height: AppShapes.spaceLg),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showCountryPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppShapes.radiusLg),
        ),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(AppShapes.spaceMd),
                child: Text(
                  'Select Country',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              const Divider(height: 1),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: _countries.entries.map((entry) {
                    final code = entry.key;
                    final flag = entry.value.$1;
                    final name = entry.value.$2;
                    final digits = entry.value.$3;
                    final isSelected = _selectedCode == code;

                    return ListTile(
                      leading: Text(flag, style: const TextStyle(fontSize: 24)),
                      title: Text(name),
                      subtitle: Text('$code • $digits digits'),
                      trailing: isSelected
                          ? const Icon(
                              Icons.check_circle,
                              color: AppColors.primary,
                            )
                          : null,
                      onTap: () {
                        setState(() {
                          _selectedCode = code;
                          // Clear phone if it exceeds new max
                          if (_phoneController.text.length > digits) {
                            _phoneController.text = _phoneController.text
                                .substring(0, digits);
                          }
                        });
                        Navigator.pop(ctx);
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
