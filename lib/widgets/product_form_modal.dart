import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/product_provider.dart';
import '../models/product.dart';

class ProductFormModal extends StatefulWidget {
  final Product? product;

  const ProductFormModal({super.key, this.product});

  @override
  State<ProductFormModal> createState() => _ProductFormModalState();
}

class _ProductFormModalState extends State<ProductFormModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockQuantityController = TextEditingController(text: '0');
  final _stockLimitController = TextEditingController(text: '5');
  final _categoryController = TextEditingController();
  final _barcodeController = TextEditingController();
  String? _imagePath;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _nameController.text = widget.product!.name;
      _priceController.text = widget.product!.price.toString();
      _stockQuantityController.text =
          widget.product!.stockQuantity.toString();
      _stockLimitController.text = widget.product!.stockLimit.toString();
      _categoryController.text = widget.product!.category ?? '';
      _barcodeController.text = widget.product!.barcode ?? '';
      _imagePath = widget.product!.imagePath;
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _imagePath = image.path;
      });
    }
  }

  Future<void> _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<ProductProvider>(context, listen: false);
      if (widget.product != null) {
        final product = widget.product!;
        product.name = _nameController.text;
        product.price = double.parse(_priceController.text);
        product.stockQuantity = int.parse(_stockQuantityController.text);
        product.stockLimit = int.parse(_stockLimitController.text);
        product.category = _categoryController.text.isEmpty
            ? null
            : _categoryController.text;
        product.barcode =
            _barcodeController.text.isEmpty ? null : _barcodeController.text;
        product.imagePath = _imagePath;
        await provider.updateProduct(product);
      } else {
        final product = Product(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: _nameController.text,
          price: double.parse(_priceController.text),
          stockQuantity: int.parse(_stockQuantityController.text),
          stockLimit: int.parse(_stockLimitController.text),
          category: _categoryController.text.isEmpty
              ? null
              : _categoryController.text,
          barcode:
              _barcodeController.text.isEmpty ? null : _barcodeController.text,
          imagePath: _imagePath,
        );
        await provider.addProduct(product);
      }
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  Future<void> _deleteProduct() async {
    if (widget.product != null) {
      final provider = Provider.of<ProductProvider>(context, listen: false);
      await provider.deleteProduct(widget.product!.id);
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title:
          Text(widget.product != null ? 'Edit Product' : 'Add New Product'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[400]!),
                  ),
                  child: _imagePath != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(_imagePath!),
                            fit: BoxFit.cover,
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt, size: 40, color: Colors.grey[600]),
                            const SizedBox(height: 8),
                            Text('Tap to add product image', style: TextStyle(color: Colors.grey[600])),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Product Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter a name' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Price (UGX)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter a price' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _stockQuantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Stock Quantity',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _stockLimitController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Restock Limit',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(
                  labelText: 'Category (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _barcodeController,
                decoration: const InputDecoration(
                  labelText: 'Barcode (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        if (widget.product != null)
          TextButton(
            onPressed: _deleteProduct,
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveProduct,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFC107),
            foregroundColor: Colors.black,
          ),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
