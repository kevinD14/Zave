import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:myapp/utils/db/db_name.dart';
import 'package:myapp/presentation/screens/onboarding/onboarding_initial_balance.dart';

class NameScreen extends StatefulWidget {
  const NameScreen({super.key});

  @override
  State<NameScreen> createState() => _NameScreenState();
}

class _NameScreenState extends State<NameScreen> {
  final TextEditingController _nameController = TextEditingController();
  bool _isButtonEnabled = false;

  Future<void> _saveNameAndNavigate() async {
    await db.saveName(_nameController.text);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const BalanceScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Theme.of(context).primaryColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Icon(
                Icons.question_mark,
                color: Theme.of(context).colorScheme.tertiary,
                size: 50,
              ),
              const SizedBox(height: 10),
              Image.asset(
                'assets/logo/cerdito_feliz.png',
                height: 150,
                width: 150,
              ),
              const SizedBox(height: 30),
              DefaultTextStyle(
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                child: AnimatedTextKit(
                  isRepeatingAnimation: false,
                  animatedTexts: [
                    TypewriterAnimatedText(
                      'Porky quiere saber más de ti,\ncuéntanos, ¿Cuál es tu nombre?',
                      speed: Duration(milliseconds: 65),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: _nameController,
                maxLength: 12,
                cursorColor: Theme.of(context).textTheme.bodyLarge?.color,
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontWeight: FontWeight.bold,
                ),
                onChanged: (value) {
                  setState(() {
                    _isButtonEnabled = value.trim().isNotEmpty;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Escribe tu nombre',
                  counterText: '',
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.secondary,
                  hintStyle: TextStyle(
                    color: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.color?.withValues(alpha: 0.6),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _isButtonEnabled
                            ? Theme.of(context).colorScheme.tertiary
                            : Colors.grey.shade400,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: _isButtonEnabled ? _saveNameAndNavigate : null,
                  child: Text(
                    'Continuar',
                    style: TextStyle(
                      color:
                          _isButtonEnabled
                              ? Colors.black
                              : Colors.grey.shade400.withValues(alpha: 150),
                      fontSize: 24,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}
