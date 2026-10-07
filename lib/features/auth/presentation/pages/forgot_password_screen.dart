// lib/features/auth/presentation/pages/forgot_password_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kora/core/common/app_loader.dart';
import 'package:kora/core/theme/app_colors.dart';
import 'package:kora/core/theme/app_text_styles.dart';
import 'package:kora/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:kora/features/auth/presentation/bloc/auth_event.dart';
import 'package:kora/features/auth/presentation/bloc/auth_state.dart';
import 'package:kora/features/auth/presentation/widgets/auth_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState
    extends State<ForgotPasswordScreen> {
  final emailController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthPasswordResetSent) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Password reset email sent'),
            ),
          );

          Navigator.pop(context);
        }

        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
           leading: const BackButton(color: AppColors.primary),
          title:  Text('Kora AI', style: AppTextStyles.headingMedium.copyWith(color: AppColors.primary),),
          actions: [
            IconButton(
              icon: const Icon(Icons.info_outline, size: 20,color: AppColors.textSecondary,),
              onPressed: () {},
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24,vertical: 32),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Icon circle
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child:  Icon(Icons.lock_outline,
                          size: 32, color: AppColors.primary),
                    ).also((w) => Align(alignment: Alignment.center, child: w)),
                    const SizedBox(height: 20),
              
                     Text('Forgot Password?',
                            style: AppTextStyles.headingLarge.copyWith(color: AppColors.primary), textAlign: TextAlign.center),
                        
                    const SizedBox(height: 12),
              
                     Text(
                      'Enter your email address to receive a secure link to reset your password.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.headingSmall.copyWith(color: AppColors.textSecondary)
                    ),
                    const SizedBox(height: 12),
              
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AuthTextField(
                        controller: emailController,
                        label: '',
                        hint: 'hello@kora.ai',
                        suffixIcon: Icons.mail_outline,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      ],
                    ),
                    const SizedBox(height: 28),
              
                     BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        final isLoading =
                            state is AuthLoading;

                        return ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () {
                                  context
                                      .read<AuthBloc>()
                                      .add(
                                        ForgotPasswordRequested(
                                          emailController.text
                                              .trim(),
                                        ),
                                      );
                                },
                          child: isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child:
                                     AppLoader(),
                                )
                              : Text(
                                  'Send Reset Link',
                                  style:
                                      AppTextStyles.button,
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
      ),
    );
  }
}

// tiny helper to center the icon widget inline
extension _WidgetAlso on Widget {
  Widget also(Widget Function(Widget) f) => f(this);
}