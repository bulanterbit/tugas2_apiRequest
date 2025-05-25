import 'package:flutter/material.dart';
import '../../models/clothing.dart';
import '../../services/api_service.dart';
import 'cloth_detail_screen.dart';
import 'add_edit_cloth_screen.dart';

class ClothesListScreen extends StatefulWidget {
  const ClothesListScreen({super.key});

  @override
  State<ClothesListScreen> createState() => _ClothesListScreenState();
}

class _ClothesListScreenState extends State<ClothesListScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Clothing>> _clothesFuture;

  @override
  void initState() {
    super.initState();
    _loadClothes();
  }

  void _loadClothes() {
    setState(() {
      _clothesFuture = _apiService.getAllClothes();
    });
  }

  void _navigateToAddScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddEditClothScreen()),
    );
    if (result == true) {
      _loadClothes();
    }
  }

  void _navigateToDetailScreen(Clothing clothing) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ClothDetailScreen(clothId: clothing.id!),
      ),
    );
    if (result == true) {
      _loadClothes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('👕 Koleksi Pakaian (123220088)'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadClothes),
        ],
      ),
      body: FutureBuilder<List<Clothing>>(
        future: _clothesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No clothes found.'));
          }

          final clothes = snapshot.data!;
          return GridView.builder(
            padding: const EdgeInsets.all(8.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
              childAspectRatio: 0.75,
            ),
            itemCount: clothes.length,
            itemBuilder: (context, index) {
              final cloth = clothes[index];
              return Card(
                elevation: 3,
                child: InkWell(
                  onTap: () => _navigateToDetailScreen(cloth),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: Hero(
                          tag: 'clothImage_${cloth.id}',
                          child: Container(
                            color: Colors.grey[300],
                            child: Center(
                              child: Text(
                                cloth.name.isNotEmpty
                                    ? cloth.name[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  fontSize: 40,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              cloth.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'Rp ${cloth.price?.toString() ?? 'N/A'}',
                              style: TextStyle(color: Colors.green[700]),
                            ),
                            Text(
                              cloth.category,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddScreen,
        tooltip: 'Add Cloth',
        child: const Icon(Icons.add),
      ),
    );
  }
}
