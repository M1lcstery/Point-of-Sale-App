import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String name;
  final double price;
  final int quantity;

  Product({
    required this.name,
    required this.price,
    required this.quantity,
  });
}

class ProductListWidget extends StatefulWidget {
  final String searchText;

  const ProductListWidget({Key? key, required this.searchText})
      : super(key: key);

  @override
  State<ProductListWidget> createState() => _ProductListWidgetState();
}

class _ProductListWidgetState extends State<ProductListWidget> {
  late Stream<QuerySnapshot> _productsStream;

  List<Product> _products = [];

  @override
  void initState() {
    super.initState();
    _productsStream =
        FirebaseFirestore.instance.collection("products").snapshots();
  }

  void addToCart(Product product) {
    int quantity = product.quantity;
    if (quantity > 0) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          int quantityToAdd = 0;
          return AlertDialog(
            title: const Text('Agregar al carrito'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('¿Cuántos productos te gustaria agregar?'),
                const SizedBox(height: 16),
                TextField(
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    quantityToAdd = int.tryParse(value) ?? 1;
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  int itemsToAdd = quantityToAdd;
                  if (quantityToAdd > quantity) {
                    itemsToAdd = quantity;
                  }
                  if (itemsToAdd > 0) {
                    FirebaseFirestore.instance
                        .collection('products')
                        .doc(product.name)
                        .update({'quantity': quantity - itemsToAdd});
                    FirebaseFirestore.instance
                        .collection('cart')
                        .get()
                        .then((querySnapshot) {
                      if (querySnapshot.size == 0) {
                        FirebaseFirestore.instance
                            .collection('cart')
                            .doc(product.name)
                            .set({
                          'name': product.name,
                          'price': product.price,
                          'quantity': itemsToAdd,
                        });
                      } else {
                        FirebaseFirestore.instance
                            .collection('cart')
                            .where('name', isEqualTo: product.name)
                            .limit(1)
                            .get()
                            .then((querySnapshot) {
                          if (querySnapshot.size == 1) {
                            String itemId = querySnapshot.docs[0].id;
                            FirebaseFirestore.instance
                                .collection('cart')
                                .doc(itemId)
                                .update({
                              'quantity': FieldValue.increment(itemsToAdd)
                            });
                          } else {
                            FirebaseFirestore.instance.collection('cart').add({
                              'name': product.name,
                              'price': product.price,
                              'quantity': itemsToAdd,
                            });
                          }
                        });
                      }
                    });
                  }

                  Navigator.of(context).pop();
                },
                child: const Text('Agregar al carrito'),
              ),
            ],
          );
        },
      );
    } else {
      return;
    }
  }

  List<Product> filterProducts() {
    if (widget.searchText.isEmpty) {
      return _products;
    } else {
      return _products
          .where((product) => product.name
              .toLowerCase()
              .contains(widget.searchText.toLowerCase()))
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _productsStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Algo salió mal.'));
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else {
          final List<DocumentSnapshot> documents = snapshot.data!.docs;
          _products = documents
              .map((doc) => Product(
                    name: doc['name'],
                    price: doc['price'].toDouble(),
                    quantity: doc['quantity'],
                  ))
              .toList();
          final filteredProducts = filterProducts();
          return ListView.builder(
            itemCount: filteredProducts.length,
            itemBuilder: (BuildContext context, int index) {
              final product = filteredProducts[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 1.0),
                child: Card(
                  elevation: 4.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: ListTile(
                          title: Text(product.name),
                          subtitle: Text(
                            'Precio: \$${product.price}',
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(context).canvasColor,
                            child: Text(
                              product.quantity.toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_shopping_cart_outlined),
                        onPressed: () {
                          addToCart(product);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }
}
