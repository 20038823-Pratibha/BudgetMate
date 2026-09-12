import 'package:flutter/material.dart';

// Transactions added during the current app session.
// Kept in memory only so no database or extra package is required.
final List<Map<String, dynamic>> budgetMateSessionTransactions = [];

void main() {
  runApp(const BudgetMateApp());
}

// ===== DESIGN SYSTEM: COLORS =====
// Deliberate choice, not Figma defaults:
// Purple = trust + calm (primary actions), Amber = energy + attention
// (warnings, secondary CTAs), semantic greens/reds for money going
// right or wrong.
class AppColors {
  static const primary = Color(0xFF6B5B95);
  static const primaryDark = Color(0xFF564A7A);
  static const secondary = Color(0xFFF4A261);
  static const success = Color(0xFF2E9E5B);
  static const warning = Color(0xFFE76F51);
  static const textDark = Color(0xFF1A1A1A);
  static const textGrey = Color(0xFF6B7280);
  static const bgLight = Color(0xFFF5F5F7);
}

class BudgetMateApp extends StatelessWidget {
  const BudgetMateApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BudgetMate',
      theme: ThemeData(
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
      ),
      home: const LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// ===== SHARED DESIGN-SYSTEM WIDGETS =====
// Used across every page so buttons/icons/badges look consistent.

Widget buildInitialsAvatar(String initials, Color color, {double radius = 22}) {
  return CircleAvatar(
    radius: radius,
    backgroundColor: color.withOpacity(0.15),
    child: Text(
      initials,
      style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: radius * 0.7),
    ),
  );
}

// Glossy raised button - gradient + shadow, used for every primary
// action (Log in, Create account, Save Expense, etc).
Widget buildPrimaryButton({
  required String label,
  required VoidCallback? onPressed,
  bool loading = false,
  Color? color,
}) {
  final base = color ?? AppColors.primary;
  final disabled = onPressed == null;
  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(14),
      gradient: LinearGradient(
        colors: disabled
            ? [Colors.grey[300]!, Colors.grey[350]!]
            : [base.withOpacity(0.88), base],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      boxShadow: disabled
          ? []
          : [BoxShadow(color: base.withOpacity(0.35), blurRadius: 16, offset: const Offset(0, 8))],
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Center(
            child: loading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                  )
                : Text(
                    label,
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.2),
                  ),
          ),
        ),
      ),
    ),
  );
}

// Rounded icon badge with soft shadow - the wallet/person icon at the
// top of Login/Sign Up.
Widget buildIconBadge(IconData icon, {double size = 72, Color? iconColor}) {
  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(size * 0.28),
      boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 20, offset: const Offset(0, 10)),
      ],
    ),
    child: Icon(icon, size: size * 0.5, color: iconColor ?? AppColors.primary),
  );
}

// Rounded pill badge - used for the "256-bit encrypted" trust message.
Widget buildInfoPill(String text) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: AppColors.primary.withOpacity(0.08),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.lock_outline, size: 14, color: AppColors.primary),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: AppColors.primary.withOpacity(0.85), fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );
}

// Tappable image-placeholder box - used anywhere a real photo would go
// (receipts, house photo). Honest about what works where.
Widget buildImagePlaceholder({required String label, required IconData icon, double height = 90}) {
  return Builder(
    builder: (context) => GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$label - camera/gallery works on Android/iOS devices')),
        );
      },
      child: DottedBox(
        height: height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.grey[400], size: 26),
            const SizedBox(height: 6),
            Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    ),
  );
}

// A simple dashed-look box (approximated with a solid light border,
// since true dashed borders need a CustomPainter - kept simple and
// safe rather than risking a fragile custom painter).
class DottedBox extends StatelessWidget {
  final double height;
  final Widget child;
  const DottedBox({Key? key, required this.height, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!, width: 1.4),
      ),
      child: child,
    );
  }
}

Widget buildSectionLabel(String text) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8, left: 2),
    child: Text(
      text,
      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textGrey, letterSpacing: 0.6),
    ),
  );
}

// Soft translucent circle bleeding off a card's corner - a detail
// from the original Figma gradient cards that hadn't been built yet.
// Purely decorative, so it never intercepts taps underneath it.
Widget buildDecorativeCircle({double size = 120, double opacity = 0.08}) {
  return Positioned(
    right: -size * 0.25,
    top: -size * 0.25,
    child: IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: Colors.white.withOpacity(opacity), shape: BoxShape.circle),
      ),
    ),
  );
}

// Circular avatar showing a real bundled photo asset, with a safe
// fallback to initials if the asset isn't found yet (e.g. before
// pubspec.yaml has been updated and `flutter pub get` run). This
// means pasting this code early never crashes or red-screens - it
// just shows initials until the photo is properly wired up.
Widget buildPhotoAvatar(String assetPath, String fallbackInitials, Color fallbackColor, {double radius = 22}) {
  return ClipOval(
    child: Image.asset(
      assetPath,
      width: radius * 2,
      height: radius * 2,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => buildInitialsAvatar(fallbackInitials, fallbackColor, radius: radius),
    ),
  );
}

// Rounded rectangular photo box (house photo, etc) with the same
// safe fallback pattern - shows the dashed placeholder until the
// real asset is in place.
Widget buildPhotoBox(String assetPath, {required double height, IconData fallbackIcon = Icons.image_outlined, String fallbackLabel = 'Add a photo'}) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(12),
    child: Image.asset(
      assetPath,
      width: double.infinity,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => buildImagePlaceholder(label: fallbackLabel, icon: fallbackIcon, height: height),
    ),
  );
}

// Reusable profile preview. Kept controller-free and scroll-safe so it
// cannot trigger keyboard/controller lifecycle errors or overflow on
// smaller devices.
void showBudgetMateProfileDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: const Text('Profile'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            buildPhotoAvatar('assets/images/profile.jpeg', 'P', AppColors.primary, radius: 54),
            const SizedBox(height: 16),
            const Text(
              'Pratibha Khakural',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'pratibha@email.com',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.07),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.account_balance_wallet_outlined, color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('BudgetMate profile', style: TextStyle(fontWeight: FontWeight.w600)),
                        SizedBox(height: 2),
                        Text('Personal budgeting account', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}

// Consistent category -> color mapping, used on Home, Statement, and
// Analytics so the same category always reads the same color everywhere.
Color categoryColor(String category) {
  switch (category) {
    case 'Groceries':
      return AppColors.primary;
    case 'Uni':
      return const Color(0xFF4A90D9);
    case 'Social':
      return AppColors.secondary;
    case 'Bills':
      return AppColors.warning;
    case 'Transport':
      return AppColors.success;
    case 'Income':
    case 'Salary':
    case 'Shift Pay':
      return AppColors.success;
    default:
      return AppColors.textGrey;
  }
}

// ===== LOGIN PAGE =====
class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;
  bool obscurePassword = true;
  bool rememberMe = false;
  String? emailError;
  String? passwordError;

  bool _isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email);
  }

  void _handleLogin() {
    setState(() {
      emailError = null;
      passwordError = null;
    });

    if (emailController.text.isEmpty) {
      setState(() => emailError = 'Email is required');
      return;
    }
    if (!_isValidEmail(emailController.text)) {
      setState(() => emailError = 'Enter a valid email');
      return;
    }
    if (passwordController.text.isEmpty) {
      setState(() => passwordError = 'Password is required');
      return;
    }
    if (passwordController.text.length < 6) {
      setState(() => passwordError = 'Password must be at least 6 characters');
      return;
    }

    setState(() => isLoading = true);
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (!mounted) return;
      setState(() => isLoading = false);
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 400),
          pageBuilder: (context, animation, secondaryAnimation) => const HomePage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
      );
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 72, 24, 60),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary.withOpacity(0.85), AppColors.primary],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(48), bottomRight: Radius.circular(48)),
              ),
              clipBehavior: Clip.hardEdge,
              child: Stack(
                children: [
                  buildDecorativeCircle(),
                  Column(
                    children: [
                      buildIconBadge(Icons.account_balance_wallet_rounded),
                      const SizedBox(height: 22),
                      const Text(
                        'Welcome Back',
                        style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.5),
                      ),
                      const SizedBox(height: 6),
                      const Text('Check in on your spending', style: TextStyle(fontSize: 14, color: Colors.white70)),
                    ],
                  ),
                ],
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -36),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 24, offset: const Offset(0, 8))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Email', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: emailController,
                      enabled: !isLoading,
                      decoration: InputDecoration(
                        hintText: 'you@email.com',
                        prefixIcon: const Icon(Icons.email_outlined, size: 20),
                        errorText: emailError,
                        filled: true,
                        fillColor: AppColors.bgLight,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('Password', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: passwordController,
                      enabled: !isLoading,
                      obscureText: obscurePassword,
                      decoration: InputDecoration(
                        hintText: '••••••••',
                        prefixIcon: const Icon(Icons.lock_outline, size: 20),
                        suffixIcon: IconButton(
                          icon: Icon(obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20),
                          onPressed: () => setState(() => obscurePassword = !obscurePassword),
                        ),
                        errorText: passwordError,
                        filled: true,
                        fillColor: AppColors.bgLight,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 22,
                              height: 22,
                              child: Checkbox(
                                value: rememberMe,
                                activeColor: AppColors.primary,
                                onChanged: (v) => setState(() => rememberMe = v ?? false),
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text('Remember me', style: TextStyle(fontSize: 13)),
                          ],
                        ),
                        TextButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Password reset link would be sent to your email')),
                            );
                          },
                          child: Text('Forgot Password?', style: TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    buildPrimaryButton(label: 'Log in', onPressed: isLoading ? null : _handleLogin, loading: isLoading),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Face ID sign-in is available on supported devices')),
                          );
                        },
                        icon: Icon(Icons.fingerprint, color: AppColors.primary),
                        label: Text('Log in with Face ID', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.primary),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey[300])),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text('or continue with', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                      ),
                      Expanded(child: Divider(color: Colors.grey[300])),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.grey[300]!),
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: const Text('Google', style: TextStyle(fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.grey[300]!),
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: const Text('Apple', style: TextStyle(fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  buildInfoPill('256-bit encrypted. We never store your bank password'),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("New to BudgetMate? ", style: TextStyle(fontSize: 13)),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUpPage()));
                        },
                        child: Text('Create account', style: TextStyle(fontSize: 13, color: AppColors.secondary, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===== SIGN UP PAGE =====
class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool obscurePassword = true;
  bool isLoading = false;
  String? nameError;
  String? emailError;

  bool get hasMinLength => passwordController.text.length >= 8;
  bool get hasUppercase => RegExp(r'[A-Z]').hasMatch(passwordController.text);
  bool get hasNumberAndSpecial =>
      RegExp(r'[0-9]').hasMatch(passwordController.text) && RegExp(r'[!$%*&#@^()\-_=+]').hasMatch(passwordController.text);

  bool _isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email);
  }

  void _handleCreateAccount() {
    setState(() {
      nameError = null;
      emailError = null;
    });

    if (nameController.text.trim().isEmpty) {
      setState(() => nameError = 'Full name is required');
      return;
    }
    if (!_isValidEmail(emailController.text)) {
      setState(() => emailError = 'Enter a valid email');
      return;
    }
    if (!(hasMinLength && hasUppercase && hasNumberAndSpecial)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password does not meet all requirements yet')),
      );
      return;
    }

    setState(() => isLoading = true);
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (!mounted) return;
      setState(() => isLoading = false);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage()));
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Widget _requirementRow(String text, bool met) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        children: [
          Icon(met ? Icons.check_circle : Icons.circle_outlined, size: 14, color: met ? AppColors.success : Colors.grey[400]),
          const SizedBox(width: 6),
          Text(text, style: TextStyle(fontSize: 11, color: met ? AppColors.success : Colors.grey[500])),
        ],
      ),
    );
  }

  void _showPhotoNote() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Photo upload works on Android/iOS devices')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 72, 24, 60),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary.withOpacity(0.85), AppColors.primary],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(48), bottomRight: Radius.circular(48)),
              ),
              clipBehavior: Clip.hardEdge,
              child: Stack(
                children: [
                  buildDecorativeCircle(),
                  Column(
                    children: [
                      GestureDetector(
                        onTap: _showPhotoNote,
                        child: Stack(
                          children: [
                            buildPhotoAvatar('assets/images/profile.jpeg', 'P', AppColors.primary, radius: 36),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: AppColors.secondary,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: const Icon(Icons.camera_alt, size: 14, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),
                      const Text(
                        'BudgetMate',
                        style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.5),
                      ),
                      const SizedBox(height: 6),
                      const Text('Check your account to get started', style: TextStyle(fontSize: 14, color: Colors.white70)),
                    ],
                  ),
                ],
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -36),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 24, offset: const Offset(0, 8))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Full Name', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        hintText: 'e.g Pratibha Khakural',
                        prefixIcon: const Icon(Icons.person_outline, size: 20),
                        errorText: nameError,
                        filled: true,
                        fillColor: AppColors.bgLight,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('Email', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        hintText: 'you@email.com',
                        prefixIcon: const Icon(Icons.email_outlined, size: 20),
                        errorText: emailError,
                        filled: true,
                        fillColor: AppColors.bgLight,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('Password', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: passwordController,
                      obscureText: obscurePassword,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: '••••••••',
                        prefixIcon: const Icon(Icons.lock_outline, size: 20),
                        suffixIcon: IconButton(
                          icon: Icon(obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20),
                          onPressed: () => setState(() => obscurePassword = !obscurePassword),
                        ),
                        filled: true,
                        fillColor: AppColors.bgLight,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _requirementRow('Min. 8 characters', hasMinLength),
                    _requirementRow('1 uppercase letter', hasUppercase),
                    _requirementRow('1 number & 1 special character (!\$%*)', hasNumberAndSpecial),
                    const SizedBox(height: 16),
                    buildPrimaryButton(label: 'Create account', onPressed: isLoading ? null : _handleCreateAccount, loading: isLoading),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey[300])),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text('or continue with', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                      ),
                      Expanded(child: Divider(color: Colors.grey[300])),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.grey[300]!),
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: const Text('Google', style: TextStyle(fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.grey[300]!),
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: const Text('Apple', style: TextStyle(fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  buildInfoPill('256-bit encrypted. Bank linking is read-only and optional'),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Already have an account? ', style: TextStyle(fontSize: 13)),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Text('Sign in', style: TextStyle(fontSize: 13, color: AppColors.secondary, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===== HOME PAGE (with bottom nav) =====
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  int selectedIndex = 0;
  late AnimationController _animationController;
  bool faceIdEnabled = true;
  bool balanceVisible = true;
  bool subscriptionReminders = true;
  bool shiftReminders = false;
  // Budget Goals - real, user-editable values (not hardcoded demo
  // numbers) that actually drive Home's goal cards and Shift Income's
  // Smart Save calculation. This is the actual fix for "can't save
  // because income isn't fixed" - the app needs to know YOUR average,
  // not a guessed one.
  double savingGoal = 200;
  double expenseLimit = 460;
  double weeklyAverageIncome = 300;
  double currentNetWorth = 1350.66;
  double currentIncome = 960;
  double currentSpent = 390;

  final List<Map<String, dynamic>> _shifts = [
    {
      'day': 'WED',
      'date': '14',
      'employer': 'Annadale Grove',
      'time': '3:00PM - 9:00PM · 6hrs',
      'pay': '\$180',
      'hourlyRate': '\$30 /hr',
    },
    {
      'day': 'FRI',
      'date': '16',
      'employer': 'GMP Pharma',
      'time': '7:00AM - 3:00PM · 6hrs',
      'pay': '\$350',
      'hourlyRate': '\$39 /hr',
    },
    {
      'day': 'SAT',
      'date': '17',
      'employer': 'GMP Pharma',
      'time': '7:00AM - 3:00PM · 6hrs',
      'pay': '\$350',
      'hourlyRate': '\$39 /hr',
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: const Duration(milliseconds: 350), vsync: this);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _showAddShiftDialog() async {
    String employer = '';
    String day = '';
    String date = '';
    String time = '';
    String pay = '';
    String hourlyRate = '';

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add shift'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) => employer = value,
                decoration: const InputDecoration(labelText: 'Employer', hintText: 'e.g. GMP Pharma'),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: (value) => day = value.toUpperCase(),
                      decoration: const InputDecoration(labelText: 'Day', hintText: 'MON'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      keyboardType: TextInputType.number,
                      onChanged: (value) => date = value,
                      decoration: const InputDecoration(labelText: 'Date', hintText: '18'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                onChanged: (value) => time = value,
                decoration: const InputDecoration(labelText: 'Shift time', hintText: '9:00AM - 3:00PM · 6hrs'),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (value) => pay = value,
                      decoration: const InputDecoration(labelText: 'Expected pay', prefixText: '\$'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (value) => hourlyRate = value,
                      decoration: const InputDecoration(labelText: 'Hourly rate', prefixText: '\$'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final payValue = double.tryParse(pay.trim());
              final rateValue = double.tryParse(hourlyRate.trim());
              if (employer.trim().isEmpty || day.trim().isEmpty || date.trim().isEmpty || time.trim().isEmpty || payValue == null || payValue <= 0 || rateValue == null || rateValue <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please complete all shift details')),
                );
                return;
              }

              Navigator.pop(dialogContext, {
                'day': day.trim().length > 3 ? day.trim().substring(0, 3) : day.trim(),
                'date': date.trim(),
                'employer': employer.trim(),
                'time': time.trim(),
                'pay': '\$${payValue.toStringAsFixed(payValue.truncateToDouble() == payValue ? 0 : 2)}',
                'hourlyRate': '\$${rateValue.toStringAsFixed(rateValue.truncateToDouble() == rateValue ? 0 : 2)} /hr',
              });
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Add shift', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (!mounted || result == null) return;
    setState(() => _shifts.add(result));
  }

  Future<void> _openAddTransaction({String initialType = 'Expense'}) async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (context) => AddTransactionPage(initialType: initialType)),
    );

    if (!mounted || result == null) return;

    final amount = result['value'] as double;
    final isIncome = result['isIncome'] as bool;

    setState(() {
      budgetMateSessionTransactions.insert(0, result);
      if (isIncome) {
        currentIncome += amount;
        currentNetWorth += amount;
      } else {
        currentSpent += amount;
        currentNetWorth -= amount;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${isIncome ? 'Income' : 'Expense'} of \$${amount.toStringAsFixed(2)} saved to ${result['title']}'),
        backgroundColor: isIncome ? AppColors.primary : AppColors.textDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _openOurHouse() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const OurHousePage()));
  }

  void _openStatement() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const StatementPage()));
  }

  void _openNotifications() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsPage()));
  }

  void _openAnalytics() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const AnalyticsPage()));
  }

  Future<void> _openBudgetGoals() async {
    final result = await Navigator.push<Map<String, double>>(
      context,
      MaterialPageRoute(
        builder: (context) => BudgetGoalsPage(
          savingGoal: savingGoal,
          expenseLimit: expenseLimit,
          weeklyAverageIncome: weeklyAverageIncome,
        ),
      ),
    );
    if (result != null) {
      setState(() {
        savingGoal = result['savingGoal'] ?? savingGoal;
        expenseLimit = result['expenseLimit'] ?? expenseLimit;
        weeklyAverageIncome = result['weeklyAverageIncome'] ?? weeklyAverageIncome;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      drawer: _buildDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('BudgetMate', style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
        actions: [
          Stack(
            children: [
              IconButton(icon: const Icon(Icons.notifications_none, color: Colors.black), onPressed: _openNotifications),
              Positioned(
                right: 10,
                top: 10,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(color: AppColors.warning, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 1.5)),
                ),
              ),
            ],
          ),
          IconButton(icon: const Icon(Icons.person, color: Colors.black), onPressed: () => setState(() => selectedIndex = 3)),
        ],
      ),
      body: FadeTransition(
        opacity: _animationController,
        child: selectedIndex == 0
            ? _buildHomePage()
            : selectedIndex == 2
                ? _buildShiftIncomePage()
                : _buildSettingsPage(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: selectedIndex,
        onTap: (index) {
          if (index == 1) {
            _openAddTransaction();
            return;
          }
          setState(() {
            selectedIndex = index;
            _animationController.reset();
            _animationController.forward();
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle), label: 'Add'),
          BottomNavigationBarItem(icon: Icon(Icons.work), label: 'Shifts'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
      ),
    );
  }

  // Real navigation drawer - opens with the hamburger icon, which
  // previously had no onPressed action wired up at all.
  Widget _buildDrawer() {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              color: AppColors.primary,
              child: Row(
                children: [
                  buildPhotoAvatar('assets/images/profile.jpeg', 'P', Colors.white, radius: 24),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Pratibha Khakural', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        Text('pratibha@email.com', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  ListTile(
                    leading: const Icon(Icons.home_outlined),
                    title: const Text('Home'),
                    onTap: () {
                      Navigator.pop(context);
                      setState(() => selectedIndex = 0);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.receipt_long_outlined),
                    title: const Text('Statement'),
                    onTap: () {
                      Navigator.pop(context);
                      _openStatement();
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.work_outline),
                    title: const Text('Shift Income'),
                    onTap: () {
                      Navigator.pop(context);
                      setState(() => selectedIndex = 2);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.people_outline),
                    title: const Text('Our House'),
                    onTap: () {
                      Navigator.pop(context);
                      _openOurHouse();
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.insights_outlined),
                    title: const Text('Spending Insights'),
                    onTap: () {
                      Navigator.pop(context);
                      _openAnalytics();
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.flag_outlined),
                    title: const Text('Budget Goals'),
                    onTap: () {
                      Navigator.pop(context);
                      _openBudgetGoals();
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.settings_outlined),
                    title: const Text('Settings'),
                    onTap: () {
                      Navigator.pop(context);
                      setState(() => selectedIndex = 3);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.help_outline),
                    title: const Text('Help & FAQ'),
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Help & FAQ articles would open here')),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- SETTINGS TAB ----------
  Widget _buildSettingsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [AppColors.primary.withOpacity(0.85), AppColors.primary]),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.25), blurRadius: 16, offset: const Offset(0, 8))],
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => showBudgetMateProfileDialog(context),
                  child: Stack(
                    children: [
                      buildPhotoAvatar('assets/images/profile.jpeg', 'P', Colors.white, radius: 28),
                      Positioned(
                        bottom: -2,
                        right: -2,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 1.5)),
                          child: const Icon(Icons.camera_alt, size: 10, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Pratibha Khakural', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      SizedBox(height: 2),
                      Text('pratibha@email.com', style: TextStyle(color: Colors.white70, fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          buildSectionLabel('ACCOUNT'),
          _settingsTile(icon: Icons.account_balance_outlined, title: 'Connected accounts', trailing: '2 linked', onTap: _showConnectedAccounts),
          _settingsTile(icon: Icons.lock_outline, title: 'Change password', onTap: _showChangePassword),
          const SizedBox(height: 20),
          buildSectionLabel('SECURITY'),
          _settingsSwitchTile(
            icon: Icons.fingerprint,
            title: 'Log in with Face ID',
            value: faceIdEnabled,
            onChanged: (v) => setState(() => faceIdEnabled = v),
          ),
          const SizedBox(height: 20),
          buildSectionLabel('NOTIFICATIONS'),
          _settingsSwitchTile(
            icon: Icons.notifications_outlined,
            title: 'Subscription reminders',
            value: subscriptionReminders,
            onChanged: (v) => setState(() => subscriptionReminders = v),
          ),
          _settingsSwitchTile(
            icon: Icons.calendar_today_outlined,
            title: 'Shift reminders',
            value: shiftReminders,
            onChanged: (v) => setState(() => shiftReminders = v),
          ),
          const SizedBox(height: 20),
          buildSectionLabel('SUPPORT'),
          _settingsTile(
            icon: Icons.help_outline,
            title: 'Help & FAQ',
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Help & FAQ articles would open here'))),
          ),
          _settingsTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy & data',
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Privacy & data settings would open here'))),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _confirmLogout,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.warning),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Log Out', style: TextStyle(color: AppColors.warning, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _settingsTile({required IconData icon, required String title, String? trailing, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[300]!)),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w500))),
            if (trailing != null) ...[
              Text(trailing, style: TextStyle(color: Colors.grey[500], fontSize: 13)),
              const SizedBox(width: 4),
            ],
            Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
          ],
        ),
      ),
    );
  }

  Widget _settingsSwitchTile({required IconData icon, required String title, required bool value, required ValueChanged<bool> onChanged}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[300]!)),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w500))),
          Switch(value: value, activeColor: AppColors.primary, onChanged: onChanged),
        ],
      ),
    );
  }

  void _showConnectedAccounts() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Connected accounts'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            ListTile(leading: Icon(Icons.account_balance), title: Text('CommBank'), trailing: Icon(Icons.check_circle, color: Colors.green, size: 18)),
            ListTile(leading: Icon(Icons.account_balance), title: Text('ANZ'), trailing: Icon(Icons.check_circle, color: Colors.green, size: 18)),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
      ),
    );
  }
void _showChangePassword() {
  String currentPassword = '';
  String newPassword = '';

  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Change password'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              obscureText: true,
              onChanged: (value) {
                currentPassword = value;
              },
              decoration: const InputDecoration(
                labelText: 'Current password',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              obscureText: true,
              onChanged: (value) {
                newPassword = value;
              },
              decoration: const InputDecoration(
                labelText: 'New password',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(dialogContext);
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (newPassword.trim().length < 6) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'New password must be at least 6 characters',
                  ),
                ),
              );
              return;
            }

            Navigator.pop(dialogContext);

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Password updated'),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
          ),
          child: const Text(
            'Save',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    ),
  );
}
  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('You will need to sign in again to access BudgetMate.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const LoginPage()), (route) => false);
            },
            child: Text('Log Out', style: TextStyle(color: AppColors.warning)),
          ),
        ],
      ),
    );
  }

  // ---------- HOME TAB ----------
  Widget _buildHomePage() {
    // "Money left for fun" answers the real question behind irregular
    // income: after savings and essentials are covered, is there
    // anything left to actually enjoy? Computed from the same editable
    // Budget Goals numbers used everywhere else - not a separate,
    // disconnected figure.
    final estimatedMonthlyIncome = weeklyAverageIncome * 4.33;
    final funMoney = estimatedMonthlyIncome - savingGoal - expenseLimit;

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        await Future.delayed(const Duration(milliseconds: 700));
      },
      child: SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [AppColors.primary.withOpacity(0.9), AppColors.primary]),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
            ),
            clipBehavior: Clip.hardEdge,
            child: Stack(
              children: [
                buildDecorativeCircle(),
                Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Net worth', style: TextStyle(color: Colors.white70, fontSize: 14)),
                    GestureDetector(
                      onTap: () => setState(() => balanceVisible = !balanceVisible),
                      child: Icon(
                        balanceVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: Colors.white70,
                        size: 18,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      balanceVisible ? '\$${currentNetWorth.toStringAsFixed(2)}' : '••••••',
                      style: const TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w800, letterSpacing: -0.5),
                    ),
                    const SizedBox(width: 10),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.18), borderRadius: BorderRadius.circular(20)),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.trending_up, color: Colors.greenAccent, size: 14),
                            SizedBox(width: 3),
                            Text('4.2%', style: TextStyle(color: Colors.greenAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Income', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(
                          balanceVisible ? '\$${currentIncome.toStringAsFixed(2)}' : '••••',
                          style: const TextStyle(color: Colors.greenAccent, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Spent', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(
                          balanceVisible ? '\$${currentSpent.toStringAsFixed(2)}' : '••••',
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: buildPrimaryButton(label: '+  Add Expense', onPressed: () => _openAddTransaction(initialType: 'Expense')),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: buildPrimaryButton(label: '+  Add Income', onPressed: () => _openAddTransaction(initialType: 'Income'), color: AppColors.secondary),
              ),
            ],
          ),
          const SizedBox(height: 24),
          InkWell(
            onTap: _openNotifications,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[300]!)),
              child: Row(
                children: [
                  Icon(Icons.notifications, color: AppColors.secondary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Netflix - \$15.55 due in 2 days', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 4),
                        Text('Subscription reminder', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: Colors.grey[400]),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buildSectionLabel('RECENT'),
              TextButton(onPressed: _openStatement, child: const Text('See all')),
            ],
          ),
          ...budgetMateSessionTransactions.take(3).expand((t) => [
                _transactionItem(
                  icon: t['icon'] as IconData,
                  title: t['title'] as String,
                  amount: t['amount'] as String,
                  color: (t['isIncome'] as bool) ? AppColors.success : AppColors.warning,
                  category: t['category'] as String,
                ),
                const SizedBox(height: 12),
              ]),
          _transactionItem(icon: Icons.work, title: 'Salary - Mart job', amount: '+\$189.66', color: AppColors.success, category: 'Salary'),
          const SizedBox(height: 12),
          _transactionItem(icon: Icons.school, title: 'Books', amount: '-\$189.66', color: AppColors.warning, category: 'Uni'),
          const SizedBox(height: 12),
          _transactionItem(icon: Icons.shopping_cart, title: 'Groceries', amount: '-\$23.66', color: AppColors.warning, category: 'Groceries'),
          const SizedBox(height: 12),
          _transactionItem(icon: Icons.work, title: 'Salary - Parttime Job', amount: '+\$330', color: AppColors.success, category: 'Salary'),
          const SizedBox(height: 24),
          buildSectionLabel('CONNECTED ACCOUNTS'),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[300]!)),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [Icon(Icons.account_balance), SizedBox(height: 8), Text('CommBank', style: TextStyle(fontWeight: FontWeight.bold))],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[300]!)),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [Icon(Icons.account_balance), SizedBox(height: 8), Text('ANZ', style: TextStyle(fontWeight: FontWeight.bold))],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _addAccountButton()),
              const SizedBox(width: 12),
              Expanded(child: _addAccountButton()),
            ],
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: _openOurHouse,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [AppColors.primary.withOpacity(0.9), AppColors.primary]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Our House', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      SizedBox(height: 4),
                      Text('Sara and mike owe you \$42.30', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                  const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _openAnalytics,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[300]!)),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: AppColors.success.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                    child: Icon(Icons.insights, color: AppColors.success, size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Spending Insights', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        SizedBox(height: 2),
                        Text('See where your money went this month', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: Colors.grey[400]),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buildSectionLabel("THIS MONTH'S GOALS"),
              GestureDetector(
                onTap: _openBudgetGoals,
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 14, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text('Edit', style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[300]!)),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
                  child: Center(child: Text('\$${savingGoal.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Saving for this month', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Goal: Save \$${savingGoal.toStringAsFixed(0)}', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[300]!)),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(8)),
                  child: Center(child: Text('\$${expenseLimit.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Expenses for this month', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Goal: Limit to \$${expenseLimit.toStringAsFixed(0)}', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.success.withOpacity(0.25)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: AppColors.success.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                  child: Icon(Icons.celebration_outlined, color: AppColors.success, size: 22),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Money left for fun', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      SizedBox(height: 2),
                      Text('After savings and essentials this month', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
                Text(
                  '\$${funMoney.toStringAsFixed(0)}',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: funMoney >= 0 ? AppColors.success : AppColors.warning),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
      ),
    );
  }

  Widget _transactionItem({required IconData icon, required String title, required String amount, required Color color, required String category}) {
    final catColor = categoryColor(category);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[300]!)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: catColor.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: catColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w500))),
          Text(amount, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  // Was missing from the build even though it's in the Figma - the
  // "+" tiles under Connected Accounts for linking another bank.
  Widget _addAccountButton() {
    return GestureDetector(
      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bank linking would open here')),
      ),
      child: Container(
        height: 64,
        decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[300]!)),
        child: Icon(Icons.add, color: Colors.grey[400]),
      ),
    );
  }

  // ---------- SHIFTS TAB ----------
  Widget _buildShiftIncomePage() {
    // Predicted amount from this week's 3 shifts (demo data below).
    // Surplus is computed against the user's own editable average,
    // not a hardcoded guess - this is what makes Smart Save real.
    const predictedThisWeek = 419.50;
    final surplus = predictedThisWeek - weeklyAverageIncome;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          // Replaced the CircularProgressIndicator + centered-text Stack,
          // which was the fragile construction causing the smeared
          // rendering glitch - big number + LinearProgressIndicator is
          // the same widget type already proven working on Analytics.
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[200]!),
            ),
            clipBehavior: Clip.hardEdge,
            child: Stack(
              children: [
                Positioned(
                  right: -24,
                  top: -24,
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.06), shape: BoxShape.circle),
                  ),
                ),
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('99', style: TextStyle(fontSize: 52, fontWeight: FontWeight.w800, color: AppColors.primary)),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text('%', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.primary)),
                        ),
                      ],
                    ),
                    Text("of this week's goal", style: TextStyle(fontSize: 13, color: Colors.grey[500])),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: 0.99,
                        minHeight: 12,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.savings_outlined, color: AppColors.secondary, size: 18),
                        const SizedBox(width: 8),
                        const Text('Almost there!', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [AppColors.primary.withOpacity(0.9), AppColors.primary]),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
            ),
            clipBehavior: Clip.hardEdge,
            child: Stack(
              children: [
                Positioned(
                  right: -30,
                  top: -30,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), shape: BoxShape.circle),
                  ),
                ),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Predicted this week', style: TextStyle(color: Colors.white70, fontSize: 14)),
                    SizedBox(height: 8),
                    Text('\$419.50', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text('Goal: \$420 · 3 shifts', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (surplus > 0)
            Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.success.withOpacity(0.25)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.savings, color: AppColors.success, size: 20),
                    const SizedBox(width: 8),
                    Text('Smart Save suggestion', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.success, fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "You're \$${surplus.toStringAsFixed(2)} above your usual weekly income. Want to move the extra to savings?",
                  style: TextStyle(fontSize: 13, color: AppColors.textDark),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Moved \$${surplus.toStringAsFixed(2)} to savings!'), backgroundColor: AppColors.success),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.success),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('Move \$${surplus.toStringAsFixed(2)} to Savings', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Upcoming shifts', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              TextButton(onPressed: _showAddShiftDialog, child: const Text('+ Add Shift')),
            ],
          ),
          const SizedBox(height: 12),
          ..._shifts.expand((shift) => [
                _shiftCard(
                  day: shift['day'] as String,
                  date: shift['date'] as String,
                  employer: shift['employer'] as String,
                  time: shift['time'] as String,
                  pay: shift['pay'] as String,
                  hourlyRate: shift['hourlyRate'] as String,
                ),
                const SizedBox(height: 12),
              ]),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.success.withOpacity(0.08), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.success.withOpacity(0.3))),
            child: Row(
              children: [
                Icon(Icons.info, color: AppColors.success),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Estimated monthly income: \$1,236',
                    style: TextStyle(fontSize: 13, color: AppColors.success),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _shiftCard({required String day, required String date, required String employer, required String time, required String pay, required String hourlyRate}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[300]!)),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(day, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary)),
                Text(date, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(employer, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text(time, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(pay, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.success)),
              const SizedBox(height: 4),
              Text(hourlyRate, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
            ],
          ),
        ],
      ),
    );
  }
}

// ===== ADD TRANSACTION PAGE (bug fixed: scrollable, keyboard-safe) =====
class AddTransactionPage extends StatefulWidget {
  final String initialType;
  const AddTransactionPage({Key? key, this.initialType = 'Expense'}) : super(key: key);

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  late String transactionType;
  String amountText = '0';
  String selectedCategory = 'Groceries';
  DateTime selectedDate = DateTime.now();
  String note = '';
  String? amountError;

  final List<String> expenseCategories = ['Groceries', 'Uni', 'Social', 'Bills', 'Transport', 'Other'];
  final List<String> incomeCategories = ['Salary', 'Shift Pay', 'Gift', 'Refund', 'Other'];

  @override
  void initState() {
    super.initState();
    transactionType = widget.initialType;
    selectedCategory = transactionType == 'Expense' ? expenseCategories.first : incomeCategories.first;
  }

  List<String> get _currentCategories => transactionType == 'Expense' ? expenseCategories : incomeCategories;

  void _onKeyTap(String key) {
    setState(() {
      amountError = null;
      if (key == 'back') {
        amountText = amountText.length > 1 ? amountText.substring(0, amountText.length - 1) : '0';
        return;
      }
      if (key == '.') {
        if (amountText.contains('.')) return;
        amountText += '.';
        return;
      }
      if (amountText.contains('.')) {
        final decimals = amountText.split('.')[1];
        if (decimals.length >= 2) return;
      }
      if (amountText == '0') {
        amountText = key;
      } else {
        if (amountText.length >= 8) return;
        amountText += key;
      }
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(context: context, initialDate: selectedDate, firstDate: DateTime(2020), lastDate: DateTime(2030));
    if (!mounted) return;
    if (picked != null) setState(() => selectedDate = picked);
  }

  // FIX: the note is edited in its own dialog instead of an inline
  // TextField. That was the root cause of the overflow bug - the
  // system keyboard and the custom number keypad were both trying to
  // occupy the bottom of the screen at once. A dialog's keyboard
  // doesn't compete with the keypad underneath it.
  Future<void> _editNote() async {
  String editedNote = note;

  final result = await showDialog<String>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Add a note'),
      content: TextFormField(
        initialValue: note,
        autofocus: true,
        onChanged: (value) {
          editedNote = value;
        },
        decoration: const InputDecoration(
          hintText: 'e.g. Woolworths weekly shop',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(dialogContext);
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(dialogContext, editedNote);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
          ),
          child: const Text(
            'Save',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    ),
  );

  if (!mounted) return;

  if (result != null) {
    setState(() {
      note = result;
    });
  }
}

  String get _formattedDate {
    final now = DateTime.now();
    if (selectedDate.year == now.year && selectedDate.month == now.month && selectedDate.day == now.day) return 'Today';
    return '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}';
  }

  void _handleSave() {
    final parsed = double.tryParse(amountText);
    if (parsed == null || parsed <= 0) {
      setState(() => amountError = 'Enter an amount first');
      return;
    }

    final isIncome = transactionType == 'Income';
    final statementCategory = isIncome
        ? 'Income'
        : (selectedCategory == 'Uni' || selectedCategory == 'Social' ? selectedCategory : selectedCategory);

    Navigator.pop(context, {
      'group': 'TODAY',
      'icon': isIncome ? Icons.work : _categoryIcon(selectedCategory),
      'title': selectedCategory,
      'subtitle': '${isIncome ? 'Income' : selectedCategory}${note.trim().isEmpty ? '' : ' · ${note.trim()}'}',
      'amount': '${isIncome ? '+' : '-'}\$${parsed.toStringAsFixed(2)}',
      'category': statementCategory,
      'isIncome': isIncome,
      'value': parsed,
      'note': note.trim(),
    });
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'Groceries': return Icons.shopping_cart;
      case 'Uni': return Icons.school;
      case 'Social': return Icons.people_outline;
      case 'Bills': return Icons.receipt_long;
      case 'Transport': return Icons.directions_bus;
      case 'Salary': return Icons.work;
      case 'Shift Pay': return Icons.work_outline;
      case 'Gift': return Icons.card_giftcard;
      case 'Refund': return Icons.replay;
      default: return Icons.payments_outlined;
    }
  }

  Widget _keypadButton(String label, {IconData? icon}) {
    return Expanded(
      child: InkWell(
        onTap: () => _onKeyTap(label),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          alignment: Alignment.center,
          child: icon != null ? Icon(icon, size: 22) : Text(label, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isExpense = transactionType == 'Expense';
    final accentColor = isExpense ? AppColors.textDark : AppColors.primary;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.close, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: const Text('New Transaction', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      // The whole top section scrolls independently, so if the screen
      // is short there is no overflow - the keypad stays fixed below it.
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() {
                              transactionType = 'Expense';
                              selectedCategory = expenseCategories.first;
                            }),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(color: isExpense ? AppColors.textDark : Colors.transparent, borderRadius: BorderRadius.circular(10)),
                              child: Text('Expense', textAlign: TextAlign.center, style: TextStyle(color: isExpense ? Colors.white : Colors.black54, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() {
                              transactionType = 'Income';
                              selectedCategory = incomeCategories.first;
                            }),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(color: !isExpense ? AppColors.primary : Colors.transparent, borderRadius: BorderRadius.circular(10)),
                              child: Text('Income', textAlign: TextAlign.center, style: TextStyle(color: !isExpense ? Colors.white : Colors.black54, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Column(
                      children: [
                        Text('\$$amountText', style: TextStyle(fontSize: 44, fontWeight: FontWeight.bold, color: amountError != null ? AppColors.warning : Colors.black)),
                        if (amountError != null) ...[
                          const SizedBox(height: 4),
                          Text(amountError!, style: TextStyle(color: AppColors.warning, fontSize: 12)),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                              builder: (context) => SafeArea(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: _currentCategories
                                      .map((c) => ListTile(
                                            title: Text(c),
                                            trailing: c == selectedCategory ? Icon(Icons.check, color: accentColor) : null,
                                            onTap: () {
                                              setState(() => selectedCategory = c);
                                              Navigator.pop(context);
                                            },
                                          ))
                                      .toList(),
                                ),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(10)),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.category_outlined, size: 16, color: Colors.grey[600]),
                                const SizedBox(width: 6),
                                Text(selectedCategory, style: const TextStyle(fontSize: 13)),
                                const Icon(Icons.arrow_drop_down, size: 18),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: _pickDate,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(10)),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                                const SizedBox(width: 6),
                                Text(_formattedDate, style: const TextStyle(fontSize: 13)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  GestureDetector(
                    onTap: _editNote,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        children: [
                          const Icon(Icons.edit_note, size: 20, color: Colors.grey),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              note.isEmpty ? 'Add a note - e.g. Woolworths weekly shop' : note,
                              style: TextStyle(fontSize: 13, color: note.isEmpty ? Colors.grey[500] : Colors.black87),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  buildImagePlaceholder(label: 'Add receipt photo (optional)', icon: Icons.receipt_long_outlined),
                ],
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.grey[200]!))),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                Row(children: [_keypadButton('1'), _keypadButton('2'), _keypadButton('3')]),
                Row(children: [_keypadButton('4'), _keypadButton('5'), _keypadButton('6')]),
                Row(children: [_keypadButton('7'), _keypadButton('8'), _keypadButton('9')]),
                Row(children: [_keypadButton('.'), _keypadButton('0'), _keypadButton('back', icon: Icons.backspace_outlined)]),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: buildPrimaryButton(label: isExpense ? 'Save Expense' : 'Save Income', onPressed: _handleSave, color: accentColor),
          ),
        ],
      ),
    );
  }
}

// ===== OUR HOUSE PAGE (housemate bill splitting) =====
class OurHousePage extends StatefulWidget {
  const OurHousePage({Key? key}) : super(key: key);

  @override
  State<OurHousePage> createState() => _OurHousePageState();
}

class _OurHousePageState extends State<OurHousePage> {
  final List<Map<String, dynamic>> _bills = [
    {
      'icon': Icons.bolt,
      'title': 'Electricity Bill',
      'subtitle': 'Paid by you · split 4 ways',
      'amount': '\$96.00',
    },
    {
      'icon': Icons.wifi,
      'title': 'Internet',
      'subtitle': 'Paid by Mike · split 4 ways',
      'amount': '\$78.90',
    },
    {
      'icon': Icons.shopping_cart,
      'title': 'House Groceries',
      'subtitle': 'Paid by Sarah · split 3 ways',
      'amount': '\$54.90',
    },
  ];

  Future<void> _showAddBillDialog() async {
    String billName = '';
    String amount = '';
    String paidBy = 'You';
    int splitWays = 4;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add shared bill'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  onChanged: (value) => billName = value,
                  decoration: const InputDecoration(labelText: 'Bill name', hintText: 'e.g. Water Bill'),
                ),
                const SizedBox(height: 12),
                TextField(
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (value) => amount = value,
                  decoration: const InputDecoration(labelText: 'Amount', prefixText: '\$'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: paidBy,
                  decoration: const InputDecoration(labelText: 'Paid by'),
                  items: const [
                    DropdownMenuItem(value: 'You', child: Text('You')),
                    DropdownMenuItem(value: 'Mike', child: Text('Mike')),
                    DropdownMenuItem(value: 'Jordan', child: Text('Jordan')),
                    DropdownMenuItem(value: 'Sarah', child: Text('Sarah')),
                  ],
                  onChanged: (value) {
                    if (value != null) setDialogState(() => paidBy = value);
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  value: splitWays,
                  decoration: const InputDecoration(labelText: 'Split between'),
                  items: const [
                    DropdownMenuItem(value: 2, child: Text('2 people')),
                    DropdownMenuItem(value: 3, child: Text('3 people')),
                    DropdownMenuItem(value: 4, child: Text('4 people')),
                  ],
                  onChanged: (value) {
                    if (value != null) setDialogState(() => splitWays = value);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final amountValue = double.tryParse(amount.trim());
                if (billName.trim().isEmpty || amountValue == null || amountValue <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Enter a bill name and valid amount')),
                  );
                  return;
                }
                Navigator.pop(dialogContext, {
                  'icon': Icons.receipt_long_outlined,
                  'title': billName.trim(),
                  'subtitle': 'Paid by ${paidBy.toLowerCase()} · split $splitWays ways',
                  'amount': '\$${amountValue.toStringAsFixed(2)}',
                });
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('Add bill', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );

    if (!mounted || result == null) return;
    setState(() => _bills.add(result));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text('Our House', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: buildPhotoAvatar('assets/images/profile.jpeg', 'P', AppColors.primary, radius: 16),
            onPressed: () => showBudgetMateProfileDialog(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildPhotoBox('assets/images/house.jpeg', height: 130, fallbackIcon: Icons.house_outlined, fallbackLabel: 'Add a house photo'),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [AppColors.primary.withOpacity(0.9), AppColors.primary]),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
              ),
              clipBehavior: Clip.hardEdge,
              child: Stack(
                children: [
                  buildDecorativeCircle(),
                  Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Spent this week', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 8),
                  const Text('\$42.30', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Settle up feature coming soon')));
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                          child: Text('Settle Up', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        decoration: BoxDecoration(border: Border.all(color: Colors.white), borderRadius: BorderRadius.circular(10)),
                        child: IconButton(icon: const Icon(Icons.share, color: Colors.white), onPressed: () {}),
                      ),
                    ],
                  ),
                ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Flatmates', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const Text('4 people · split evenly by default', style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 12),
            _flatmateRow('P', 'Pratibha', AppColors.primary, '', isYou: true, photoAsset: 'assets/images/profile.jpeg'),
            _flatmateRow('M', 'Mike', AppColors.secondary, 'owes \$18.50', photoAsset: 'assets/images/mike.jpeg'),
            _flatmateRow('J', 'Jordan', const Color(0xFF4A90D9), 'owes \$18.50', photoAsset: 'assets/images/jordan.jpeg'),
            _flatmateRow('S', 'Sarah', AppColors.success, 'Settled', settled: true, photoAsset: 'assets/images/sarah.jpeg'),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Shared Bills', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                TextButton.icon(onPressed: _showAddBillDialog, icon: const Icon(Icons.add, size: 18), label: const Text('Add bill')),
              ],
            ),
            const SizedBox(height: 8),
            ..._bills.map((bill) => _billRow(
                  bill['icon'] as IconData,
                  bill['title'] as String,
                  bill['subtitle'] as String,
                  bill['amount'] as String,
                )),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _flatmateRow(String initials, String name, Color color, String status, {bool isYou = false, bool settled = false, String? photoAsset}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          photoAsset != null ? buildPhotoAvatar(photoAsset, initials, color) : buildInitialsAvatar(initials, color),
          const SizedBox(width: 12),
          Expanded(child: Text(isYou ? '$name (You)' : name, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15))),
          if (status.isNotEmpty)
            Text(status, style: TextStyle(color: settled ? AppColors.success : AppColors.secondary, fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _billRow(IconData icon, String title, String subtitle, String amount) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[300]!)),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
          ),
          Text(amount, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// ===== STATEMENT PAGE (all transactions, filterable) =====
class StatementPage extends StatefulWidget {
  const StatementPage({Key? key}) : super(key: key);

  @override
  State<StatementPage> createState() => _StatementPageState();
}

class _StatementPageState extends State<StatementPage> {
  String selectedFilter = 'All';
  String searchQuery = '';
  bool sortByAmount = false;
  final filters = ['All', 'Income', 'Uni', 'Social'];

  // Demo dataset matching the Figma statement mockup.
  late final List<Map<String, dynamic>> _transactions = [
    ...budgetMateSessionTransactions.map((t) => Map<String, dynamic>.from(t)),
    {'group': 'TODAY', 'icon': Icons.shopping_cart, 'title': 'Groceries', 'subtitle': 'Uni · shopping cart', 'amount': '-\$23.66', 'category': 'Uni', 'isIncome': false},
    {'group': 'TODAY', 'icon': Icons.local_cafe, 'title': 'Coffee with Friends', 'subtitle': 'Social · coffee', 'amount': '-\$23.66', 'category': 'Social', 'isIncome': false},
    {'group': 'YESTERDAY', 'icon': Icons.menu_book, 'title': 'Textbook Rental', 'subtitle': 'Uni · books', 'amount': '-\$23.66', 'category': 'Uni', 'isIncome': false},
    {'group': 'YESTERDAY', 'icon': Icons.work, 'title': 'Salary - Part-time job', 'subtitle': 'Income · briefcase', 'amount': '+\$189.66', 'category': 'Income', 'isIncome': true},
    {'group': '12 JULY', 'icon': Icons.directions_bus, 'title': 'Bus Fare', 'subtitle': 'Uni · bus', 'amount': '-\$29.66', 'category': 'Uni', 'isIncome': false},
    {'group': '12 JULY', 'icon': Icons.checkroom, 'title': 'Clothes', 'subtitle': 'Social · t-shirt', 'amount': '-\$78.90', 'category': 'Social', 'isIncome': false},
  ];

  List<Map<String, dynamic>> get _filtered {
    var list = _transactions;
    if (selectedFilter != 'All') {
      list = list.where((t) => t['category'] == selectedFilter).toList();
    }
    if (searchQuery.trim().isNotEmpty) {
      final q = searchQuery.trim().toLowerCase();
      list = list.where((t) => (t['title'] as String).toLowerCase().contains(q)).toList();
    }
    if (sortByAmount) {
      list = List<Map<String, dynamic>>.from(list)
        ..sort((a, b) => _parseAmount(b['amount'] as String).compareTo(_parseAmount(a['amount'] as String)));
    }
    return list;
  }

  double _parseAmount(String amount) {
    return double.parse(amount.replaceAll(RegExp(r'[^0-9.]'), ''));
  }

  void _showTransactionDetail(Map<String, dynamic> t) {
    final color = categoryColor(t['category'] as String);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
                  child: Icon(t['icon'] as IconData, color: color),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(t['group'] as String, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                    ],
                  ),
                ),
                Text(
                  t['amount'] as String,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: (t['isIncome'] as bool) ? AppColors.success : AppColors.textDark),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _detailRow('Category', t['category'] as String),
            _detailRow('Note', ((t['note'] as String?)?.trim().isNotEmpty ?? false) ? t['note'] as String : 'No note added'),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  setState(() => _transactions.remove(t));
                  budgetMateSessionTransactions.removeWhere((item) =>
                      item['amount'] == t['amount'] && item['title'] == t['title'] && item['note'] == t['note']);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Transaction deleted')));
                },
                icon: Icon(Icons.delete_outline, color: AppColors.warning),
                label: Text('Delete transaction', style: TextStyle(color: AppColors.warning)),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.warning),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(width: 90, child: Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 13))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13))),
        ],
      ),
    );
  }

  Widget _statChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 11, color: color)),
          const SizedBox(height: 2),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: color)),
        ],
      ),
    );
  }

  // Single transaction row - shared between the grouped-by-date view
  // and the flat sorted-by-amount view, so both stay visually identical.
  Widget _transactionRow(Map<String, dynamic> t) {
    return GestureDetector(
      onTap: () => _showTransactionDetail(t),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: categoryColor(t['category'] as String).withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
              child: Icon(t['icon'] as IconData, size: 20, color: categoryColor(t['category'] as String)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t['title'] as String, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  Text(t['subtitle'] as String, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                ],
              ),
            ),
            Text(
              t['amount'] as String,
              style: TextStyle(fontWeight: FontWeight.bold, color: (t['isIncome'] as bool) ? AppColors.success : AppColors.textDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _weeklyBar(String day, double value) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            height: 42 * value + 8,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.82),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(height: 5),
          Text(day, style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final grouped = <String, List<Map<String, dynamic>>>{};
    for (final t in _filtered) {
      grouped.putIfAbsent(t['group'] as String, () => []).add(t);
    }
    final totalIncome = _filtered.where((t) => t['isIncome'] as bool).fold<double>(0, (sum, t) => sum + _parseAmount(t['amount'] as String));
    final totalExpense = _filtered.where((t) => !(t['isIncome'] as bool)).fold<double>(0, (sum, t) => sum + _parseAmount(t['amount'] as String));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text('Your Statement', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share, color: Colors.black),
            tooltip: 'Export statement',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Would export as PDF/CSV in the full app')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [AppColors.primary.withOpacity(0.9), AppColors.primary]),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
              ),
              clipBehavior: Clip.hardEdge,
              child: Stack(
                children: [
                  buildDecorativeCircle(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Spent this week', style: TextStyle(color: Colors.white70, fontSize: 14)),
                      const SizedBox(height: 8),
                      const Text('\$107', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 18),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _weeklyBar('M', 0.35),
                          _weeklyBar('T', 0.62),
                          _weeklyBar('W', 0.48),
                          _weeklyBar('T', 0.82),
                          _weeklyBar('F', 0.55),
                          _weeklyBar('S', 0.72),
                          _weeklyBar('S', 0.28),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _statChip('Income', '+\$${totalIncome.toStringAsFixed(2)}', AppColors.success)),
                const SizedBox(width: 12),
                Expanded(child: _statChip('Expenses', '-\$${totalExpense.toStringAsFixed(2)}', AppColors.warning)),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              onChanged: (v) => setState(() => searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Search transactions',
                prefixIcon: const Icon(Icons.search, size: 20),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text('Sort:', style: TextStyle(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.w600)),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => setState(() => sortByAmount = false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: !sortByAmount ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text('Recent', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: !sortByAmount ? AppColors.primary : Colors.grey[500])),
                  ),
                ),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: () => setState(() => sortByAmount = true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: sortByAmount ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text('Highest amount', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: sortByAmount ? AppColors.primary : Colors.grey[500])),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: filters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final filter = filters[index];
                  final isSelected = filter == selectedFilter;
                  return GestureDetector(
                    onTap: () => setState(() => selectedFilter = filter),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.textDark : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isSelected ? AppColors.textDark : Colors.grey[300]!),
                      ),
                      child: Center(
                        child: Text(filter, style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: FontWeight.w600, fontSize: 13)),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            if (_filtered.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Center(child: Text('No transactions in this category', style: TextStyle(color: Colors.grey[500]))),
              )
            else if (sortByAmount) ...[
              Text('HIGHEST AMOUNT FIRST', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey[600], letterSpacing: 0.5)),
              const SizedBox(height: 8),
              ..._filtered.map((t) => _transactionRow(t)),
            ] else
              ...grouped.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(entry.key, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey[600], letterSpacing: 0.5)),
                      const SizedBox(height: 8),
                      ...entry.value.map((t) => _transactionRow(t)),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

// ===== NOTIFICATIONS PAGE =====
class NotificationsPage extends StatelessWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final items = [
      {'icon': Icons.subscriptions_outlined, 'color': AppColors.secondary, 'title': 'Netflix subscription due', 'subtitle': '\$15.55 due in 2 days', 'time': '2h ago'},
      {'icon': Icons.work_outline, 'color': AppColors.primary, 'title': 'Upcoming shift reminder', 'subtitle': 'Annadale Grove · Wed 14, 3:00PM', 'time': '5h ago'},
      {'icon': Icons.people_outline, 'color': AppColors.success, 'title': 'Mike settled up', 'subtitle': 'Our House · \$18.50 received', 'time': '1d ago'},
      {'icon': Icons.insights, 'color': AppColors.success, 'title': 'Weekly spending report ready', 'subtitle': 'You spent \$107 this week', 'time': '2d ago'},
    ];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text('Notifications', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final item = items[index];
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[300]!)),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: (item['color'] as Color).withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                  child: Icon(item['icon'] as IconData, color: item['color'] as Color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 2),
                      Text(item['subtitle'] as String, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                    ],
                  ),
                ),
                Text(item['time'] as String, style: TextStyle(fontSize: 11, color: Colors.grey[400])),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ===== SPENDING INSIGHTS / ANALYTICS PAGE =====
class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final categories = [
      {'name': 'Bills', 'amount': 130.0, 'color': AppColors.warning},
      {'name': 'Groceries', 'amount': 120.0, 'color': AppColors.primary},
      {'name': 'Uni', 'amount': 80.0, 'color': const Color(0xFF4A90D9)},
      {'name': 'Social', 'amount': 60.0, 'color': AppColors.secondary},
      {'name': 'Transport', 'amount': 40.0, 'color': AppColors.success},
    ];
    final total = categories.fold<double>(0, (sum, c) => sum + (c['amount'] as double));
    final maxAmount = categories.map((c) => c['amount'] as double).reduce((a, b) => a > b ? a : b);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text('Spending Insights', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [AppColors.success.withOpacity(0.9), AppColors.success]),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: AppColors.success.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
              ),
              clipBehavior: Clip.hardEdge,
              child: Stack(
                children: [
                  buildDecorativeCircle(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total spent this month', style: TextStyle(color: Colors.white70, fontSize: 14)),
                      const SizedBox(height: 8),
                      Text('\$${total.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            buildSectionLabel('BY CATEGORY'),
            ...categories.map((c) {
              final amount = c['amount'] as double;
              final color = c['color'] as Color;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(c['name'] as String, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                        Text('\$${amount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: amount / maxAmount,
                        minHeight: 10,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Bills are your biggest category this month - worth checking for any subscriptions you no longer use.',
                      style: TextStyle(fontSize: 13, color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ===== BUDGET GOALS PAGE (real, editable - not hardcoded demo numbers) =====
class BudgetGoalsPage extends StatefulWidget {
  final double savingGoal;
  final double expenseLimit;
  final double weeklyAverageIncome;

  const BudgetGoalsPage({
    Key? key,
    required this.savingGoal,
    required this.expenseLimit,
    required this.weeklyAverageIncome,
  }) : super(key: key);

  @override
  State<BudgetGoalsPage> createState() => _BudgetGoalsPageState();
}

class _BudgetGoalsPageState extends State<BudgetGoalsPage> {
  late final TextEditingController savingController;
  late final TextEditingController expenseController;
  late final TextEditingController averageController;
  String? error;

  @override
  void initState() {
    super.initState();
    savingController = TextEditingController(text: widget.savingGoal.toStringAsFixed(0));
    expenseController = TextEditingController(text: widget.expenseLimit.toStringAsFixed(0));
    averageController = TextEditingController(text: widget.weeklyAverageIncome.toStringAsFixed(0));
  }

  @override
  void dispose() {
    savingController.dispose();
    expenseController.dispose();
    averageController.dispose();
    super.dispose();
  }

  void _handleSave() {
    final saving = double.tryParse(savingController.text.trim());
    final expense = double.tryParse(expenseController.text.trim());
    final average = double.tryParse(averageController.text.trim());

    if (saving == null || expense == null || average == null || saving <= 0 || expense <= 0 || average <= 0) {
      setState(() => error = 'Enter valid positive numbers for all three fields');
      return;
    }

    Navigator.pop(context, {
      'savingGoal': saving,
      'expenseLimit': expense,
      'weeklyAverageIncome': average,
    });
  }

  Widget _numberField({required String label, required String hint, required TextEditingController controller, required IconData icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            prefixText: '\$ ',
            prefixIcon: Icon(icon, size: 20),
            hintText: hint,
            filled: true,
            fillColor: AppColors.bgLight,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text('Budget Goals', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.primary, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Set your targets to keep your budget and savings on track.',
                      style: TextStyle(fontSize: 12, color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _numberField(label: 'Monthly saving goal', hint: 'e.g. 200', controller: savingController, icon: Icons.savings_outlined),
            const SizedBox(height: 20),
            _numberField(label: 'Monthly expense limit', hint: 'e.g. 460', controller: expenseController, icon: Icons.trending_down),
            const SizedBox(height: 20),
            _numberField(label: 'Average weekly income', hint: 'e.g. 300', controller: averageController, icon: Icons.calendar_view_week),
            if (error != null) ...[
              const SizedBox(height: 12),
              Text(error!, style: TextStyle(color: AppColors.warning, fontSize: 12)),
            ],
            const SizedBox(height: 28),
            buildPrimaryButton(label: 'Save Goals', onPressed: _handleSave),
          ],
        ),
      ),
    );
  }
}
