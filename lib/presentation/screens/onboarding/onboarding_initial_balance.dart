import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:myapp/utils/db/db_helper_transactions.dart';
import 'package:myapp/utils/config/max_amount.dart';
import 'package:myapp/presentation/screens/onboarding/onboarding_end.dart';

class BalanceScreen extends StatefulWidget {
  const BalanceScreen({super.key});

  @override
  State<BalanceScreen> createState() => _BalanceScreenState();
}

class _BalanceScreenState extends State<BalanceScreen> {
  final TextEditingController _balanceController = TextEditingController();
  bool _isButtonEnabled = false;

  Future<void> _saveBalanceAndNavigate() async {
    final text = _balanceController.text.trim();
    if (text.isEmpty) return;

    final double? balance = double.tryParse(text);
    if (balance == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor, ingresa un balance válido.'),
          ),
        );
      }
      return;
    }

    if (balance >= 0.01) {
      final DateTime now = DateTime.now();
      final String formattedDate =
          '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';

      final String description = 'Saldo inicial de la app';
      await TransactionDB().addTransaction(
        balance,
        'Balance inicial',
        formattedDate,
        'ingresos',
        description,
      );
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seenOnboarding', true);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OnboardingPageEnd()),
      );
    }
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
              const Icon(Icons.money, color: Colors.yellow, size: 50),
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
                      'Porky es muy curioso,\n¿Cuál será tu balance inicial?',
                      speed: Duration(milliseconds: 65),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: _balanceController,
                maxLength: 10,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
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
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                  MaxAmountFormatter(),
                ],
                decoration: InputDecoration(
                  hintText: 'Escribe tu balance inicial',
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
                  prefixIcon: Icon(
                    Icons.attach_money,
                    color:
                        _isButtonEnabled
                            ? Theme.of(context).textTheme.bodyLarge?.color
                            : Theme.of(context).textTheme.bodyLarge?.color
                                ?.withValues(alpha: 0.6),
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
                  onPressed: _isButtonEnabled ? _saveBalanceAndNavigate : null,
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
