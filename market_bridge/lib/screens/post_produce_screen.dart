// lib/screens/post_produce_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PostProduceScreen extends StatefulWidget {
  final Map<String, dynamic>? editListing;
  final String? listingId;

  const PostProduceScreen({
    Key? key,
    this.editListing,
    this.listingId,
  }) : super(key: key);

  @override
  State<PostProduceScreen> createState() => _PostProduceScreenState();
}

class _PostProduceScreenState extends State<PostProduceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  final _locationController = TextEditingController();

  String? _selectedCrop;
  String _selectedUnit = 'Kg';
  bool _isPriceNegotiable = false;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  final List<String> _crops = [
    'Tomato',
    'Onion',
    'Potato',
    'Wheat',
    'Rice',
    'Carrot',
    'Cabbage',
    'Spinach',
  ];

  final List<String> _units = ['Kg', 'Quintal', 'Ton'];

  @override
  void initState() {
    super.initState();
    // If editing, populate fields
    if (widget.editListing != null) {
      _selectedCrop = widget.editListing!['crop'];
      _quantityController.text = widget.editListing!['quantity'].toString();
      _selectedUnit = widget.editListing!['unit'] ?? 'Kg';
      _priceController.text = widget.editListing!['price'].toString();
      _isPriceNegotiable = widget.editListing!['isNegotiable'] ?? false;
      _locationController.text = widget.editListing!['location'] ?? '';
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _priceController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      _showSnackbar('Error picking image: $e', isError: true);
    }
  }

  void _showSnackbar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : const Color(0xFF11823F),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // Add new listing to Firestore
  Future<void> _addListing() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCrop == null) {
      _showSnackbar('Please select a crop', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Validate input
      final quantity = _quantityController.text.trim();
      final price = _priceController.text.trim();
      final location = _locationController.text.trim();

      if (quantity.isEmpty || price.isEmpty || location.isEmpty) {
        _showSnackbar('Please fill all fields', isError: true);
        setState(() => _isLoading = false);
        return;
      }

      // Create document data with 'name' field for marketplace
      final data = {
        'name': _selectedCrop, // Added for marketplace compatibility
        'crop': _selectedCrop,
        'quantity': double.parse(quantity),
        'unit': _selectedUnit,
        'price': double.parse(price),
        'isNegotiable': _isPriceNegotiable,
        'location': location,
        'status': 'active',
        'views': 0,
        'inquiries': 0,
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      };

      // Add to Firestore
      await FirebaseFirestore.instance.collection('products').add(data);

      if (!mounted) return;

      // Show success message
      _showSnackbar('Listing published successfully!');

      // Navigate back
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      debugPrint('Error adding listing: $e');
      _showSnackbar('Failed to publish listing: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Update existing listing in Firestore
  Future<void> _updateListing() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCrop == null) {
      _showSnackbar('Please select a crop', isError: true);
      return;
    }
    if (widget.listingId == null) {
      _showSnackbar('Listing ID not found', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Validate input
      final quantity = _quantityController.text.trim();
      final price = _priceController.text.trim();
      final location = _locationController.text.trim();

      if (quantity.isEmpty || price.isEmpty || location.isEmpty) {
        _showSnackbar('Please fill all fields', isError: true);
        setState(() => _isLoading = false);
        return;
      }

      // Update document in Firestore with 'name' field
      await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.listingId)
          .update({
        'name': _selectedCrop, // Added for marketplace compatibility
        'crop': _selectedCrop,
        'quantity': double.parse(quantity),
        'unit': _selectedUnit,
        'price': double.parse(price),
        'isNegotiable': _isPriceNegotiable,
        'location': location,
        'updatedAt': Timestamp.now(),
      });

      if (!mounted) return;

      // Show success message
      _showSnackbar('Listing updated successfully!');

      // Navigate back
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      debugPrint('Error updating listing: $e');
      _showSnackbar('Failed to update listing: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _publishListing() {
    if (widget.editListing != null) {
      _updateListing();
    } else {
      _addListing();
    }
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final isTablet = mq.size.width > 600;
    final isEditing = widget.editListing != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF11823F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEditing ? 'Edit Produce' : 'Post Your Produce',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isTablet ? 24 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Crop Name
                  _buildSectionLabel('Crop Name'),
                  const SizedBox(height: 8),
                  _buildDropdownField(
                    hint: 'Select Crop',
                    value: _selectedCrop,
                    items: _crops,
                    onChanged: (value) {
                      setState(() {
                        _selectedCrop = value;
                      });
                    },
                  ),
                  const SizedBox(height: 20),

                  // Quantity and Unit Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionLabel('Quantity'),
                            const SizedBox(height: 8),
                            _buildTextField(
                              controller: _quantityController,
                              hint: 'Enter Quantity',
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Invalid number';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionLabel('Unit'),
                            const SizedBox(height: 8),
                            _buildDropdownField(
                              hint: 'Unit',
                              value: _selectedUnit,
                              items: _units,
                              onChanged: (value) {
                                setState(() {
                                  _selectedUnit = value!;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Price
                  _buildSectionLabel('Price (per unit)'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _priceController,
                    hint: 'Enter amount',
                    prefix: const Padding(
                      padding: EdgeInsets.only(left: 16, right: 8),
                      child: Text(
                        '₹',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter price';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Invalid price';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // Price Negotiable Checkbox
                  InkWell(
                    onTap: () {
                      setState(() {
                        _isPriceNegotiable = !_isPriceNegotiable;
                      });
                    },
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: _isPriceNegotiable
                                ? const Color(0xFF11823F)
                                : Colors.white,
                            border: Border.all(
                              color: _isPriceNegotiable
                                  ? const Color(0xFF11823F)
                                  : Colors.grey[400]!,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: _isPriceNegotiable
                              ? const Icon(Icons.check,
                              size: 16, color: Colors.white)
                              : null,
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Price Negotiable',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF333333),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Photo Section
                  _buildSectionLabel('Photo (Optional)'),
                  const SizedBox(height: 12),
                  if (_selectedImage != null)
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _selectedImage!,
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _selectedImage = null;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: _buildPhotoButton(
                            icon: Icons.camera_alt,
                            label: 'Camera',
                            onTap: () => _pickImage(ImageSource.camera),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildPhotoButton(
                            icon: Icons.photo_library,
                            label: 'Gallery',
                            onTap: () => _pickImage(ImageSource.gallery),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 24),

                  // Location
                  _buildSectionLabel('Location'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _locationController,
                    hint: 'City/District',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter location';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),

                  // Publish Button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _publishListing,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF11823F),
                        disabledBackgroundColor: Colors.grey[400],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                          : Text(
                        isEditing ? 'Update Listing' : 'Publish Listing',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFF333333),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    Widget? prefix,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: Color(0xFF999999),
          fontSize: 14,
        ),
        prefix: prefix,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF11823F), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String hint,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      hint: Text(
        hint,
        style: const TextStyle(
          color: Color(0xFF999999),
          fontSize: 14,
        ),
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF11823F), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(
            item,
            style: const TextStyle(fontSize: 14),
          ),
        );
      }).toList(),
      onChanged: onChanged,
      icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF666666)),
      dropdownColor: Colors.white,
    );
  }

  Widget _buildPhotoButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: const Color(0xFF11823F)),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF666666),
              ),
            ),
          ],
        ),
      ),
    );
  }
}