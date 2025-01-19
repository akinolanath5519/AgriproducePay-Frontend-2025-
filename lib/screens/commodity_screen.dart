import 'package:agriproduce/data_models/commodity_model.dart';
import 'package:agriproduce/state_management/commodity_provider.dart';
import 'package:agriproduce/widgets/custom_list_tile.dart';
import 'package:agriproduce/widgets/custom_loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agriproduce/widgets/custom_search_bar.dart';
import 'package:intl/intl.dart';

class CommodityScreen extends ConsumerStatefulWidget {
  const CommodityScreen({super.key});

  @override
  _CommodityScreenState createState() => _CommodityScreenState();
}

class _CommodityScreenState extends ConsumerState<CommodityScreen> {
  bool isLoading = false;
  TextEditingController nameController = TextEditingController();
  TextEditingController rateController = TextEditingController();
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchCommodities();
  }

  @override
  void dispose() {
    nameController.dispose();
    rateController.dispose();
    searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchCommodities() async {
    setState(() {
      isLoading = true;
    });

    try {
      final commodities = ref.read(commodityNotifierProvider);
      // Only fetch if commodities are not already cached
      if (commodities.isEmpty) {
        await ref
            .read(commodityNotifierProvider.notifier)
            .fetchCommodities(ref);
      }
    } catch (error) {
      print('Error fetching commodities: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching commodities')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showCommodityDialog(BuildContext context, {Commodity? commodity}) {
    nameController.text = commodity?.name ?? '';
    rateController.text = commodity?.rate.toString() ?? '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(commodity == null
              ? 'Add Commodity\'s Rate'
              : 'Edit Commodity\'s '),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Commodity Name'),
                ),
                SizedBox(height: 12.0),
                TextField(
                  controller: rateController,
                  decoration: InputDecoration(labelText: 'Rate'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final rateText = rateController.text.trim();
                final double? rate = double.tryParse(rateText);

                // Rate Validation
                if (rate == null || rate <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            'Rate must be a numeric value greater than 0.')),
                  );
                  return;
                }

                // Uniqueness Check
                final existingCommodities = ref.read(
                    commodityNotifierProvider); // Assuming it holds the list
                final isDuplicate = existingCommodities.any(
                    (existingCommodity) =>
                        existingCommodity.name.toLowerCase() ==
                            name.toLowerCase() &&
                        (commodity == null ||
                            existingCommodity.id != commodity.id));

                if (isDuplicate) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Commodity name must be unique.')),
                  );
                  return;
                }

                try {
                  if (commodity == null) {
                    await ref
                        .read(commodityNotifierProvider.notifier)
                        .createCommodity(
                          ref,
                          Commodity(id: '', name: name, rate: rate),
                        );
                  } else {
                    await ref
                        .read(commodityNotifierProvider.notifier)
                        .updateCommodity(
                          ref,
                          commodity.id,
                          Commodity(id: commodity.id, name: name, rate: rate),
                        );
                  }

                  _fetchCommodities();
                  Navigator.of(context).pop();
                } catch (error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            'Error ${commodity == null ? 'adding' : 'updating'} commodity.')),
                  );
                }
              },
              child: Text(commodity == null ? 'Add' : 'Save'),
            ),
          ],
        );
      },
    );
  }

  List<Commodity> _filterCommodities(List<Commodity> commodities) {
    final query = searchController.text.toLowerCase();
    return commodities.where((commodity) {
      return commodity.name.toLowerCase().contains(query) ||
          commodity.rate.toString().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final commodities = ref.watch(commodityNotifierProvider);

    final filteredCommodities = _filterCommodities(commodities);

    return Scaffold(
      appBar: AppBar(title: Text('Commodities')),
      body: Stack(
        children: [
          Container(color: Colors.grey[100]),
          if (isLoading)
            CustomLoadingIndicator()
          else
            RefreshIndicator(
              onRefresh: _fetchCommodities,
              child: Column(
                children: [
                  CustomSearchBar(
                    controller: searchController,
                    hintText: 'Search by name or rate',
                    onChanged: (value) {
                      setState(() {});
                    },
                    onClear: () {
                      setState(() {
                        searchController.clear();
                      });
                    },
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      itemCount: filteredCommodities.length,
                      itemBuilder: (context, index) {
                        final commodity = filteredCommodities[index];
                        return CustomListTile(
                          title: commodity.name,
                          subtitle:
                              'Rate: ${NumberFormat('#,##0.00').format(commodity.rate)}',
                          onEdit: () => _showCommodityDialog(context,
                              commodity: commodity),
                          onDelete: () {
                            ref
                                .read(commodityNotifierProvider.notifier)
                                .deleteCommodity(ref, commodity.id);
                          },
                        );
                      },
                      cacheExtent: 300,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCommodityDialog(context),
        child: Icon(Icons.add),
      ),
    );
  }
}
