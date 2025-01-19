import 'package:agriproduce/data_models/companyInfo.dart';
import 'package:agriproduce/state_management/companyInfo_provider.dart';
import 'package:agriproduce/widgets/custom_list_tile.dart';
import 'package:agriproduce/widgets/custom_loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agriproduce/widgets/custom_search_bar.dart';

class CompanyInfoScreen extends ConsumerStatefulWidget {
  const CompanyInfoScreen({super.key});

  @override
  _CompanyInfoScreenState createState() => _CompanyInfoScreenState();
}

class _CompanyInfoScreenState extends ConsumerState<CompanyInfoScreen> {
  bool isLoading = false;
  TextEditingController nameController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchCompanyInfos();
  }

  @override
  void dispose() {
    nameController.dispose();
    addressController.dispose();
    phoneController.dispose();
    emailController.dispose();
    searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchCompanyInfos() async {
    setState(() {
      isLoading = true;
    });

    try {
      final companyInfos = ref.read(companyInfoNotifierProvider);
      if (companyInfos.isEmpty) {
        await ref
            .read(companyInfoNotifierProvider.notifier)
            .fetchCompanyInfos(ref);
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching company infos')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showCompanyInfoDialog(BuildContext context,
      {CompanyInfo? companyInfo}) {
    nameController.text = companyInfo?.name ?? '';
    addressController.text = companyInfo?.address ?? '';
    phoneController.text = companyInfo?.phone ?? '';
    emailController.text = companyInfo?.email ?? '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    companyInfo == null
                        ? 'Add Company Info'
                        : 'Edit Company Info',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildTextField(nameController, 'Company Name'),
                  SizedBox(height: 12),
                  _buildTextField(addressController, 'Address'),
                  SizedBox(height: 12),
                  _buildTextField(phoneController, 'Phone'),
                  SizedBox(height: 12),
                  _buildTextField(emailController, 'Email'),
                  SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child:
                            Text('Cancel', style: TextStyle(color: Colors.red)),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          final name = nameController.text.trim();
                          final address = addressController.text.trim();
                          final phone = phoneController.text.trim();
                          final email = emailController.text.trim();

                          if (name.isEmpty ||
                              address.isEmpty ||
                              phone.isEmpty ||
                              email.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('All fields are required')),
                            );
                            return;
                          }

                          try {
                            if (companyInfo == null) {
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
                            } else {
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
                            }
                            _fetchCompanyInfos();
                            Navigator.of(context).pop();
                          } catch (error) {
                            print(
                                'Error ${companyInfo == null ? 'adding' : 'updating'} company info: $error');
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'Error ${companyInfo == null ? 'adding' : 'updating'} company info')),
                            );
                          }
                        },
                        child: Text(companyInfo == null ? 'Add' : 'Save'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  TextField _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  List<CompanyInfo> _filterCompanyInfos(List<CompanyInfo> companyInfos) {
    final query = searchController.text.toLowerCase();
    return companyInfos.where((companyInfo) {
      return companyInfo.name.toLowerCase().contains(query) ||
          companyInfo.address.toLowerCase().contains(query) ||
          companyInfo.phone.toLowerCase().contains(query) ||
          companyInfo.email.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final companyInfos = ref.watch(companyInfoNotifierProvider);

    final filteredCompanyInfos = _filterCompanyInfos(companyInfos);

    return Scaffold(
      appBar: AppBar(
        title: Text('Company Info', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        
      ),
      body: Stack(
        children: [
          Container(color: Colors.grey[100]),
          if (isLoading)
            CustomLoadingIndicator()
          else
            RefreshIndicator(
              onRefresh: _fetchCompanyInfos,
              child: Column(
                children: [
                  CustomSearchBar(
                    controller: searchController,
                    hintText: 'Search by name, address, phone or email',
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
                      itemCount: filteredCompanyInfos.length,
                      itemBuilder: (context, index) {
                        final companyInfo = filteredCompanyInfos[index];
                        return CustomListTile(
                          title: companyInfo.name,
                          subtitle:
                              'Address: ${companyInfo.address}\nPhone: ${companyInfo.phone}\nEmail: ${companyInfo.email}',
                          onEdit: () => _showCompanyInfoDialog(context,
                              companyInfo: companyInfo),
                          onDelete: () {
                            ref
                                .read(companyInfoNotifierProvider.notifier)
                                .deleteCompanyInfo(ref, companyInfo.id);
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
        onPressed: () => _showCompanyInfoDialog(context),
        backgroundColor: Colors.deepPurple,
        child: Icon(Icons.add),
      ),
    );
  }
}
