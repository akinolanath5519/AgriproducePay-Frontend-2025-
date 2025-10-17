import 'package:agriproduce/utilis/snack_bar.dart';
import 'package:agriproduce/widgets/custom_text_field.dart';
import 'package:agriproduce/widgets/custom_list_tile.dart';
import 'package:agriproduce/widgets/custom_search_bar.dart';
import 'package:agriproduce/theme/app_theme.dart';
import 'package:agriproduce/data_models/companyInfo.dart';
import 'package:agriproduce/state_management/companyInfo_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';

class CompanyInfoScreen extends ConsumerStatefulWidget {
  const CompanyInfoScreen({super.key});

  @override
  _CompanyInfoScreenState createState() => _CompanyInfoScreenState();
}

class _CompanyInfoScreenState extends ConsumerState<CompanyInfoScreen> {
  bool isLoading = false;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchCompanyInfos();
  }

  Future<void> _fetchCompanyInfos() async {
    setState(() => isLoading = true);
    try {
      final companyInfos = ref.read(companyInfoNotifierProvider);
      if (companyInfos.isEmpty) {
        await ref
            .read(companyInfoNotifierProvider.notifier)
            .fetchCompanyInfos(ref);
      }
    } catch (error) {
      showErrorSnackbar(context, 'Error fetching company info: $error');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showCompanyInfoDialog(BuildContext context, {CompanyInfo? companyInfo}) {
  final theme = Theme.of(context);
  final isEditing = companyInfo != null;

  final nameController = TextEditingController(text: companyInfo?.name);
  final addressController = TextEditingController(text: companyInfo?.address);
  final phoneController = TextEditingController(text: companyInfo?.phone);
  final emailController = TextEditingController(text: companyInfo?.email);

  bool isSaving = false;

  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setStateDialog) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: theme.mediumBorderRadius,
          ),
          title: Text(
            isEditing ? 'Edit Company Info' : 'Add Company Info',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460), // ✅ width limit
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomTextField(
                    controller: nameController,
                    label: 'Company Name',
                    prefixIcon: Icons.business,
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: addressController,
                    label: 'Address',
                    prefixIcon: Icons.location_on_outlined,
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: phoneController,
                    label: 'Phone',
                    keyboardType: TextInputType.phone,
                    prefixIcon: Icons.phone,
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: emailController,
                    label: 'Email',
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.email_outlined,
                  ),
                  if (isSaving)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(
                          theme.colorScheme.primary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: theme.mediumBorderRadius,
                ),
              ),
              onPressed: isSaving
                  ? null
                  : () async {
                      final name = nameController.text.trim();
                      final address = addressController.text.trim();
                      final phone = phoneController.text.trim();
                      final email = emailController.text.trim();

                      if ([name, address, phone, email].any((v) => v.isEmpty)) {
                        showErrorSnackbar(context, 'All fields are required');
                        return;
                      }

                      setStateDialog(() => isSaving = true);

                      try {
                        if (isEditing) {
                          await ref
                              .read(companyInfoNotifierProvider.notifier)
                              .updateCompanyInfo(
                                ref,
                                companyInfo.id,
                                CompanyInfo(
                                  id: companyInfo.id,
                                  name: name,
                                  address: address,
                                  phone: phone,
                                  email: email,
                                ),
                              );
                          showSuccessSnackbar(
                              context, 'Company info updated successfully!');
                        } else {
                          await ref
                              .read(companyInfoNotifierProvider.notifier)
                              .createCompanyInfo(
                                ref,
                                CompanyInfo(
                                  id: '',
                                  name: name,
                                  address: address,
                                  phone: phone,
                                  email: email,
                                ),
                              );
                          showSuccessSnackbar(
                              context, 'Company info added successfully!');
                        }

                        await _fetchCompanyInfos();
                        Navigator.of(context).pop();
                      } catch (error) {
                        showErrorSnackbar(context, 'Error saving info: $error');
                      } finally {
                        setStateDialog(() => isSaving = false);
                      }
                    },
              child: Text(
                isEditing ? 'Save' : 'Add',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    ),
  );
}

  List<CompanyInfo> _filterCompanyInfos(List<CompanyInfo> companyInfos) {
    final query = searchController.text.toLowerCase();
    return companyInfos.where((info) {
      return info.name.toLowerCase().contains(query) ||
          info.address.toLowerCase().contains(query) ||
          info.phone.toLowerCase().contains(query) ||
          info.email.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final companyInfos = ref.watch(companyInfoNotifierProvider);
    final filtered = _filterCompanyInfos(companyInfos);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Company Info'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: AppBackground(
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _fetchCompanyInfos,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: CustomSearchBar(
                    controller: searchController,
                    hintText: 'Search by name, address, phone, or email',
                    onChanged: (_) => setState(() {}),
                    onClear: () {
                      searchController.clear();
                      setState(() {});
                    },
                  ),
                ),
                Expanded(
                  child: isLoading
                      ? _buildShimmerList()
                      : filtered.isEmpty
                          ? Center(
                              child: Text(
                                'No company info found',
                                style: AppText.subtitle
                                    .copyWith(color: Colors.grey),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.only(bottom: 80),
                              itemCount: filtered.length,
                              itemBuilder: (context, i) {
                                final info = filtered[i];
                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: AppBorderRadius.medium,
                                    boxShadow: [AppShadows.subtle],
                                  ),
                                  child: CustomListTile(
                                    title: info.name,
                                    subtitle:
                                        'Address: ${info.address}\nPhone: ${info.phone}\nEmail: ${info.email}',
                                    onEdit: () => _showCompanyInfoDialog(
                                        context,
                                        companyInfo: info),
                                    onDelete: () async {
                                      try {
                                        await ref
                                            .read(companyInfoNotifierProvider
                                                .notifier)
                                            .deleteCompanyInfo(ref, info.id);
                                        showSuccessSnackbar(
                                            context, 'Deleted successfully');
                                        await _fetchCompanyInfos();
                                      } catch (error) {
                                        showErrorSnackbar(
                                            context, 'Error deleting: $error');
                                      }
                                    },
                                  ),
                                );
                              },
                            ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCompanyInfoDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppBorderRadius.medium,
          ),
        ),
      ),
    );
  }
}
