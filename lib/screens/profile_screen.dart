import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/business_profile_provider.dart';
import '../models/business_profile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _shopNameController = TextEditingController();
  final _tinController = TextEditingController();
  final _categoryController = TextEditingController();
  final _yearsOperatingController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _locationController = TextEditingController();
  final _vatRateController = TextEditingController(text: '18.0');
  final _invoiceFooterController = TextEditingController();
  final _dailyTargetController = TextEditingController();
  final _savingsPercentageController = TextEditingController();
  
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfile();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadProfile() {
    final provider = Provider.of<BusinessProfileProvider>(context, listen: false);
    final profile = provider.profile;
    if (profile != null) {
      _shopNameController.text = profile.shopName ?? '';
      _tinController.text = profile.tin ?? '';
      _categoryController.text = profile.category ?? '';
      _yearsOperatingController.text = profile.yearsOperating?.toString() ?? '';
      _phoneController.text = profile.phone ?? '';
      _emailController.text = profile.email ?? '';
      _locationController.text = profile.location ?? '';
      _vatRateController.text = profile.vatRate.toString();
      _invoiceFooterController.text = profile.invoiceFooter ?? '';
      _dailyTargetController.text = profile.dailyTarget?.toString() ?? '';
      _savingsPercentageController.text = profile.savingsPercentage?.toString() ?? '';
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<BusinessProfileProvider>(context, listen: false);
      final currentProfile = provider.profile;
      final profile = BusinessProfile(
        shopName: _shopNameController.text.isEmpty ? null : _shopNameController.text,
        tin: _tinController.text.isEmpty ? null : _tinController.text,
        category: _categoryController.text.isEmpty ? null : _categoryController.text,
        yearsOperating: _yearsOperatingController.text.isEmpty ? null : int.tryParse(_yearsOperatingController.text),
        phone: _phoneController.text.isEmpty ? null : _phoneController.text,
        email: _emailController.text.isEmpty ? null : _emailController.text,
        location: _locationController.text.isEmpty ? null : _locationController.text,
        vatRate: double.tryParse(_vatRateController.text) ?? 18.0,
        invoiceFooter: _invoiceFooterController.text.isEmpty ? null : _invoiceFooterController.text,
        dailyTarget: _dailyTargetController.text.isEmpty ? null : double.tryParse(_dailyTargetController.text),
        savingsPercentage: _savingsPercentageController.text.isEmpty ? null : double.tryParse(_savingsPercentageController.text),
        totalSavings: currentProfile?.totalSavings ?? 0.0,
        savingsStartDate: currentProfile?.savingsStartDate,
      );
      await provider.saveProfile(profile);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile saved successfully!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.storefront, size: 28),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('MY SHOP', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Consumer<BusinessProfileProvider>(
                  builder: (context, provider, child) {
                    if (provider.profile?.tin == null || provider.profile!.tin!.isEmpty) {
                      return Text(
                        'NO TIN SET',
                        style: TextStyle(color: Colors.orange[800], fontSize: 12),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'IDENTITY'),
            Tab(text: 'CONTACT'),
            Tab(text: 'COMPLIANCE'),
            Tab(text: 'GROWTH'),
            Tab(text: 'BACKUP'),
          ],
        ),
      ),
      body: Consumer<BusinessProfileProvider>(
        builder: (context, profileProvider, child) {
          return Form(
            key: _formKey,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildIdentityTab(),
                _buildContactTab(),
                _buildComplianceTab(),
                _buildGrowthTab(),
                _buildBackupTab(),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: _saveProfile,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Text('SAVE CHANGES', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildIdentityTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'BUSINESS IDENTITY',
            style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Basic information about your business',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _shopNameController,
            decoration: const InputDecoration(
              labelText: 'Shop Name',
              prefixIcon: Icon(Icons.storefront),
            ),
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            initialValue: _categoryController.text.isEmpty ? null : _categoryController.text,
            items: const [
              DropdownMenuItem(value: 'Retail', child: Text('Retail')),
              DropdownMenuItem(value: 'Wholesale', child: Text('Wholesale')),
              DropdownMenuItem(value: 'Restaurant', child: Text('Restaurant')),
              DropdownMenuItem(value: 'Hardware', child: Text('Hardware')),
              DropdownMenuItem(value: 'Pharmacy', child: Text('Pharmacy')),
              DropdownMenuItem(value: 'Other', child: Text('Other')),
            ],
            onChanged: (value) {
              setState(() {
                _categoryController.text = value ?? '';
              });
            },
            decoration: const InputDecoration(
              labelText: 'Business Category',
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _yearsOperatingController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Years in Operation',
              prefixIcon: Icon(Icons.calendar_today),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'CONTACT INFORMATION',
            style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'How customers can reach you',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Phone Number',
              prefixIcon: Icon(Icons.phone_android),
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email (Optional)',
              prefixIcon: Icon(Icons.email_outlined),
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _locationController,
            decoration: const InputDecoration(
              labelText: 'Business Address',
              prefixIcon: Icon(Icons.location_on_outlined),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComplianceTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'URA COMPLIANCE',
            style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Tax registration details for official receipts',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
          const SizedBox(height: 24),
          Consumer<BusinessProfileProvider>(
            builder: (context, provider, child) {
              if (provider.profile?.tin == null || provider.profile!.tin!.isEmpty) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF2196F3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Color(0xFF2196F3)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Enter your Tax Identification Number for URA compliance. This will appear on official receipts.',
                          style: TextStyle(color: Colors.blue[900], fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          TextFormField(
            controller: _tinController,
            decoration: const InputDecoration(
              labelText: 'TIN Number',
              prefixIcon: Icon(Icons.receipt_long_outlined),
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _vatRateController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'VAT Rate (%)',
              prefixIcon: Icon(Icons.percent),
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _invoiceFooterController,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Invoice Footer Text',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrowthTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'GROWTH MODE',
            style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Set goals for your business',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _dailyTargetController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Daily Target (UGX)',
              prefixIcon: Icon(Icons.trending_up_outlined),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'AUTOMATIC SAVINGS',
            style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Deduct a percentage from every sale automatically',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
          const SizedBox(height: 24),
          Consumer<BusinessProfileProvider>(
            builder: (context, provider, child) {
              final isSavingsActive = provider.profile?.savingsPercentage != null && provider.profile!.savingsPercentage! > 0;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isSavingsActive)
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF4CAF50)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Color(0xFF4CAF50)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Automatic savings are active! ${provider.profile!.savingsPercentage}% of every sale is saved.',
                              style: TextStyle(color: Colors.green[900], fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  TextFormField(
                    controller: _savingsPercentageController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Savings Percentage (%)',
                      prefixIcon: Icon(Icons.savings_outlined),
                      hintText: 'e.g., 5',
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final percentage = double.tryParse(_savingsPercentageController.text);
                            if (percentage != null && percentage > 0) {
                              await Provider.of<BusinessProfileProvider>(context, listen: false).activateSavings(percentage);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Savings activated!')),
                                );
                              }
                            } else {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Please enter a valid percentage!')),
                                );
                              }
                            }
                          },
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('ACTIVATE SAVINGS'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4CAF50),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                          ),
                        ),
                      ),
                      if (isSavingsActive)
                        const SizedBox(width: 12),
                      if (isSavingsActive)
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              await Provider.of<BusinessProfileProvider>(context, listen: false).deactivateSavings();
                              if (mounted) {
                                _savingsPercentageController.clear();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Savings deactivated!')),
                                );
                              }
                            },
                            icon: const Icon(Icons.pause),
                            label: const Text('DEACTIVATE'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              side: const BorderSide(color: Colors.red, width: 2),
                              foregroundColor: Colors.red,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBackupTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'DATA & BACKUP',
            style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Protect your business data with regular backups',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber, color: Color(0xFFFF9800)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Regular backups protect your data from loss. Export your data frequently and store it safely.',
                    style: TextStyle(color: Colors.orange[900], fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.download_outlined),
                  label: const Text('EXPORT DATA'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.upload_outlined),
                  label: const Text('IMPORT DATA'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    side: const BorderSide(color: Colors.black, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Consumer<BusinessProfileProvider>(
                builder: (context, provider, child) {
                  final totalSaved = provider.profile?.totalSavings ?? 0.0;
                  final formattedSaved = NumberFormat('#,###').format(totalSaved);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'DATA SUMMARY',
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildDataRow('Business Profile', provider.profile != null ? 'Configured' : 'Not Set'),
                      const SizedBox(height: 12),
                      _buildDataRow('Growth Mode', provider.profile?.dailyTarget != null ? 'Active' : 'Inactive'),
                      const SizedBox(height: 12),
                      _buildDataRow('Total Saved', 'UGX $formattedSaved'),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey[600], fontSize: 16),
        ),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    );
  }
}
