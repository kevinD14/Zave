import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:myapp/utils/db/db_helper_transactions.dart';
import 'package:myapp/utils/config/format_dates.dart';
import 'package:myapp/presentation/screens/transactions_all/details/transaction_detail_screen.dart';

// Pantalla principal que muestra todas las transacciones registradas
class AllTransactionsPage extends StatefulWidget {
  const AllTransactionsPage({super.key});

  @override
  State<AllTransactionsPage> createState() => _AllTransactionsPageState();
}

// Estado asociado a la pantalla de todas las transacciones
class _AllTransactionsPageState extends State<AllTransactionsPage> {
  // Futuro que contendrá la lista de transacciones obtenidas de la base de datos
  late Future<List<Map<String, dynamic>>> _transactionsFuture;

  @override
  void initState() {
    // Se llama cuando el widget se inserta en el árbol de widgets

    super.initState();
    _loadTransactions();
  }

  // Carga todas las transacciones desde la base de datos y las asigna al futuro
  void _loadTransactions() {
    _transactionsFuture = TransactionDB().getAllTransactions();
  }

  @override
  Widget build(BuildContext context) {
    // Construye la interfaz de usuario de la pantalla

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      // Barra superior de la aplicación
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: const Text(
          'Transacciones',
          style: TextStyle(color: Colors.white),
        ),
      ),
      // Contenido principal de la pantalla, muestra las transacciones usando FutureBuilder
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _transactionsFuture,
        builder: (context, snapshot) {
          // Manejo de los diferentes estados del Future
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Mientras se cargan los datos, muestra un indicador de progreso
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Si ocurre un error al cargar los datos
            return const Center(child: Text('Error cargando transacciones'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            // Si no hay datos, muestra un mensaje informativo
            return Center(
              child: Text(
                'No hay transacciones aún',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }

          // Obtiene la lista de transacciones desde el snapshot
          final transactions = List<Map<String, dynamic>>.from(snapshot.data!);

          // Ordena las transacciones por fecha (descendente) y por id si la fecha es igual
          transactions.sort((a, b) {
            final dateA = DateFormat('dd/MM/yyyy').parse(a['date']);
            final dateB = DateFormat('dd/MM/yyyy').parse(b['date']);

            if (dateA.isAtSameMomentAs(dateB)) {
              return (b['id'] as int).compareTo(a['id'] as int);
            } else {
              return dateB.compareTo(dateA);
            }
          });

          // Agrupa las transacciones por fecha
          Map<String, List<Map<String, dynamic>>> groupedTransactions = {};
          for (var transaction in transactions) {
            final date = transaction['date'] ?? '';
            groupedTransactions.putIfAbsent(date, () => []).add(transaction);
          }

          // Obtiene la lista de fechas ordenadas (descendente)
          final sortedDates =
              groupedTransactions.keys.toList()..sort((a, b) {
                final dateA = DateFormat('dd/MM/yyyy').parse(a);
                final dateB = DateFormat('dd/MM/yyyy').parse(b);
                return dateB.compareTo(dateA);
              });

          // Construye la lista de transacciones agrupadas por fecha
          return ListView.builder(
            itemCount: sortedDates.length,
            itemBuilder: (context, index) {
              final date = sortedDates[index];
              final dailyTransactions = groupedTransactions[date]!;

              // Por cada fecha, muestra la cabecera y la lista de transacciones de ese día
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Cabecera con la fecha formateada
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22.0,
                        vertical: 4.0,
                      ),
                      child: Text(
                        formatDate(date),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white.withAlpha(150),
                        ),
                      ),
                    ),
                    // Lista de transacciones del día
                    ...dailyTransactions.map((transaction) {
                      final double amount =
                          (transaction['amount'] as num?)?.toDouble() ?? 0.0;
                      final String category =
                          transaction['category'] ?? 'Sin categoría';
                      final String type = transaction['type'] ?? 'otros';

                      return GestureDetector(
                        // Al tocar la transacción, navega a la pantalla de detalle
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => TransactionDetailScreen(
                                    transaction: transaction,
                                  ),
                            ),
                          );
                        },
                        child: ListTile(
                          // Icono según el tipo de transacción
                          leading: SvgPicture.asset(
                            type == 'ingresos'
                                ? 'assets/icons/payments.svg'
                                : type == 'gastos'
                                ? 'assets/icons/pay.svg'
                                : 'assets/icons/debt.svg',
                            width: 40,
                            height: 40,
                            colorFilter: const ColorFilter.mode(
                              Colors.white,
                              BlendMode.srcIn,
                            ),
                          ),
                          // Título según el tipo de transacción
                          title: Text(
                            type == 'ingresos'
                                ? 'Ingresos'
                                : type == 'gastos'
                                ? 'Gastos'
                                : 'Deuda',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          // Categoría de la transacción
                          subtitle: Text(
                            category,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withAlpha(220),
                            ),
                          ),
                          // Monto de la transacción, con signo según tipo
                          trailing: Text(
                            '${type == 'ingresos' ? '+' : '-'}\$${amount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
