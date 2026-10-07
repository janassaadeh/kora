// lib/features/auth/presentation/pages/sign_up_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kora/core/common/app_loader.dart';
import 'package:kora/core/theme/app_colors.dart';
import 'package:kora/core/theme/app_text_styles.dart';
import 'package:kora/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:kora/features/auth/presentation/bloc/auth_event.dart';
import 'package:kora/features/auth/presentation/bloc/auth_state.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/social_auth_row.dart';


class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          Navigator.pop(context); // or go to main screen via AuthGate
        }

        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child:  Scaffold(
        appBar: AppBar(
          leading: const BackButton(color: AppColors.primary),
          title:  Text('Kora AI', style: AppTextStyles.headingMedium.copyWith(color: AppColors.primary),),
          actions: [
            // IconButton(
            //   icon: const Icon(Icons.info_outline, size: 20,color: AppColors.textSecondary,),
            //   onPressed: () {},
            // ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 24),
                    Text('Sign Up',
                        style: AppTextStyles.headingLarge.copyWith(color: AppColors.primary), textAlign: TextAlign.center),
                    const SizedBox(height: 32),
                
                    AuthTextField(
                      controller: nameController,
                      label: 'Full Name',
                      hint: 'Enter your name',
                      suffixIcon: Icons.person_outline,
                    ),
                    const SizedBox(height: 16),
                     AuthTextField(
                      controller: emailController,
                      label: 'Email Address',
                      hint: 'hello@kora.ai',
                      suffixIcon: Icons.mail_outline,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                     AuthTextField(
                      controller: passwordController,
                      label: 'Password',
                      hint: '••••••••',
                      suffixIcon: Icons.lock_outline,
                      obscureText: true,
                    ),
                    const SizedBox(height: 28),
                
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        final isLoading = state is AuthLoading;

                        return ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () {
                                  context.read<AuthBloc>().add(
                                        SignUpRequested(
                                          email: emailController.text.trim(),
                                          password:
                                              passwordController.text.trim(),
                                          displayName:
                                              nameController.text.trim(),  
                                        ),
                                      );
                                },
                          child: isLoading
                              ? const AppLoader()
                              : Text(
                                  'Sign Up',
                                  style: AppTextStyles.button,
                                ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                
                    const SocialAuthRow(),
                    const SizedBox(height: 24),
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