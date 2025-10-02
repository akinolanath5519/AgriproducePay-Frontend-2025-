import 'dart:async';
import 'package:agriproduce/data_models/commodity_model.dart';
import 'package:agriproduce/state_management/commodity_provider.dart';
import 'package:agriproduce/utilis/snack_bar.dart';
import 'package:agriproduce/widgets/custom_list_tile.dart';
import 'package:agriproduce/widgets/custom_search_bar.dart';
import 'package:agriproduce/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

class CommodityScreen extends ConsumerStatefulWidget {
  const CommodityScreen({super.key});

  @override
  _CommodityScreenState createState() => _CommodityScreenState();
}

class _CommodityScreenState extends ConsumerState<CommodityScreen> {
  bool isLoading = false;
  bool isCreating = false;
  bool isUpdating = false;
  bool isDeleting = false;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController rateController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  Timer? _debounce;

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
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _fetchCommodities() async {
    setState(() => isLoading = true);

    try {
      final commodities = ref.read(commodityNotifierProvider);
      if (commodities.isEmpty) {
        await ref
            .read(commodityNotifierProvider.notifier)
            .fetchCommodities(ref);
      }
    } catch (error) {
      showErrorSnackbar(context, 'Error fetching commodities: $error');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () => setState(() {}));
  }

  void _showCommodityDialog(BuildContext context, {Commodity? commodity}) {
    final theme = Theme.of(context);
    nameController.text = commodity?.name ?? '';
    rateController.text = commodity?.rate.toString() ?? '';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setStateDialog) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: theme.mediumBorderRadius),
            title: Text(
              commodity == null
                  ? 'Add Commodity\'s Rate'
                  : 'Edit Commodity\'s Rate',
              style: theme.textTheme.titleLarge,
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Commodity Name',
                      border: OutlineInputBorder(
                          borderRadius: theme.mediumBorderRadius),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: rateController,
                    decoration: InputDecoration(
                      labelText: 'Rate',
                      border: OutlineInputBorder(
                          borderRadius: theme.mediumBorderRadius),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  if (isCreating || isUpdating)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation(theme.colorScheme.primary),
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Cancel',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: theme.mediumBorderRadius),
                ),
                onPressed: () async {
                  setStateDialog(() {
                    isCreating = commodity == null;
                    isUpdating = commodity != null;
                  });

                  final name = nameController.text.trim();
                  final double? rate =
                      double.tryParse(rateController.text.trim());

                  if (rate == null || rate <= 0) {
                    showErrorSnackbar(context, 'Rate must be greater than 0.');
                    setStateDialog(() {
                      isCreating = false;
                      isUpdating = false;
                    });
                    return;
                  }

                  final existingCommodities =
                      ref.read(commodityNotifierProvider);
                  final isDuplicate = existingCommodities.any(
                    (c) =>
                        c.name.toLowerCase() == name.toLowerCase() &&
                        (commodity == null || c.id != commodity.id),
                  );
                  if (isDuplicate) {
                    showErrorSnackbar(
                        context, 'Commodity name must be unique.');
                    setStateDialog(() {
                      isCreating = false;
                      isUpdating = false;
                    });
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
                    showSuccessSnackbar(
                      context,
                      commodity == null
                          ? 'Commodity added successfully!'
                          : 'Commodity updated successfully!',
                    );
                  } catch (_) {
                    showErrorSnackbar(context,
                        'Error ${commodity == null ? 'adding' : 'updating'} commodity.');
                  } finally {
                    setStateDialog(() {
                      isCreating = false;
                      isUpdating = false;
                    });
                  }
                },
                child: Text(
                  commodity == null ? 'Add' : 'Save',
                  style: theme.textTheme.labelLarge,
                ),
              ),
            ],
          );
        });
      },
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, String commodityId) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: theme.mediumBorderRadius),
          title: Text('Delete Commodity', style: theme.textTheme.titleLarge),
          content: Text(
            'Are you sure you want to delete this commodity\'s rate?',
            style: theme.textTheme.bodyLarge,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  )),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                shape: RoundedRectangleBorder(
                    borderRadius: theme.mediumBorderRadius),
              ),
              onPressed: () async {
                setState(() => isDeleting = true);
                try {
                  await ref
                      .read(commodityNotifierProvider.notifier)
                      .deleteCommodity(ref, commodityId);
                  _fetchCommodities();
                  Navigator.of(context).pop();
                  showSuccessSnackbar(
                      context, 'Commodity deleted successfully!');
                } catch (_) {
                  showErrorSnackbar(context, 'Error deleting commodity.');
                } finally {
                  setState(() => isDeleting = false);
                }
              },
              child: Text('Delete',
                  style: theme.textTheme.labelLarge
                      ?.copyWith(color: Colors.white)),
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
    final theme = Theme.of(context);
    final commodities = ref.watch(commodityNotifierProvider);
    final filteredCommodities = _filterCommodities(commodities);

    return Scaffold(
      appBar: AppBar(
        title: Text('Commodities',
            style: theme.textTheme.titleLarge?.copyWith(color: Colors.white)),
      ),
      body: Stack(
        children: [
          Container(color: theme.scaffoldBackgroundColor),
          if (isLoading)
            Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(color: Colors.white),
            )
          else
            RefreshIndicator(
              onRefresh: _fetchCommodities,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: CustomSearchBar(
                      controller: searchController,
                      hintText: 'Search by name or rate',
                      onChanged: _onSearchChanged,
                      onClear: () => setState(() => searchController.clear()),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      itemCount: filteredCommodities.length,
                      itemBuilder: (context, index) {
                        final commodity = filteredCommodities[index];
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: theme.mediumBorderRadius,
                            boxShadow: [theme.subtleShadow],
                          ),
                          child: CustomListTile(
                            title: commodity.name,
                            subtitle:
                                'Rate: ${NumberFormat('#,##0.00').format(commodity.rate)}',
                            onEdit: () => _showCommodityDialog(context,
                                commodity: commodity),
                            onDelete: () =>
                                _showDeleteConfirmDialog(context, commodity.id),
                          ),
                        );
                      },
                      cacheExtent: 300,
                    ),
                  ),
                ],
              ),
            ),
          if (isCreating || isUpdating || isDeleting)
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center(
                child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation(theme.colorScheme.primary)),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCommodityDialog(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
