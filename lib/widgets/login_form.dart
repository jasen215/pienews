import 'package:flutter/cupertino.dart';
import 'package:pienews/generated/l10n.dart';
import 'package:pienews/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _usernameError;
  String? _passwordError;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _validateEmail(String value) {
    if (value.isEmpty) {
      setState(() => _usernameError = S.of(context).pleaseEnterYourEmail);
      return false;
    }
    if (!value.contains('@')) {
      setState(
          () => _usernameError = S.of(context).pleaseEnterAValidEmailAddress);
      return false;
    }
    setState(() => _usernameError = null);
    return true;
  }

  bool _validatePassword(String value) {
    if (value.isEmpty) {
      setState(() => _passwordError = S.of(context).pleaseEnterYourPassword);
      return false;
    }
    if (value.length < 6) {
      setState(() =>
          _passwordError = S.of(context).passwordMustBeAtLeast6Characters);
      return false;
    }
    setState(() => _passwordError = null);
    return true;
  }

  Future<void> _login() async {
    final isEmailValid = _validateEmail(_usernameController.text);
    final isPasswordValid = _validatePassword(_passwordController.text);

    if (!isEmailValid || !isPasswordValid) return;

    setState(() => _isLoading = true);

    try {
      await context.read<AuthProvider>().login(
            _usernameController.text,
            _passwordController.text,
          );
    } catch (e) {
      if (!mounted) return;

      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text(S.of(context).error),
          content: Text(e.toString()),
          actions: [
            CupertinoDialogAction(
              child: Text(S.of(context).ok),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          S.of(context).welcomeBack,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        CupertinoTextField(
          controller: _usernameController,
          placeholder: S.of(context).email,
          prefix: const Padding(
            padding: EdgeInsets.only(left: 8),
            child: Icon(
              CupertinoIcons.mail,
              color: CupertinoColors.systemGrey,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(
              color: _usernameError != null
                  ? CupertinoColors.systemRed
                  : CupertinoColors.systemGrey4,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          enabled: !_isLoading,
          onChanged: (value) => _validateEmail(value),
        ),
        if (_usernameError != null)
          Padding(
            padding: const EdgeInsets.only(left: 8, top: 4),
            child: Text(
              _usernameError!,
              style: const TextStyle(
                color: CupertinoColors.systemRed,
                fontSize: 12,
              ),
            ),
          ),
        const SizedBox(height: 16),
        CupertinoTextField(
          controller: _passwordController,
          placeholder: S.of(context).password,
          prefix: const Padding(
            padding: EdgeInsets.only(left: 8),
            child: Icon(
              CupertinoIcons.lock,
              color: CupertinoColors.systemGrey,
            ),
          ),
          suffix: CupertinoButton(
            padding: EdgeInsets.zero,
            child: Icon(
              _obscurePassword ? CupertinoIcons.eye : CupertinoIcons.eye_slash,
              color: CupertinoColors.systemGrey,
            ),
            onPressed: () {
              setState(() => _obscurePassword = !_obscurePassword);
            },
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(
              color: _passwordError != null
                  ? CupertinoColors.systemRed
                  : CupertinoColors.systemGrey4,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          obscureText: _obscurePassword,
          textInputAction: TextInputAction.done,
          enabled: !_isLoading,
          onChanged: (value) => _validatePassword(value),
          onSubmitted: (_) => _login(),
        ),
        if (_passwordError != null)
          Padding(
            padding: const EdgeInsets.only(left: 8, top: 4),
            child: Text(
              _passwordError!,
              style: const TextStyle(
                color: CupertinoColors.systemRed,
                fontSize: 12,
              ),
            ),
          ),
        const SizedBox(height: 24),
        CupertinoButton.filled(
          onPressed: _isLoading ? null : _login,
          child: _isLoading
              ? const CupertinoActivityIndicator(color: CupertinoColors.white)
              : Text(S.of(context).login),
        ),
      ],
    );
  }
}
