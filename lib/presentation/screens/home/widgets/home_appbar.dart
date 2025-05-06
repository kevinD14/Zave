import 'dart:async';
import 'package:flutter/material.dart';
import 'package:myapp/utils/db/db_name.dart';
import 'package:myapp/utils/db/db_helper_transactions.dart';
import 'package:myapp/utils/config/event_bus.dart';

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

  @override
  void initState() {
    super.initState();
    _loadData();

    _nombreSubscription = EventBus().onUsernameUpdated.listen((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _nombreSubscription.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    final name = await db.getName();
    final transactions = await TransactionDB().getAllTransactions();

    double balance = 0.0;
    for (var tx in transactions) {
      final amount = tx['amount'] as double;
      final type = tx['type'] as String;
      balance += (type == 'ingresos') ? amount : -amount;
    }

    setState(() {
      _userName = _shortenName(name);
      _balance = balance;
    });
  }

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
