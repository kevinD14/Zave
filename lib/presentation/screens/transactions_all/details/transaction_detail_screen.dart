import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:myapp/utils/extras/transaction_utils.dart';
import 'package:myapp/utils/config/format_dates.dart';
import 'package:myapp/presentation/screens/transactions_all/details/edit_transaction_screen.dart';

/// Pantalla que muestra el detalle de una transacción específica.
class TransactionDetailScreen extends StatelessWidget {
  /// Mapa con los datos de la transacción a mostrar.
  final Map<String, dynamic> transaction;

  /// Constructor que recibe la transacción a detallar.
  const TransactionDetailScreen({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    // Extrae los datos principales de la transacción para mostrarlos en la UI.
    final double amount = (transaction['amount'] as num).toDouble();
    final String category = transaction['category'] ?? 'Sin categoría';
    final String type = transaction['type'] ?? 'otros';
    final String date = transaction['date'] ?? 'Fecha desconocida';
    final String? description = transaction['description'];

    return Scaffold(
      // Estructura principal de la pantalla con AppBar y contenido.
      appBar: AppBar(
        title: const Text('Transacción'),
        actions: [
          // Botón de eliminar transacción.
          IconButton(
            icon: SvgPicture.asset(
              'assets/icons/trash.svg',
              height: 28,
              width: 28,
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
            ),
            onPressed: () {
              // Llama a la función de confirmación de borrado.
              confirmDeleteTransaction(context, transaction);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        // Columna principal con los detalles de la transacción.
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),
            Align(
              alignment: Alignment.topLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Ícono según el tipo de transacción.
                  SvgPicture.asset(
                    type == 'ingresos'
                        ? 'assets/icons/payments.svg'
                        : type == 'gastos'
                        ? 'assets/icons/pay.svg'
                        : 'assets/icons/debt.svg',
                    height: 50,
                    width: 50,
                  ),
                  const SizedBox(width: 8),
                  // Título de la sección.
                  Text(
                    'Detalles ${_transactionLabel(type)}',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 26),
            Container(
              width: MediaQuery.of(context).size.width * 0.92,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(12),
              ),
              // Contenedor con los datos detallados de la transacción.
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Fila con la fecha de la transacción.
                  _buildInfoRow(
                    Icons.calendar_today,
                    'Fecha: ',
                    formatDate(date),
                    context,
                  ),
                  const SizedBox(height: 12),
                  // Fila con la categoría.
                  _buildInfoRow(Icons.label, 'Categoría: ', category, context),
                  const SizedBox(height: 12),
                  // Fila con el monto de la transacción.
                  _buildInfoRow(
                    Icons.attach_money,
                    'Monto: ',
                    '\$${amount.toStringAsFixed(2)}',
                    context,
                  ),
                  const SizedBox(height: 12),
                  // Si hay descripción, la muestra con su ícono y formato.
                  if (description != null && description.trim().isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.message,
                              color: Theme.of(
                                context,
                              ).textTheme.bodyLarge?.color,
                              size: 22,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Descripción:',
                              style: TextStyle(
                                fontSize: 18,
                                color: Theme.of(
                                  context,
                                ).textTheme.bodyLarge?.color,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          description,
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      // Muestra botón de editar solo si no es una deuda.
      floatingActionButton: transaction['type'] != 'deuda'
          ? FloatingActionButton.extended(
              onPressed: () {
                // Navega a la pantalla de edición de transacción.
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        EditTransactionScreen(transaction: transaction),
                  ),
                );
              },
              icon: const Icon(Icons.edit),
              label: const Text('Editar'),
              backgroundColor: Theme.of(context).colorScheme.tertiary,
              foregroundColor: Colors.black,
            )
          : null,
    );
  }

  /// Construye una fila de información con ícono, etiqueta y valor.
  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value,
    BuildContext context,
  ) {
    return Row(
      // Fila horizontal con ícono y texto.
      children: [
        Icon(
          icon,
          color: Theme.of(context).textTheme.bodyLarge?.color,
          size: 22,
        ),
        const SizedBox(width: 8),
        RichText(
          text: TextSpan(
            style: const TextStyle(fontSize: 18),
            children: [
              TextSpan(
                text: label,
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              TextSpan(
                text: value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Devuelve la etiqueta adecuada según el tipo de transacción.
  String _transactionLabel(String type) {
    switch (type) {
      case 'ingresos':
        return 'del ingreso';
      case 'gastos':
        return 'del gasto';
      case 'deuda':
        return 'de la deuda';
      default:
        return 'de la transacción';
    }
  }
}
