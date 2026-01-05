// lib/screens/post_produce_screen.dart - ENHANCED VERSION
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  final _descriptionController = TextEditingController();
  final _harvestDateController = TextEditingController();
  final _minOrderController = TextEditingController();

  String? _selectedCrop;
  String _selectedUnit = 'Kg';
  String _selectedQuality = 'Grade A';
  bool _isPriceNegotiable = false;
  bool _isOrganicCertified = false;
  bool _allowHomeDelivery = false;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String? _existingImageUrl;
  DateTime? _harvestDate;
  TimeOfDay? _availableFromTime;
  TimeOfDay? _availableToTime;

  final List<String> _crops = [
    'Apple',
    'Banana',
    'Bean',
    'Bell Pepper',
    'Brinjal',
    'Brown Rice',
    'Butter',
    'Cabbage',
    'Carrot',
    'Chili Pepper',
    'Coriander',
    'Corn',
    'Cucumber',
    'Curd',
    'Dragonfruit',
    'Ghee',
    'Grape',
    'Green Chili',
    'Ladyfinger',
    'Mango',
    'Milk',
    'Mint',
    'Mushroom',
    'Oat',
    'Onion',
    'Orange',
    'Papaya',
    'Pea',
    'Pineapple',
    'Pomegranate',
    'Potato',
    'Pumpkin',
    'Quinoa',
    'Raddish',
    'Rice',
    'Spinach',
    'Strawberry',
    'Tomato',
    'Watermelon',
    'Yogurt',
  ];

  final List<String> _units = ['Kg', 'Quintal', 'Ton', 'Piece', 'Dozen', 'Bundle'];
  final List<String> _qualities = ['Grade A', 'Grade B', 'Grade C', 'Organic', 'Mixed'];

  @override
  void initState() {
    super.initState();
    // Pre-fill location from user profile
    _loadUserLocation();

    // If editing, populate fields
    if (widget.editListing != null) {
      _selectedCrop = widget.editListing!['crop'];
      _quantityController.text = widget.editListing!['quantity'].toString();
      _selectedUnit = widget.editListing!['unit'] ?? 'Kg';
      _priceController.text = widget.editListing!['price'].toString();
      _isPriceNegotiable = widget.editListing!['isNegotiable'] ?? false;
      _locationController.text = widget.editListing!['location'] ?? '';
      _existingImageUrl = widget.editListing!['imageUrl'];
      _descriptionController.text = widget.editListing!['description'] ?? '';
      _selectedQuality = widget.editListing!['quality'] ?? 'Grade A';
      _isOrganicCertified = widget.editListing!['isOrganic'] ?? false;
      _allowHomeDelivery = widget.editListing!['homeDelivery'] ?? false;
      _minOrderController.text = widget.editListing!['minOrder']?.toString() ?? '';

      // Load harvest date if exists
      if (widget.editListing!['harvestDate'] != null) {
        final timestamp = widget.editListing!['harvestDate'] as Timestamp;
        _harvestDate = timestamp.toDate();
        _harvestDateController.text = _formatDate(_harvestDate!);
      }
    }
  }

  Future<void> _loadUserLocation() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (doc.exists && mounted) {
          final location = doc.data()?['location'] as String?;
          if (location != null && _locationController.text.isEmpty) {
            setState(() {
              _locationController.text = location;
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading user location: $e');
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _selectHarvestDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _harvestDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF11823F),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _harvestDate) {
      setState(() {
        _harvestDate = picked;
        _harvestDateController.text = _formatDate(picked);
      });
    }
  }

  Future<void> _selectTime(bool isFromTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isFromTime
          ? (_availableFromTime ?? TimeOfDay.now())
          : (_availableToTime ?? TimeOfDay.now()),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF11823F),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isFromTime) {
          _availableFromTime = picked;
        } else {
          _availableToTime = picked;
        }
      });
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _priceController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _harvestDateController.dispose();
    _minOrderController.dispose();
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
          _existingImageUrl = null;
        });
      }
    } catch (e) {
      _showSnackbar('Error picking image: $e', isError: true);
    }
  }

  Future<void> _pickFile() async {
    try {
      // Use gallery which allows selecting any file type on most Android devices
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _existingImageUrl = null;
        });
        _showSnackbar('File selected: ${image.name}');
      }
    } catch (e) {
      _showSnackbar('Error picking file: $e', isError: true);
    }
  }

  void _showSnackbar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? Colors.red : const Color(0xFF11823F),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<String?> _uploadImageToStorage(File imageFile) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showSnackbar('User not logged in', isError: true);
        return null;
      }

      setState(() {
        _isUploading = true;
        _uploadProgress = 0.0;
      });

      // Generate unique filename with timestamp and random suffix
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileExtension = imageFile.path.split('.').last;
      final fileName = 'product_${timestamp}.$fileExtension';
      
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('users')
          .child(user.uid)
          .child('products')
          .child(fileName);

      final uploadTask = storageRef.putFile(imageFile);

      uploadTask.snapshotEvents.listen(
            (snapshot) {
          if (mounted) {
            setState(() {
              _uploadProgress = snapshot.bytesTransferred / snapshot.totalBytes;
            });
          }
        },
        onError: (e) {
          debugPrint('❌ Upload error: $e');
          if (mounted) {
            setState(() => _isUploading = false);
            _showSnackbar('Upload failed: $e', isError: true);
          }
        },
      );

      await uploadTask;
      final downloadUrl = await storageRef.getDownloadURL();

      if (mounted) {
        setState(() => _isUploading = false);
      }
      debugPrint('✅ File uploaded: $downloadUrl');
      return downloadUrl;
    } catch (e, stackTrace) {
      debugPrint('❌ Error uploading file: $e');
      debugPrint('Stack trace: $stackTrace');
      if (mounted) {
        setState(() => _isUploading = false);
        _showSnackbar('File upload failed. Please try again.', isError: true);
      }
      return null;
    }
  }

  Future<void> _deleteImageFromStorage(String imageUrl) async {
    try {
      final ref = FirebaseStorage.instance.refFromURL(imageUrl);
      await ref.delete();
      debugPrint('✅ Old image deleted successfully');
    } catch (e) {
      debugPrint('⚠️ Error deleting old image: $e');
    }
  }

  String _getAssetIconForCrop(String crop) {
    final name = crop.toLowerCase();
    if (name.contains('apple')) return 'assets/icons/apple.png';
    if (name.contains('banana')) return 'assets/icons/bananas.png';
    if (name.contains('bean')) return 'assets/icons/bean.png';
    if (name.contains('bell pepper')) return 'assets/icons/bell-pepper.png';
    if (name.contains('brinjal') || name.contains('eggplant')) return 'assets/icons/brinjal.png';
    if (name.contains('brown rice')) return 'assets/icons/brown-rice.png';
    if (name.contains('butter')) return 'assets/icons/butter.png';
    if (name.contains('cabbage')) return 'assets/icons/cabbage.png';
    if (name.contains('carrot')) return 'assets/icons/carrots.png';
    if (name.contains('chili') || name.contains('chili pepper')) return 'assets/icons/chili-pepper.png';
    if (name.contains('coriander')) return 'assets/icons/coriander.png';
    if (name.contains('corn')) return 'assets/icons/corn.png';
    if (name.contains('cucumber')) return 'assets/icons/cucumber.png';
    if (name.contains('curd')) return 'assets/icons/curd.png';
    if (name.contains('dragonfruit')) return 'assets/icons/dragonfruit.png';
    if (name.contains('ghee')) return 'assets/icons/ghee.png';
    if (name.contains('grape')) return 'assets/icons/grapes.png';
    if (name.contains('green chili')) return 'assets/icons/green-chili-pepper.png';
    if (name.contains('ladyfinger') || name.contains('okra')) return 'assets/icons/ladyfinger.png';
    if (name.contains('mango')) return 'assets/icons/mango.png';
    if (name.contains('milk')) return 'assets/icons/milk.png';
    if (name.contains('mint')) return 'assets/icons/mint.png';
    if (name.contains('mushroom')) return 'assets/icons/mushroom.png';
    if (name.contains('oat')) return 'assets/icons/oat.png';
    if (name.contains('onion')) return 'assets/icons/onion.png';
    if (name.contains('orange')) return 'assets/icons/orange.png';
    if (name.contains('papaya')) return 'assets/icons/papaya.png';
    if (name.contains('pea')) return 'assets/icons/peas.png';
    if (name.contains('pineapple')) return 'assets/icons/pineapple.png';
    if (name.contains('pomegranate')) return 'assets/icons/pomegranate.png';
    if (name.contains('potato')) return 'assets/icons/potato.png';
    if (name.contains('pumpkin')) return 'assets/icons/pumpkin.png';
    if (name.contains('quinoa')) return 'assets/icons/quinoa.png';
    if (name.contains('raddish') || name.contains('radish')) return 'assets/icons/raddish.png';
    if (name.contains('rice')) return 'assets/icons/rice.png';
    if (name.contains('spinach')) return 'assets/icons/spinach.png';
    if (name.contains('strawberry')) return 'assets/icons/strawberry.png';
    if (name.contains('tomato')) return 'assets/icons/tomato.png';
    if (name.contains('watermelon')) return 'assets/icons/watermelon.png';
    if (name.contains('yogurt')) return 'assets/icons/yogurt.png';
    return 'assets/icons/default.png';
  }

  Future<void> _addListing() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCrop == null) {
      _showSnackbar('Please select a crop', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final quantity = _quantityController.text.trim();
      final price = _priceController.text.trim();
      final location = _locationController.text.trim();
      final description = _descriptionController.text.trim();

      if (quantity.isEmpty || price.isEmpty || location.isEmpty) {
        _showSnackbar('Please fill all required fields', isError: true);
        setState(() => _isLoading = false);
        return;
      }

      String? imageUrl;
      if (_selectedImage != null) {
        imageUrl = await _uploadImageToStorage(_selectedImage!);
        if (imageUrl == null) {
          setState(() => _isLoading = false);
          return;
        }
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showSnackbar('User not logged in', isError: true);
        setState(() => _isLoading = false);
        return;
      }

      // Get asset icon path
      final assetIcon = _getAssetIconForCrop(_selectedCrop!);

      final data = {
        'name': _selectedCrop,
        'crop': _selectedCrop,
        'quantity': double.parse(quantity),
        'unit': _selectedUnit,
        'price': double.parse(price),
        'isNegotiable': _isPriceNegotiable,
        'location': location,
        'description': description,
        'quality': _selectedQuality,
        'isOrganic': _isOrganicCertified,
        'homeDelivery': _allowHomeDelivery,
        'status': 'active',
        'inStock': true,
        'views': 0,
        'inquiries': 0,
        'imageUrl': imageUrl,
        'assetIcon': assetIcon, // Store asset icon path
        'ownerId': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Add optional fields
      if (_harvestDate != null) {
        data['harvestDate'] = Timestamp.fromDate(_harvestDate!);
      }

      if (_minOrderController.text.isNotEmpty) {
        data['minOrder'] = double.parse(_minOrderController.text);
      }

      if (_availableFromTime != null && _availableToTime != null) {
        data['availableFrom'] = '${_availableFromTime!.hour}:${_availableFromTime!.minute}';
        data['availableTo'] = '${_availableToTime!.hour}:${_availableToTime!.minute}';
      }

      await FirebaseFirestore.instance.collection('products').add(data);

      if (!mounted) return;

      _showSnackbar('Listing published successfully!');

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
      final quantity = _quantityController.text.trim();
      final price = _priceController.text.trim();
      final location = _locationController.text.trim();
      final description = _descriptionController.text.trim();

      if (quantity.isEmpty || price.isEmpty || location.isEmpty) {
        _showSnackbar('Please fill all required fields', isError: true);
        setState(() => _isLoading = false);
        return;
      }

      String? imageUrl = _existingImageUrl;

      if (_selectedImage != null) {
        final newImageUrl = await _uploadImageToStorage(_selectedImage!);
        if (newImageUrl == null) {
          setState(() => _isLoading = false);
          return;
        }

        if (_existingImageUrl != null && _existingImageUrl!.isNotEmpty) {
          await _deleteImageFromStorage(_existingImageUrl!);
        }

        imageUrl = newImageUrl;
      }

      // Get asset icon path
      final assetIcon = _getAssetIconForCrop(_selectedCrop!);

      final updateData = {
        'name': _selectedCrop,
        'crop': _selectedCrop,
        'quantity': double.parse(quantity),
        'unit': _selectedUnit,
        'price': double.parse(price),
        'isNegotiable': _isPriceNegotiable,
        'location': location,
        'description': description,
        'quality': _selectedQuality,
        'isOrganic': _isOrganicCertified,
        'homeDelivery': _allowHomeDelivery,
        'imageUrl': imageUrl,
        'assetIcon': assetIcon,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Add optional fields
      if (_harvestDate != null) {
        updateData['harvestDate'] = Timestamp.fromDate(_harvestDate!);
      }

      if (_minOrderController.text.isNotEmpty) {
        updateData['minOrder'] = double.parse(_minOrderController.text);
      }

      if (_availableFromTime != null && _availableToTime != null) {
        updateData['availableFrom'] = '${_availableFromTime!.hour}:${_availableFromTime!.minute}';
        updateData['availableTo'] = '${_availableToTime!.hour}:${_availableToTime!.minute}';
      }

      await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.listingId)
          .update(updateData);

      if (!mounted) return;

      _showSnackbar('Listing updated successfully!');

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
          if (!isEditing)
            IconButton(
              icon: const Icon(Icons.info_outline, color: Colors.white),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    title: const Text('Tips for Better Listings'),
                    content: const SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('• Add a clear photo of your produce'),
                          SizedBox(height: 8),
                          Text('• Specify harvest date for freshness'),
                          SizedBox(height: 8),
                          Text('• Mention quality grade accurately'),
                          SizedBox(height: 8),
                          Text('• Set competitive prices'),
                          SizedBox(height: 8),
                          Text('• Include detailed description'),
                          SizedBox(height: 8),
                          Text('• Respond to inquiries quickly'),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Got it'),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isTablet ? 24 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Crop Selection
              _buildSectionLabel('Crop Name', required: true),
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

              // Quantity and Unit
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionLabel('Quantity', required: true),
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
                              return 'Invalid';
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
                        _buildSectionLabel('Unit', required: true),
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

              // Quality Grade
              _buildSectionLabel('Quality Grade', required: true),
              const SizedBox(height: 8),
              _buildDropdownField(
                hint: 'Select Quality',
                value: _selectedQuality,
                items: _qualities,
                onChanged: (value) {
                  setState(() {
                    _selectedQuality = value!;
                  });
                },
              ),
              const SizedBox(height: 20),

              // Price and Minimum Order
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionLabel('Price (per unit)', required: true),
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
                              return 'Required';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Invalid';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionLabel('Min Order'),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _minOrderController,
                          hint: 'Min',
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Price Negotiable Checkbox
              _buildCheckbox(
                value: _isPriceNegotiable,
                label: 'Price Negotiable',
                onChanged: (value) {
                  setState(() {
                    _isPriceNegotiable = value!;
                  });
                },
              ),
              const SizedBox(height: 8),

              // Organic Certified Checkbox
              _buildCheckbox(
                value: _isOrganicCertified,
                label: 'Organic Certified',
                icon: Icons.eco,
                onChanged: (value) {
                  setState(() {
                    _isOrganicCertified = value!;
                  });
                },
              ),
              const SizedBox(height: 8),

              // Home Delivery Checkbox
              _buildCheckbox(
                value: _allowHomeDelivery,
                label: 'Home Delivery Available',
                icon: Icons.local_shipping_outlined,
                onChanged: (value) {
                  setState(() {
                    _allowHomeDelivery = value!;
                  });
                },
              ),
              const SizedBox(height: 24),

              // Harvest Date
              _buildSectionLabel('Harvest Date'),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _selectHarvestDate,
                child: AbsorbPointer(
                  child: _buildTextField(
                    controller: _harvestDateController,
                    hint: 'Select harvest date',
                    suffix: const Icon(Icons.calendar_today, size: 20),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Description
              _buildSectionLabel('Description'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _descriptionController,
                hint: 'Add details about your produce...',
                maxLines: 4,
              ),
              const SizedBox(height: 24),

              // Location
              _buildSectionLabel('Location', required: true),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _locationController,
                hint: 'City/District',
                suffix: const Icon(Icons.location_on, size: 20),
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
                  onPressed:
                  (_isLoading || _isUploading) ? null : _publishListing,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF11823F),
                    disabledBackgroundColor: Colors.grey[400],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: (_isLoading || _isUploading)
                      ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                      : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isEditing ? Icons.update : Icons.publish,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isEditing ? 'Update Listing' : 'Publish Listing',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label, {bool required = false}) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
          ),
        ),
        if (required)
          const Text(
            ' *',
            style: TextStyle(color: Colors.red, fontSize: 14),
          ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    Widget? prefix,
    Widget? suffix,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: Color(0xFF999999),
          fontSize: 14,
        ),
        prefix: prefix,
        suffixIcon: suffix,
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

  Widget _buildCheckbox({
    required bool value,
    required String label,
    IconData? icon,
    required void Function(bool?) onChanged,
  }) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: value ? const Color(0xFF11823F) : Colors.white,
              border: Border.all(
                color: value
                    ? const Color(0xFF11823F)
                    : Colors.grey[400]!,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: value
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 10),
          if (icon != null) ...[
            Icon(icon, size: 18, color: const Color(0xFF11823F)),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF333333),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview(String path, {required bool isExisting}) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: isExisting
              ? Image.network(
            path,
            width: double.infinity,
            height: 200,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                width: double.infinity,
                height: 200,
                color: Colors.grey[200],
                child: Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                        : null,
                    color: const Color(0xFF11823F),
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: double.infinity,
                height: 200,
                color: Colors.grey[200],
                child: const Icon(
                  Icons.broken_image,
                  size: 60,
                  color: Colors.grey,
                ),
              );
            },
          )
              : Image.file(
            File(path),
            width: double.infinity,
            height: 200,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Row(
            children: [
              InkWell(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    builder: (context) => Container(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            leading: const Icon(Icons.camera_alt,
                                color: Color(0xFF11823F)),
                            title: const Text('Take Photo'),
                            onTap: () {
                              Navigator.pop(context);
                              _pickImage(ImageSource.camera);
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.photo_library,
                                color: Color(0xFF11823F)),
                            title: const Text('Choose from Gallery'),
                            onTap: () {
                              Navigator.pop(context);
                              _pickImage(ImageSource.gallery);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.edit,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () {
                  setState(() {
                    if (isExisting) {
                      _existingImageUrl = null;
                    } else {
                      _selectedImage = null;
                    }
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
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImagePicker() {
    return InkWell(
      onTap: () => _pickImage(ImageSource.gallery),
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
            Icon(Icons.cloud_upload_outlined, size: 36, color: const Color(0xFF11823F)),
            const SizedBox(height: 8),
            const Text(
              'Upload Image',
              style: TextStyle(
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

  Widget _buildUploadProgress() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Uploading image...',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF666666),
              ),
            ),
            Text(
              '${(_uploadProgress * 100).toInt()}%',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF11823F),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: _uploadProgress,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(
              Color(0xFF11823F),
            ),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}