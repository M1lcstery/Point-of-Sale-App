// ignore_for_file: depend_on_referenced_packages

import 'dart:io';

import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;

class Product {
  final String name;
  final double price;
  final int quantity;

  Product({required this.name, required this.price, required this.quantity});
}

class CartView extends StatefulWidget {
  const CartView({Key? key}) : super(key: key);

  @override
  State<CartView> createState() => _CartViewState();
}

class _CartViewState extends State<CartView> {
  late Stream<QuerySnapshot> _cartProductsStream;
  bool _includeIVA =
      true; // New variable to track whether to include IVA or not

  List<Product> _products = [];

  @override
  void initState() {
    super.initState();
    _cartProductsStream =
        FirebaseFirestore.instance.collection("cart").snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canvasColor = theme.canvasColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Carrito"),
        backgroundColor: canvasColor,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _cartProductsStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Algo salió mal'));
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            final List<DocumentSnapshot> documents = snapshot.data!.docs;
            _products = documents
                .map(
                  (doc) => Product(
                    name: doc['name'],
                    price: doc['price'].toDouble(),
                    quantity: doc['quantity'],
                  ),
                )
                .toList();
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: _products.length,
                    itemBuilder: (BuildContext context, int index) {
                      final product = _products[index];
                      final unitaryPrice = product.price;
                      final totalPrice = unitaryPrice * product.quantity;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Card(
                          elevation: 4.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6.0),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: canvasColor,
                              child: Text(
                                product.quantity.toString(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            title: Text(product.name),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Precio Unitario: \$${unitaryPrice.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Text(
                                  'Total: \$${totalPrice.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(
                                  Icons.remove_shopping_cart_outlined),
                              onPressed: () {
                                // Remove item from cart collection
                                _removeProduct(product);
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      // Perform checkout logic
                      _checkout();
                    },
                    child: const Text('Checkout'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: canvasColor,
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Subtotal: \$${_calculateSubtotal().toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        if (_includeIVA)
                          Text(
                            'IVA (21%): \$${_calculateIVA().toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 16.0,
                              color: Colors.white,
                            ),
                          ),
                        const Divider(color: Colors.white),
                        Text(
                          'Total: \$${_calculateTotal().toStringAsFixed(2)}${_includeIVA ? " (IVA incluido)" : ""}',
                          style: const TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Text(
                              'Incluir IVA',
                              style: TextStyle(color: Colors.white),
                            ),
                            Switch(
                              value: _includeIVA,
                              onChanged: (value) {
                                setState(() {
                                  _includeIVA = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  double _calculateSubtotal() {
    double subtotal = 0;
    for (var product in _products) {
      subtotal += product.price * product.quantity;
    }
    return subtotal;
  }

  double _calculateIVA() {
    double subtotal = _calculateSubtotal();
    return subtotal * 0.21;
  }

  double _calculateTotal() {
    double subtotal = _calculateSubtotal();
    double iva = _calculateIVA();
    return _includeIVA ? subtotal + iva : subtotal;
  }

  void _removeProduct(Product product) {
    // Remove item from cart collection
    FirebaseFirestore.instance
        .collection('cart')
        .where('name', isEqualTo: product.name)
        .limit(1)
        .get()
        .then((querySnapshot) {
      if (querySnapshot.size == 1) {
        String itemId = querySnapshot.docs[0].id;
        FirebaseFirestore.instance.collection('cart').doc(itemId).delete();
      }
    });

    // Update product quantity in products collection
    FirebaseFirestore.instance
        .collection('products')
        .where('name', isEqualTo: product.name)
        .limit(1)
        .get()
        .then((querySnapshot) {
      if (querySnapshot.size == 1) {
        String itemId = querySnapshot.docs[0].id;
        FirebaseFirestore.instance
            .collection('products')
            .doc(itemId)
            .update({'quantity': FieldValue.increment(product.quantity)});
      }
    });
  }

  void _checkout() {
    // Get the current timestamp for the checkout time
    DateTime checkoutTime = DateTime.now();

    // Create a new collection to store the checkout details
    CollectionReference checkoutCollection =
        FirebaseFirestore.instance.collection('checkouts');

    // Create a new document in the checkout collection
    DocumentReference checkoutDocRef = checkoutCollection.doc();

    // Create a new sub-collection for cart items within the checkout document
    CollectionReference cartItemsCollection =
        checkoutDocRef.collection('cartItems');

    double subtotal = _calculateSubtotal();
    double iva = _calculateIVA();
    double total = _calculateTotal();

    // Get the cart products
    FirebaseFirestore.instance.collection('cart').get().then((querySnapshot) {
      // Process the cart data
      if (querySnapshot.size > 0) {
        // Cart has items, perform checkout logic

        List<Product> cartProducts = [];

        // Iterate over the cart items and add them to the sub-collection
        for (var doc in querySnapshot.docs) {
          var cartItem = doc.data(); // Retrieve the cart item data

          // Create a Product object from the cart item data
          Product product = Product(
            name: cartItem['name'],
            price: cartItem['price'],
            quantity: cartItem['quantity'],
          );

          cartProducts.add(product);

          // Add the cart item to the sub-collection
          cartItemsCollection
              .add({
                'name': cartItem['name'],
                'price': cartItem['price'],
                'quantity': cartItem['quantity'],
              })
              .then((newCartItemDoc) {})
              .catchError((error) {});

          // Remove the cart item after successful checkout
          doc.reference.delete();
        }

        // Add checkout details and totals to the checkout document
        checkoutDocRef.set({
          'checkoutTime': checkoutTime,
          'subtotal': subtotal,
          'iva': iva,
          'total': total,
        }).then((_) {
          // Generate the PDF receipt
          generatePDFReceipt(subtotal, iva, total, checkoutTime, cartProducts,
              checkoutDocRef.id);

          Navigator.pop(context); // Close the cart view
        }).catchError((error) {});
      }
    });
  }

  Future<void> generatePDFReceipt(
    double subtotal,
    double iva,
    double total,
    DateTime checkoutTime,
    List<Product> products,
    String checkoutId,
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Container(
            margin: const pw.EdgeInsets.all(40),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Recibo',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  'Fecha y hora del checkout: ${DateFormat('dd/MM/yyyy HH:mm').format(checkoutTime)}',
                ),
                pw.SizedBox(height: 20),
                pw.Text('Productos:'),
                pw.ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (pw.Context context, int index) {
                    final product = products[index];
                    final unitaryPrice = product.price;
                    final totalPrice = unitaryPrice * product.quantity;

                    return pw.Container(
                      margin: const pw.EdgeInsets.symmetric(vertical: 4.0),
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            product.name,
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                          pw.Text(
                            'Cantidad: ${product.quantity}',
                          ),
                          pw.Text(
                            'Precio Unitario: \$${unitaryPrice.toStringAsFixed(2)}',
                          ),
                          pw.Text(
                            'Total: \$${totalPrice.toStringAsFixed(2)}',
                          ),
                        ],
                      ),
                    );
                  },
                ),
                pw.Divider(),
                pw.Container(
                  margin: const pw.EdgeInsets.only(top: 8.0),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.end,
                    children: [
                      pw.Text(
                        'Subtotal: \$${subtotal.toStringAsFixed(2)}',
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_includeIVA)
                  pw.Container(
                    margin: const pw.EdgeInsets.only(top: 8.0),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.end,
                      children: [
                        pw.Text(
                          'IVA (21%): \$${iva.toStringAsFixed(2)}',
                          style: const pw.TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                pw.Container(
                  margin: const pw.EdgeInsets.only(top: 8.0),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.end,
                    children: [
                      pw.Text(
                        'Total: \$${total.toStringAsFixed(2)}${_includeIVA ? " (IVA incluido)" : ""}',
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    // Get the external storage directory
    final directory = await getExternalStorageDirectory();

    // Save the PDF file to external storage
    final outputFile = File('${directory!.path}/receipt_$checkoutId.pdf');
    await outputFile.writeAsBytes(await pdf.save());
  }
}
