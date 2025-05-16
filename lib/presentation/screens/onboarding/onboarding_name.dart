import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:myapp/utils/db/db_name.dart';
import 'package:myapp/presentation/screens/onboarding/onboarding_initial_balance.dart';

// Widget de estado para ingresar el nombre del usuario
class NameScreen extends StatefulWidget {
  const NameScreen({super.key});

  @override
  State<NameScreen> createState() => _NameScreenState();
}

class _NameScreenState extends State<NameScreen> {
  final TextEditingController _nameController = TextEditingController(); // Controlador del campo de texto
  bool _isButtonEnabled = false; // Controla si el botón "Continuar" está habilitado

  // Guarda el nombre en la base de datos y navega a la siguiente pantalla
  Future<void> _saveNameAndNavigate() async {
    await db.saveName(_nameController.text);

    if (!mounted) return; // Verifica que el widget esté aún montado
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const BalanceScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // Evita que el teclado cubra la vista
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

              // Texto animado con efecto de máquina de escribir
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

              // Campo de texto para ingresar el nombre
              TextField(
                controller: _nameController,
                maxLength: 12, // Longitud máxima del nombre
                cursorColor: Theme.of(context).textTheme.bodyLarge?.color,
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontWeight: FontWeight.bold,
                ),
                onChanged: (value) {
                  // Activa o desactiva el botón dependiendo si hay texto
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

              // Botón "Continuar"
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
