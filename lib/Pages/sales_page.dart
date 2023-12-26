import 'package:flutter/material.dart';
import 'package:flutter_pos_revised/Widgets/Sales/cart.dart';
import 'package:flutter_pos_revised/Widgets/Sales/product_list.dart';
import 'package:flutter_pos_revised/Widgets/Sales/product_searchbar.dart';

class SalesPageWidget extends StatefulWidget {
  const SalesPageWidget({Key? key}) : super(key: key);

  @override
  State<SalesPageWidget> createState() => _SalesPageWidgetState();
}

class _SalesPageWidgetState extends State<SalesPageWidget> {
  String _searchText = '';

  void onSearchTextChanged(String searchText) {
    setState(() {
      _searchText = searchText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ProductSearchbarWidget(onTextChanged: onSearchTextChanged),
        Expanded(
          child: Stack(
            children: [
              ProductListWidget(
                  searchText: _searchText), // Pass the search text here
              const Positioned(
                left: 1,
                right: 1,
                bottom: 0,
                child: CartWidget(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
