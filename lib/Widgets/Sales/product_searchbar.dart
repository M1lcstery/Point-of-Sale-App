// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';

class ProductSearchbarWidget extends StatefulWidget {
  final Function(String) onTextChanged;

  const ProductSearchbarWidget({
    Key? key,
    required this.onTextChanged,
  }) : super(key: key);

  @override
  _ProductSearchbarWidgetState createState() => _ProductSearchbarWidgetState();
}

class _ProductSearchbarWidgetState extends State<ProductSearchbarWidget> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.black, width: 1.0),
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Icon(
                Icons.search,
                color: Colors.grey[600],
              ),
            ),
            Expanded(
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  widget.onTextChanged(value);
                },
                decoration: InputDecoration(
                  hintText: 'Buscar productos',
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.clear,
                color: Colors.grey[600],
              ),
              onPressed: () {
                _searchController.clear();
                widget.onTextChanged('');
              },
            ),
          ],
        ),
      ),
    );
  }
}
