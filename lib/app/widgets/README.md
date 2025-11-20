# Widgets

## Purpose
This folder contains reusable custom widgets that are used across multiple views in the application.

Widgets are modular UI components that encapsulate specific functionality and can be composed together.

## Structure
```
widgets/
├── common/
│   ├── custom_button.dart
│   ├── custom_text_field.dart
│   ├── loading_indicator.dart
│   ├── empty_state.dart
│   └── error_widget.dart
├── cards/
│   ├── workout_card.dart
│   ├── exercise_card.dart
│   ├── nutrition_card.dart
│   └── stat_card.dart
├── charts/
│   ├── progress_chart.dart
│   ├── calorie_chart.dart
│   └── weight_chart.dart
└── dialogs/
    ├── confirmation_dialog.dart
    └── input_dialog.dart
```

## Example Usage

### Custom Button Widget
```dart
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final double? width;
  
  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.width,
  });
  
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? Theme.of(context).primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}
```

### Custom Text Field Widget
```dart
class CustomTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  
  const CustomTextField({
    super.key,
    required this.label,
    this.hint,
    required this.controller,
    this.validator,
    this.obscureText = false,
    this.keyboardType,
    this.prefixIcon,
    this.suffixIcon,
  });
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          obscureText: obscureText,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }
}
```

### Workout Card Widget
```dart
class WorkoutCard extends StatelessWidget {
  final WorkoutModel workout;
  final VoidCallback? onTap;
  
  const WorkoutCard({
    super.key,
    required this.workout,
    this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.fitness_center,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      workout.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${workout.duration} min • ${workout.exercises.length} exercises',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

## Usage in Views

```dart
class LoginView extends GetView<LoginController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CustomTextField(
              label: 'Email',
              hint: 'Enter your email',
              controller: controller.emailController,
              validator: Validators.email,
              keyboardType: TextInputType.emailAddress,
              prefixIcon: const Icon(Icons.email),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Password',
              hint: 'Enter your password',
              controller: controller.passwordController,
              validator: Validators.password,
              obscureText: true,
              prefixIcon: const Icon(Icons.lock),
            ),
            const SizedBox(height: 24),
            Obx(() => CustomButton(
              text: 'Login',
              onPressed: controller.login,
              isLoading: controller.isLoading.value,
            )),
          ],
        ),
      ),
    );
  }
}
```

## Best Practices
- Make widgets reusable and configurable
- Use `const` constructors when possible
- Accept callbacks for user interactions
- Provide sensible defaults for optional parameters
- Keep widgets focused on single responsibility
- Use composition over inheritance
- Add documentation comments
- Follow Material Design guidelines
- Make widgets themeable (use Theme.of(context))
- Test widgets independently
