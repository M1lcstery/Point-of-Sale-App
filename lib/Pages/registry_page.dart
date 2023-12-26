// ignore_for_file: library_private_types_in_public_api

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Checkout {
  final String id;
  final DateTime checkoutTime;
  final List<CartItem> cartItems;
  final double subtotal;
  final double iva;
  final double total;

  Checkout({
    required this.id,
    required this.checkoutTime,
    required this.cartItems,
    required this.subtotal,
    required this.iva,
    required this.total,
  });
}

class CartItem {
  final String name;
  final double price;
  final int quantity;

  CartItem({
    required this.name,
    required this.price,
    required this.quantity,
  });
}

class CheckoutsScreen extends StatefulWidget {
  const CheckoutsScreen({Key? key}) : super(key: key);

  @override
  _CheckoutsScreenState createState() => _CheckoutsScreenState();
}

class _CheckoutsScreenState extends State<CheckoutsScreen> {
  DateTime? selectedDate;

  Future<void> _openPDFReceipt(String checkoutId) async {
    final String pdfPath = await _getPDFPath(checkoutId);
    if (pdfPath.isNotEmpty) {
      try {
        await OpenFile.open(pdfPath);
      } catch (e) {
        print('Error opening PDF: $e');
      }
    }
  }

  Future<String> _getPDFPath(String checkoutId) async {
    try {
      final Directory? directory = await getExternalStorageDirectory();
      if (directory != null) {
        final String path = '${directory.path}/receipt_$checkoutId.pdf';
        final bool exists = await File(path).exists();
        if (exists) {
          return path;
        }
      }
    } catch (e) {
      print('Error getting PDF path: $e');
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Divider(height: 1.0),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('checkouts')
                  .orderBy('checkoutTime', descending: true)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text('Algo salió mal.'),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasData && snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('No hay checkouts disponibles'),
                  );
                }

                final List<DocumentSnapshot> documents = snapshot.data!.docs;
                List<Checkout> checkouts = documents.map((doc) {
                  final List<CartItem> cartItems = [];

                  doc.reference.collection('cartItems').get().then((snapshot) {
                    for (var itemDoc in snapshot.docs) {
                      final Map<String, dynamic> data = itemDoc.data();
                      final CartItem cartItem = CartItem(
                        name: data['name'] ?? '',
                        price: data['price']?.toDouble() ?? 0.0,
                        quantity: data['quantity'] ?? 0,
                      );
                      cartItems.add(cartItem);
                    }
                  });

                  return Checkout(
                    id: doc.id,
                    checkoutTime: doc['checkoutTime'].toDate(),
                    cartItems: cartItems,
                    subtotal: doc['subtotal']?.toDouble() ?? 0.0,
                    iva: doc['iva']?.toDouble() ?? 0.0,
                    total: doc['total']?.toDouble() ?? 0.0,
                  );
                }).toList();

                if (selectedDate != null) {
                  checkouts = checkouts.where((checkout) {
                    final checkoutDate = DateTime(
                      checkout.checkoutTime.year,
                      checkout.checkoutTime.month,
                      checkout.checkoutTime.day,
                    );
                    final selectedDateOnly = DateTime(
                      selectedDate!.year,
                      selectedDate!.month,
                      selectedDate!.day,
                    );
                    return checkoutDate == selectedDateOnly;
                  }).toList();
                }

                return ListView.builder(
                  itemCount: checkouts.length,
                  itemBuilder: (BuildContext context, int index) {
                    final Checkout checkout = checkouts[index];

                    return ListTile(
                      title: Text('ID: ${checkout.id}'),
                      subtitle: Text(
                          'Fecha y Hora: ${checkout.checkoutTime.toLocal().toString().split('.')[0]}'),
                      trailing: ElevatedButton(
                        child: const Icon(Icons.receipt),
                        onPressed: () {
                          _openPDFReceipt(checkout.id);
                        },
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                CheckoutDetailsScreen(checkout: checkout),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      appBar: AppBar(
        title: const Text('Registro de Operaciones'),
        backgroundColor: Colors.grey[300],
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showDatePicker(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              setState(() {
                selectedDate = null;
              });
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showDatePicker(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2025),
      locale: const Locale('es', 'ES'),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }
}

class CheckoutDetailsScreen extends StatelessWidget {
  final Checkout checkout;

  const CheckoutDetailsScreen({Key? key, required this.checkout})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles'),
        backgroundColor: theme.canvasColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ID del Checkout: ${checkout.id}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
              ),
            ),
            const SizedBox(height: 16.0),
            Text(
              'Fecha y Hora del Checkout: ${checkout.checkoutTime.toLocal().toString().split('.')[0]}',
              style: TextStyle(
                fontSize: 16.0,
                color: theme.primaryColor,
              ),
            ),
            const Divider(height: 32.0),
            const Text(
              'Productos del Carrito:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
            const SizedBox(height: 16.0),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: checkout.cartItems.length,
              itemBuilder: (BuildContext context, int index) {
                final CartItem cartItem = checkout.cartItems[index];
                return ListTile(
                  title: Text(cartItem.name),
                  subtitle: Text('Cantidad: ${cartItem.quantity}'),
                  trailing: Text('\$${cartItem.price.toStringAsFixed(2)}'),
                );
              },
            ),
            const Divider(height: 32.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Subtotal:',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '\$${checkout.subtotal.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'IVA:',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '\$${checkout.iva.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total:',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '\$${checkout.total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
