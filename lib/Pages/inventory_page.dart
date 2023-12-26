// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_pos_revised/Widgets/Sales/product_searchbar.dart';

class Product {
  final String name;
  double price;
  int quantity;

  Product({required this.name, required this.price, required this.quantity});
}

class InventoryPage extends StatefulWidget {
  const InventoryPage({Key? key}) : super(key: key);

  @override
  _InventoryPageState createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  final CollectionReference productsRef =
      FirebaseFirestore.instance.collection('products');

  late List<Product> allProducts;
  late List<Product> displayedProducts;

  @override
  void initState() {
    super.initState();
    allProducts = [];
    displayedProducts = [];
    fetchProducts();
  }

  void fetchProducts() async {
    final snapshot = await productsRef.get();
    final products = snapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      double price =
          double.parse(data['price'].toString().replaceAll(',', '.'));
      return Product(
        name: data['name'],
        price: price,
        quantity: data['quantity'],
      );
    }).toList();

    setState(() {
      allProducts = products;
      displayedProducts = products;
    });
  }

  void onSearchTextChanged(String searchText) {
    setState(() {
      displayedProducts = allProducts
          .where((product) =>
              product.name.toLowerCase().contains(searchText.toLowerCase()))
          .toList();
    });
  }

  void _showPriceUpdateDialog(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (context) {
        bool isFlatIncrease = true;
        bool isIncreasing = true;
        TextEditingController amountController = TextEditingController();

        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: const Text('Actualizar Precios'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: amountController,
                  decoration: const InputDecoration(
                    hintText: 'Monto del cambio',
                    hintStyle: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(
                    height:
                        16), // Spacing between the text field and the switch
                InkWell(
                  onTap: () {
                    setState(() {
                      isIncreasing = !isIncreasing;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: isIncreasing ? Colors.red : Colors.blue,
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Center(
                      child: Text(
                        isIncreasing ? 'Aumentar' : 'Disminuir',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                    height:
                        16), // Spacing between the switch and the "Actualizar" button
                InkWell(
                  onTap: () {
                    setState(() {
                      isFlatIncrease = !isFlatIncrease;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: isFlatIncrease ? Colors.red : Colors.blue,
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Center(
                      child: Text(
                        isFlatIncrease ? 'Monto Fijo' : 'Porcentaje',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                child: const Text('Cancelar'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              TextButton(
                child: const Text('Actualizar'),
                onPressed: () {
                  double amount =
                      double.tryParse(amountController.text.trim()) ?? 0.0;

                  if (amount > 0) {
                    if (isFlatIncrease) {
                      if (isIncreasing) {
                        updateProductPriceFlatIncrease(product, amount);
                      } else {
                        updateProductPriceFlatDecrease(product, amount);
                      }
                    } else {
                      if (isIncreasing) {
                        updateProductPricePercentageIncrease(product, amount);
                      } else {
                        updateProductPricePercentageDecrease(product, amount);
                      }
                    }

                    setState(() {}); // Trigger a rebuild to update the UI

                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Por favor introducir un monto válido.'),
                      ),
                    );
                  }
                },
              ),
            ],
          );
        });
      },
    );
  }

  void updateProductPriceFlatDecrease(Product product, double decreaseAmount) {
    double newPrice = product.price - decreaseAmount;
    productsRef.doc(product.name).update({'price': newPrice});

    // Update the price for the product in the displayedProducts list
    int productIndex =
        displayedProducts.indexWhere((p) => p.name == product.name);
    if (productIndex != -1) {
      Product updatedProduct = Product(
        name: product.name,
        price: newPrice,
        quantity: product.quantity,
      );
      displayedProducts[productIndex] = updatedProduct;
      setState(() {}); // Trigger a rebuild to update the UI
    }
  }

  void updateProductPricePercentageDecrease(
      Product product, double decreasePercentage) {
    double decreaseAmount = product.price * (decreasePercentage / 100);
    double newPrice = product.price - decreaseAmount;
    productsRef.doc(product.name).update({'price': newPrice});

    // Update the price for the product in the displayedProducts list
    int productIndex =
        displayedProducts.indexWhere((p) => p.name == product.name);
    if (productIndex != -1) {
      Product updatedProduct = Product(
        name: product.name,
        price: newPrice,
        quantity: product.quantity,
      );
      displayedProducts[productIndex] = updatedProduct;
      setState(() {}); // Trigger a rebuild to update the UI
    }
  }

  void updateProductPriceFlatIncrease(Product product, double increaseAmount) {
    double newPrice = product.price + increaseAmount;
    productsRef.doc(product.name).update({'price': newPrice});

    // Update the price for the product in the displayedProducts list
    int productIndex =
        displayedProducts.indexWhere((p) => p.name == product.name);
    if (productIndex != -1) {
      Product updatedProduct = Product(
        name: product.name,
        price: newPrice,
        quantity: product.quantity,
      );
      displayedProducts[productIndex] = updatedProduct;
      setState(() {}); // Trigger a rebuild to update the UI
    }
  }

  void updateProductPricePercentageIncrease(
      Product product, double increasePercentage) {
    double increaseAmount = product.price * (increasePercentage / 100);
    double newPrice = product.price + increaseAmount;
    productsRef.doc(product.name).update({'price': newPrice});

    // Update the price for the product in the displayedProducts list
    int productIndex =
        displayedProducts.indexWhere((p) => p.name == product.name);
    if (productIndex != -1) {
      Product updatedProduct = Product(
        name: product.name,
        price: newPrice,
        quantity: product.quantity,
      );
      displayedProducts[productIndex] = updatedProduct;
      setState(() {}); // Trigger a rebuild to update the UI
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          ProductSearchbarWidget(onTextChanged: onSearchTextChanged),
          Expanded(
            child: ListView.separated(
              itemCount: displayedProducts.length,
              separatorBuilder: (context, index) {
                return Divider(
                  color: Colors.grey.shade400,
                  thickness: 1,
                  indent: 16,
                  endIndent: 16,
                );
              },
              itemBuilder: (context, index) {
                Product product = displayedProducts[index];
                return ListTile(
                  leading: IconButton(
                    icon: const Icon(
                      Icons.delete_forever,
                      size: 32,
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Borrar Producto'),
                          content: const Text('¿Quieres borrar este producto?'),
                          actions: [
                            TextButton(
                              child: const Text('Cancelar'),
                              onPressed: () => Navigator.pop(context),
                            ),
                            TextButton(
                              child: const Text('Borrar'),
                              onPressed: () {
                                // Delete the product from the database
                                productsRef.doc(product.name).delete();

                                // Remove the product from allProducts list
                                allProducts.remove(product);

                                // Remove the product from displayedProducts list
                                displayedProducts.remove(product);

                                setState(() {}); // Update the UI

                                // Close the dialog
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  title: Row(
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  subtitle: Text(
                    'ARS ${product.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.attach_money,
                          size: 32,
                        ),
                        onPressed: () {
                          _showPriceUpdateDialog(context, product);
                        },
                      ),
                      const SizedBox(width: 20),
                      GestureDetector(
                        onTap: () {
                          if (product.quantity > 0) {
                            setState(() {
                              product.quantity -= 1;
                            });
                            updateProductQuantity(product);
                          }
                        },
                        child: const Icon(
                          Icons.remove,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Text(
                        product.quantity.toString(),
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(width: 20),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            product.quantity += 1;
                          });
                          updateProductQuantity(product);
                        },
                        child: const Icon(
                          Icons.add,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          _addProduct(context);
        },
      ),
    );
  }

  void _addProduct(BuildContext context) async {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController priceController = TextEditingController();
    final TextEditingController quantityController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Agregar Producto'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  hintText: 'Nombre',
                  hintStyle: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(
                  hintText: 'Precio',
                  hintStyle: TextStyle(
                    color: Colors.grey,
                  ),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
              TextField(
                controller: quantityController,
                decoration: const InputDecoration(
                  hintText: 'Cantidad',
                  hintStyle: TextStyle(
                    color: Colors.grey,
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text('Agregar'),
              onPressed: () async {
                String id = nameController.text.trim();
                String name = nameController.text.trim();
                double price = double.tryParse(
                        priceController.text.trim().replaceAll(",", ".")) ??
                    0.0;
                int quantity =
                    int.tryParse(quantityController.text.trim()) ?? 0;

                if (name.isNotEmpty && price > 0 && quantity > 0) {
                  // Add the new product to the database
                  await productsRef.doc(id).set({
                    'name': name,
                    'price': price,
                    'quantity': quantity,
                  });

                  // ignore: use_build_context_synchronously
                  Navigator.pop(context);

                  // Fetch the updated list of products
                  fetchProducts();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Por favor introducir datos válidos.'),
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void updateProductQuantity(Product product) {
    productsRef.doc(product.name).update({'quantity': product.quantity});
  }
}
