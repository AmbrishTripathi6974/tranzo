import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';

import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/auth/auth_state.dart';

class AuthGatePage extends StatefulWidget {
  const AuthGatePage({super.key});

  @override
  State<AuthGatePage> createState() => _AuthGatePageState();
}

class _AuthGatePageState extends State<AuthGatePage> {
  late final TextEditingController _emailController;
  late final TextEditingController _otpController;
  late final FocusNode _otpFocusNode;
  Timer? _resendTimer;
  int _resendSecondsRemaining = 0;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _otpController = TextEditingController();
    _otpFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _emailController.dispose();
    _otpController.dispose();
    _otpFocusNode.dispose();
    super.dispose();
  }

  void _startResendCooldown() {
    _resendTimer?.cancel();
    setState(() {
      _resendSecondsRemaining = 30;
    });
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_resendSecondsRemaining <= 1) {
        timer.cancel();
        setState(() {
          _resendSecondsRemaining = 0;
        });
        return;
      }
      setState(() {
        _resendSecondsRemaining -= 1;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: BlocConsumer<AuthBloc, AuthState>(
                listenWhen: (AuthState previous, AuthState current) =>
                    (previous.errorMessage != current.errorMessage &&
                        current.errorMessage != null) ||
                    (previous.status != current.status &&
                        current.status == AuthStatus.otpSent),
                listener: (BuildContext context, AuthState state) {
                  if (state.status == AuthStatus.otpSent) {
                    _startResendCooldown();
                    _otpController.clear();
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (!mounted) {
                        return;
                      }
                      _otpFocusNode.requestFocus();
                    });
                  }
                  final String? error = state.errorMessage;
                  if (error == null) {
                    return;
                  }
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(SnackBar(content: Text(error)));
                },
                builder: (BuildContext context, AuthState state) {
                  final bool sendingOtp =
                      state.activeAction == AuthAction.sendOtp;
                  final bool verifyingOtp =
                      state.activeAction == AuthAction.verifyOtp;
                  final bool otpStep = state.flowStep == AuthFlowStep.otpEntry;
                  final bool resendCoolingDown = _resendSecondsRemaining > 0;
                  final bool emailFieldEnabled = !sendingOtp && !verifyingOtp;
                  final bool otpFieldEnabled = !verifyingOtp;
                  final String pendingEmail =
                      state.pendingEmail ?? _emailController.text.trim();
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text(
                        'Sign in to Tranzo',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Use email OTP to enable secure transfer sessions.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 18),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const <String>[AutofillHints.email],
                        enabled: emailFieldEnabled,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          hintText: 'you@example.com',
                        ),
                      ),
                      const SizedBox(height: 10),
                      FilledButton(
                        onPressed:
                            sendingOtp ||
                                verifyingOtp ||
                                (otpStep && resendCoolingDown)
                            ? null
                            : () {
                                context.read<AuthBloc>().add(
                                  AuthEmailOtpRequested(
                                    email: _emailController.text,
                                  ),
                                );
                              },
                        child: sendingOtp
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                otpStep && resendCoolingDown
                                    ? 'Resend in ${_resendSecondsRemaining}s'
                                    : (otpStep ? 'Resend code' : 'Send code'),
                              ),
                      ),
                      if (otpStep) ...<Widget>[
                        const SizedBox(height: 16),
                        TextField(
                          controller: _otpController,
                          focusNode: _otpFocusNode,
                          keyboardType: TextInputType.number,
                          enabled: otpFieldEnabled,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(6),
                          ],
                          decoration: InputDecoration(
                            labelText: 'Verification code',
                            hintText: '6-digit code sent to $pendingEmail',
                          ),
                        ),
                        const SizedBox(height: 10),
                        FilledButton.tonal(
                          onPressed: verifyingOtp
                              ? null
                              : () {
                                  context.read<AuthBloc>().add(
                                    AuthEmailOtpVerified(
                                      email: pendingEmail,
                                      otpCode: _otpController.text,
                                    ),
                                  );
                                },
                          child: verifyingOtp
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Verify and continue'),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
