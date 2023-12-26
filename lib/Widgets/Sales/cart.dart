import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pos_revised/Widgets/Sales/cart_view.dart';

class CartWidget extends StatelessWidget {
  const CartWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('cart').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Error al obtener el carrito.');
        }

        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        bool isCartEmpty = snapshot.data!.docs.isEmpty;

        if (isCartEmpty) {
          return const SizedBox.shrink();
        }

        return Positioned(
          left: 128,
          right: 128,
          bottom: 16,
          child: SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const CartView(),
                  ),
                );
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_rounded),
                  SizedBox(width: 8),
                  Text(
                    'Carrito',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
