import 'package:flutter/material.dart';
import '../../models/clothing.dart';
import '../../services/api_service.dart';
import 'add_edit_cloth_screen.dart';

class ClothDetailScreen extends StatefulWidget {
  final int clothId;

  const ClothDetailScreen({super.key, required this.clothId});

  @override
  State<ClothDetailScreen> createState() => _ClothDetailScreenState();
}

class _ClothDetailScreenState extends State<ClothDetailScreen> {
  final ApiService _apiService = ApiService();
  late Future<Clothing> _clothDetailFuture;

  @override
  void initState() {
    super.initState();
    _loadClothDetails();
  }

  void _loadClothDetails() {
    setState(() {
      _clothDetailFuture = _apiService.getClothById(widget.clothId);
    });
  }

  void _navigateToEditScreen(Clothing clothing) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditClothScreen(clothing: clothing),
      ),
    );
    if (result == true) {
      _loadClothDetails();
    }
  }

  Future<void> _deleteCloth(BuildContext context, int id) async {
    try {
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      await _apiService.deleteCloth(id);
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Clothing deleted successfully! 🎉'),
          backgroundColor: Colors.green,
        ),
      );
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete clothing: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Pakaian')),
      body: FutureBuilder<Clothing>(
        future: _clothDetailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Cloth not found.'));
          }

          final cloth = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Hero(
                  tag: 'clothImage_${cloth.id}',
                  child: Container(
                    height: 250,
                    width: double.infinity,
                    color: Colors.grey[300],
                    child: Center(
                      child: Text(
                        cloth.name.isNotEmpty
                            ? cloth.name[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          fontSize: 100,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  cloth.name,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                Text(
                  cloth.name,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 10),
                Text(
                  'Price: Rp ${cloth.price?.toString() ?? 'Not available'}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Category: ${cloth.category}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                if (cloth.brand != null)
                  Text(
                    'Brand: ${cloth.brand}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                if (cloth.material != null)
                  Text(
                    'Material: ${cloth.material}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                const SizedBox(height: 8),
                Text(
                  'Rating: ${cloth.rating?.toStringAsFixed(1) ?? 'N/A'} ⭐',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Text(
                  'Year Released: ${cloth.yearReleased?.toString() ?? 'N/A'}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                if (cloth.stock != null)
                  Text(
                    'Stock: ${cloth.stock}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                if (cloth.sold != null)
                  Text(
                    'Sold: ${cloth.sold}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit'),
                      onPressed: () => _navigateToEditScreen(cloth),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                      ),
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.delete_forever),
                      label: const Text('Delete'),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext ctx) {
                            return AlertDialog(
                              title: const Text('Please Confirm'),
                              content: const Text(
                                'Are you sure you want to delete this item?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(ctx).pop(true);
                                    _deleteCloth(context, cloth.id!);
                                  },
                                  child: const Text(
                                    'Delete',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
