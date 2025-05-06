import 'dart:math';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class CerditoConGlobo extends StatelessWidget {
  const CerditoConGlobo({super.key});

  final List<String> frases = const [
    "¿Otra vez arroz con huevo?",
    "Si ahorro más, ¿me convierto en millonario?",
    "Necesito tacos... ¡por razones económicas!",
    "Hoy es buen día para gastar… digo, ahorrar.",
    "¿Invertir en criptocerditos?",
    "La dieta comienza mañana… o nunca.",
    "¿Te parece que somos ricos?",
    "Humm huele chicharron... Sospechoso...",
    "Humm que podría comer hoy...",
    "¿Me regalas una moneda?",
    "Mi plan financiero: sobrevivir.",
    "¿Ahorrar o pedir pizza? ¡Difícil decisión!",
    "Mis metas: dormir, comer y no gastar.",
    "No soy gordito, ¡estoy financieramente inflado!",
    "Cada moneda cuenta… cuando es mía.",
    "¿Y si mejor me hago influencer financiero?",
    "Tengo más deudas que likes en Instagram.",
    "¿Dónde está mi beca por existir?",
    "¡El antojo no entiende de presupuesto!",
    "Hoy no gasto… mañana hablamos.",
    "¿Y si invierto en chocobananos?",
    "Sueño con un buffet… gratis.",
    "Gastar menos suena aburrido.",
    "Necesito un préstamo... ¡de abrazos!",
    "Mi billetera hace eco.",
    "¿Monedas? Pensé que eran chocolates.",
    "¡No estoy roto, estoy en modo ahorro!",
    "Solo quería ver si tenía algo… sigo pobre.",
    "Cero gastos... por accidente.",
    "¡Mi presupuesto llora en silencio!",
    "Entre ahorrar y Netflix... ganó Netflix.",
    "La inflación me persigue hasta en sueños.",
    "¿Tarjeta o efectivo? Mejor sueños.",
    "Solo gasto en cosas esenciales: memes y comida.",
    "¡Soy rico! En personalidad.",
    "¿Ahorro o me compro otro café?",
    "Mi cartera está a dieta.",
    "Plan financiero: no mirar la cuenta.",
    "¡Amo ahorrar! Pero amo más el delivery.",
    "Hoy iba a ahorrar, pero se me atravesó una pupusa.",
    "¿Dinero? Ah sí, tuve una vez.",
    "No tengo crisis… solo creatividad financiera.",
    "El dinero va y viene… el mío solo se va.",
    "Más barato que yo: imposible.",
    "Necesito estar gordito... ¡pero de monadas!",
    "El arte de desaparecer dinero...",
    "La vida es corta, ¡gastala! (Es broma)",
    "¿Ahorrar? ¿Que es eso?",
  ];

  @override
  Widget build(BuildContext context) {
    final random = Random();
    final fraseElegida = frases[random.nextInt(frases.length)];

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.topCenter,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 10),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: DefaultTextStyle(
                  style: const TextStyle(color: Colors.black, fontSize: 16),
                  child: AnimatedTextKit(
                    animatedTexts: [
                      TypewriterAnimatedText(
                        fraseElegida,
                        speed: Duration(milliseconds: 60),
                      ),
                    ],
                    totalRepeatCount: 1,
                    pause: Duration(milliseconds: 500),
                    displayFullTextOnTap: true,
                    stopPauseOnTap: true,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                child: ClipPath(
                  clipper: TriangleClipper(),
                  child: Container(width: 20, height: 10, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: 125,
            height: 125,
            child: Image.asset('assets/logo/cerdito_cool.png'),
          ),
        ],
      ),
    );
  }
}

class TriangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width / 2, size.height);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
