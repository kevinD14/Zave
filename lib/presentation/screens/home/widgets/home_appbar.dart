import 'dart:async';
import 'package:flutter/material.dart';
import 'package:myapp/utils/db/db_name.dart';
import 'package:myapp/utils/db/db_helper_transactions.dart';
import 'package:myapp/utils/config/event_bus.dart';

// Widget personalizado que representa una AppBar con saludo
class CustomHomeAppBar extends StatefulWidget implements PreferredSizeWidget {
  const CustomHomeAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(120);

  @override
  State<CustomHomeAppBar> createState() => _CustomHomeAppBarState();
}

class _CustomHomeAppBarState extends State<CustomHomeAppBar> {
  late String _userName = '';
  late double _balance = 0.0;
  late final StreamSubscription _nombreSubscription;
  late final StreamSubscription _transaccionesSubscription;

  @override
  void initState() {
    super.initState();

    // Carga los datos del usuario y balance al iniciar
    _loadData();

    // Escucha eventos de actualización del nombre y vuelve a cargar datos
    _nombreSubscription = EventBus().onUsernameUpdated.listen((_) {
      _loadData();
    });

    _transaccionesSubscription = EventBus().onTransactionsUpdated.listen((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    // Cancela la subscripción para evitar fugas de memoria
    _nombreSubscription.cancel();
    _transaccionesSubscription.cancel();
    super.dispose();
  }

  // Carga el nombre del usuario y calcula el balance a partir de las transacciones
  Future<void> _loadData() async {
    final name = await db.getName(); // Obtiene nombre desde la base de datos
    final transactions = await TransactionDB().getAllTransactions(); // Obtiene todas las transacciones

    // Calcula el balance sumando ingresos y restando egresos
    double balance = 0.0;
    for (var tx in transactions) {
      final amount = tx['amount'] as double;
      final type = tx['type'] as String;
      balance += (type == 'ingresos') ? amount : -amount;
    }

    // Actualiza el estado del widget con los nuevos datos
    setState(() {
      _userName = _shortenName(name);
      _balance = balance;
    });
  }

  // Acorta el nombre si es muy largo (más de 8 caracteres)
  String _shortenName(String name) {
    return (name.length > 8) ? '${name.substring(0, 8)}...' : name;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).appBarTheme.backgroundColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Hola, ',
                      style: TextStyle(
                        color:
                            Theme.of(context).appBarTheme.titleTextStyle?.color,
                        fontSize: 28,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    TextSpan(
                      text: _userName,
                      style: TextStyle(
                        color:
                            Theme.of(context).appBarTheme.titleTextStyle?.color,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Imagen del cerdito feliz o triste dependiendo del balance
              ClipRRect(
                child: Image.asset(
                  _balance < 0
                      ? 'assets/logo/cerdito_triste.png'
                      : 'assets/logo/cerdito_feliz_brillo.png',
                  width: 110,
                  height: 110,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
