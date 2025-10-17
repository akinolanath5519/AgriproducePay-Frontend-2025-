import 'package:flutter/material.dart';

class Product {
  final String name;
  final String imageUrl;
  final double price;
  final String description;
  final String seller;

  Product({
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.description,
    required this.seller,
  });
}

final List<Product> dummyProducts = [
  Product(
    name: 'Cashew',
    imageUrl: 'https://via.placeholder.com/150',
    price: 1200,
    description: 'High-quality Nigerian cashew nuts perfect for export.',
    seller: 'GreenFarm Traders',
  ),
  Product(
    name: 'Cocoa',
    imageUrl: 'https://via.placeholder.com/150',
    price: 4500,
    description: 'Pure cocoa beans from Ondo farms, sun-dried and sorted.',
    seller: 'FarmGate Cocoa',
  ),
  Product(
    name: 'Maize',
    imageUrl: 'https://via.placeholder.com/150',
    price: 750,
    description: 'Freshly harvested maize suitable for feed and food use.',
    seller: 'AgroPlus Ventures',
  ),
  Product(
    name: 'Palm Kernel',
    imageUrl: 'https://via.placeholder.com/150',
    price: 950,
    description: 'Clean and processed palm kernels, ready for crushing.',
    seller: 'Niger Palm Co.',
  ),
];

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  final TextEditingController _searchController = TextEditingController();

  // For demo: separate lists for Buy and Sell (in real app these will come from API)
  late final List<Product> buyProducts;
  late final List<Product> sellProducts;

  @override
  void initState() {
    super.initState();
    // simple split for demo purposes
    buyProducts = dummyProducts;
    sellProducts = [
      // could be different items or the same with different sellers/prices
      Product(
        name: 'Cashew (Wanted)',
        imageUrl: 'https://via.placeholder.com/150',
        price: 1180,
        description: 'Buy request for cashew — looking for 10+ tonnes.',
        seller: 'BuyRequest - LocalCo',
      ),
      Product(
        name: 'Maize (Wanted)',
        imageUrl: 'https://via.placeholder.com/150',
        price: 730,
        description: 'Looking to buy maize for feedstock.',
        seller: 'BuyRequest - FeedCorp',
      ),
    ];
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Product> _filter(List<Product> list) {
    final q = _searchController.text.trim().toLowerCase();
    if (q.isEmpty) return list;
    return list.where((p) {
      return p.name.toLowerCase().contains(q) ||
          p.seller.toLowerCase().contains(q) ||
          p.description.toLowerCase().contains(q);
    }).toList();
  }

  Widget _buildGrid(List<Product> products) {
    if (products.isEmpty) {
      return const Center(child: Text('No items found'));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: products.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (context, index) {
        final product = products[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProductDetailsScreen(product: product),
              ),
            );
          },
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(12)),
                    child: Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text('₦${product.price.toStringAsFixed(0)} /kg'),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ProductDetailsScreen(product: product),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          minimumSize: const Size(double.infinity, 36),
                        ),
                        child: const Text('View Details'),
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
  }

  @override
  Widget build(BuildContext context) {
    final filteredBuy = _filter(buyProducts);
    final filteredSell = _filter(sellProducts);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Marketplace'),
          bottom: const TabBar(tabs: [
            Tab(text: 'Buy'),
            Tab(text: 'Sell'),
          ]),
        ),
        body: Column(
          children: [
            // Search bar (shared)
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search commodities...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.grey.shade200,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // Tab views
            Expanded(
              child: TabBarView(children: [
                // Buy tab
                _buildGrid(filteredBuy),
                // Sell tab
                _buildGrid(filteredSell),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductDetailsScreen extends StatelessWidget {
  final Product product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(product.name)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.network(product.imageUrl, height: 250, fit: BoxFit.cover),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name,
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text('Price: ₦${product.price.toStringAsFixed(0)} /kg',
                      style:
                          const TextStyle(fontSize: 18, color: Colors.green)),
                  const SizedBox(height: 10),
                  Text('Seller: ${product.seller}',
                      style: const TextStyle(fontSize: 16, color: Colors.grey)),
                  const SizedBox(height: 20),
                  Text(
                    product.description,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 30),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Request Purchase pressed'),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text(
                        'Request Purchase',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
