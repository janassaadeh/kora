import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kora/core/common/app_loader.dart';
import 'package:kora/core/theme/app_colors.dart';
import 'package:kora/core/theme/app_text_styles.dart';
import 'package:kora/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:kora/features/auth/presentation/bloc/auth_event.dart';
import 'package:kora/features/auth/presentation/bloc/auth_state.dart';
import 'package:kora/features/main_shell/presentation/screens/main_screen.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/social_auth_row.dart';
import 'sign_up_screen.dart';
import 'forgot_password_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return  BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => MainScreen()),
          );
        }

        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title:  Text('Kora AI', style: AppTextStyles.headingMedium.copyWith(color: AppColors.primary),),
          
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24,vertical: 32),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),
                  Text('Sign In',
                      style: AppTextStyles.headingLarge.copyWith(color: AppColors.primary), textAlign: TextAlign.center),
                  const SizedBox(height: 32),
              
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
                  const SizedBox(height: 10),
              
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const ForgotPasswordScreen())),
                      child:  Text(
                        'Forgot Password?',
                        style: AppTextStyles.headingSmall.copyWith(color: AppColors.primary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
              
                   BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        final isLoading = state is AuthLoading;

                        return ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () {
                                  context.read<AuthBloc>().add(
                                        SignInRequested(
                                          email: emailController.text.trim(),
                                          password:
                                              passwordController.text.trim(),
                                        ),
                                      );
                                },
                          child: isLoading
                              ? AppLoader()
                              : Text(
                                  'Sign In',
                                  style: AppTextStyles.button,
                                ),
                        );
                      },
                    ),

                  const SizedBox(height: 24),
              
                  SocialAuthRow(
                    onGoogleTap: () {
                      context.read<AuthBloc>().add(SignInWithGoogleRequested());
                    },
                  ),                  const SizedBox(height: 24),
              
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Don't have an account? ",
                            style: AppTextStyles.headingSmall.copyWith(color: AppColors.textSecondary)),
                      
                      GestureDetector(
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const SignUpScreen())),
                        child:  Text(
                          'Sign Up',
                           style: AppTextStyles.headingSmall.copyWith(color: AppColors.primary),),
                      ),
                    ],
                  ),
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