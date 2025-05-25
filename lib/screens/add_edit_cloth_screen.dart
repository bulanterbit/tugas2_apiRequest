import 'package:flutter/material.dart';
import '../../models/clothing.dart';
import '../../services/api_service.dart';

class AddEditClothScreen extends StatefulWidget {
  final Clothing? clothing;

  const AddEditClothScreen({super.key, this.clothing});

  @override
  State<AddEditClothScreen> createState() => _AddEditClothScreenState();
}

class _AddEditClothScreenState extends State<AddEditClothScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();

  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _categoryController;
  late TextEditingController _brandController;
  late TextEditingController _soldController;
  late TextEditingController _ratingController;
  late TextEditingController _stockController;
  late TextEditingController _yearReleasedController;
  late TextEditingController _materialController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.clothing?.name ?? '');
    _priceController = TextEditingController(
      text: widget.clothing?.price?.toString() ?? '',
    );
    _categoryController = TextEditingController(
      text: widget.clothing?.category ?? '',
    );
    _brandController = TextEditingController(
      text: widget.clothing?.brand ?? '',
    );
    _soldController = TextEditingController(
      text: widget.clothing?.sold?.toString() ?? '',
    );
    _ratingController = TextEditingController(
      text: widget.clothing?.rating?.toString() ?? '',
    );
    _stockController = TextEditingController(
      text: widget.clothing?.stock?.toString() ?? '',
    );
    _yearReleasedController = TextEditingController(
      text: widget.clothing?.yearReleased?.toString() ?? '',
    );
    _materialController = TextEditingController(
      text: widget.clothing?.material ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
    _brandController.dispose();
    _soldController.dispose();
    _ratingController.dispose();
    _stockController.dispose();
    _yearReleasedController.dispose();
    _materialController.dispose();
    super.dispose();
  }

  Future<void> _saveCloth() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final currentYear = DateTime.now().year;

      final clothingData = Clothing(
        id: widget.clothing?.id,
        name: _nameController.text,
        price: int.parse(_priceController.text),
        category: _categoryController.text,
        brand: _brandController.text.isNotEmpty ? _brandController.text : null,
        sold:
            _soldController.text.isNotEmpty
                ? int.tryParse(_soldController.text)
                : null,
        rating: double.parse(_ratingController.text),
        stock:
            _stockController.text.isNotEmpty
                ? int.tryParse(_stockController.text)
                : null,
        yearReleased: int.parse(_yearReleasedController.text),
        material:
            _materialController.text.isNotEmpty
                ? _materialController.text
                : null,
      );

      try {
        final scaffoldMessenger = ScaffoldMessenger.of(context);
        if (widget.clothing == null) {
          await _apiService.addCloth(clothingData);
          scaffoldMessenger.showSnackBar(
            const SnackBar(
              content: Text('Clothing added successfully! ✨'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          await _apiService.updateCloth(widget.clothing!.id!, clothingData);
          scaffoldMessenger.showSnackBar(
            const SnackBar(
              content: Text('Clothing updated successfully! 👍'),
              backgroundColor: Colors.green,
            ),
          );
        }
        if (mounted) Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.clothing == null ? '➕ Add New Cloth' : '✏️ Edit Cloth',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              _buildTextField(_nameController, 'Name', isRequired: true),
              _buildTextField(
                _priceController,
                'Price',
                inputType: TextInputType.number,
                isRequired: true,
              ),
              _buildTextField(
                _categoryController,
                'Category',
                isRequired: true,
              ),
              _buildTextField(
                _ratingController,
                'Rating (0.0 - 5.0)',
                inputType: TextInputType.numberWithOptions(decimal: true),
                isRequired: true,
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Rating is required.';
                  final rating = double.tryParse(value);
                  if (rating == null || rating < 0 || rating > 5) {
                    return 'Rating must be between 0 and 5.';
                  }
                  return null;
                },
              ),
              _buildTextField(
                _yearReleasedController,
                'Year Released (e.g., 2018 - ${DateTime.now().year})',
                inputType: TextInputType.number,
                isRequired: true,
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Year released is required.';
                  final year = int.tryParse(value);
                  if (year == null ||
                      year < 2018 ||
                      year > DateTime.now().year) {
                    return 'Year must be between 2018 and ${DateTime.now().year}.';
                  }
                  return null;
                },
              ),
              _buildTextField(_brandController, 'Brand (Optional)'),
              _buildTextField(_materialController, 'Material (Optional)'),
              _buildTextField(
                _stockController,
                'Stock (Optional)',
                inputType: TextInputType.number,
              ),
              _buildTextField(
                _soldController,
                'Sold (Optional)',
                inputType: TextInputType.number,
              ),

              const SizedBox(height: 20),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                    onPressed: _saveCloth,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      widget.clothing == null ? 'Add Cloth' : 'Save Changes',
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    TextInputType inputType = TextInputType.text,
    bool isRequired = false,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        keyboardType: inputType,
        validator: (value) {
          if (isRequired && (value == null || value.isEmpty)) {
            return '$label is required.';
          }
          if (validator != null) {
            return validator(value);
          }
          if ((label == 'Price' ||
                  label == 'Stock' ||
                  label == 'Sold' ||
                  label.startsWith('Year Released')) &&
              value != null &&
              value.isNotEmpty) {
            if (int.tryParse(value) == null)
              return 'Please enter a valid number for $label.';
          }
          if (label.startsWith('Rating') && value != null && value.isNotEmpty) {
            if (double.tryParse(value) == null)
              return 'Please enter a valid decimal for $label.';
          }
          return null;
        },
      ),
    );
  }
}
