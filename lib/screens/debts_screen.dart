import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/debt_provider.dart';
import '../models/debt.dart';
import '../widgets/debt_form_modal.dart';

class DebtsScreen extends StatelessWidget {
  const DebtsScreen({super.key});

  Future<void> _sendWhatsAppReminder(BuildContext context, Debt debt) async {
    final message = 'Hello ${debt.customerName}, this is a reminder about your pending debt of UGX ${NumberFormat('#,###').format(debt.remainingAmount)}.';
    
    // Format phone number (remove leading 0, add 256)
    String? formattedPhone = debt.customerPhone;
    if (formattedPhone != null && formattedPhone.isNotEmpty) {
      if (formattedPhone.startsWith('0')) {
        formattedPhone = '256${formattedPhone.substring(1)}';
      } else if (!formattedPhone.startsWith('256')) {
        formattedPhone = '256$formattedPhone';
      }
      // Remove any non-digit characters
      formattedPhone = formattedPhone.replaceAll(RegExp(r'[^0-9]'), '');
    }
    
    final whatsappUrl = formattedPhone != null && formattedPhone.isNotEmpty
        ? Uri.parse('https://wa.me/$formattedPhone?text=${Uri.encodeComponent(message)}')
        : Uri.parse('https://wa.me/?text=${Uri.encodeComponent(message)}');
    
    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open WhatsApp')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DEBTORS LOG'),
        elevation: 0,
      ),
      body: Consumer<DebtProvider>(
        builder: (context, debtProvider, child) {
          final debts = debtProvider.debts;

          if (debts.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.money_off_outlined,
                        size: 100, color: Colors.grey[300]),
                    const SizedBox(height: 24),
                    Text('No outstanding debts',
                        style: TextStyle(fontSize: 20, color: Colors.grey[600], fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    Text('Add your first debt to get started',
                        style: TextStyle(fontSize: 14, color: Colors.grey[500])),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () => showDialog(
                        context: context,
                        builder: (context) => const DebtFormModal(),
                      ),
                      icon: const Icon(Icons.add),
                      label: const Text('ADD DEBT'),
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            children: [
              if (debtProvider.totalUnpaid > 0)
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.warning_amber, color: Colors.red),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'TOTAL UNPAID',
                              style: TextStyle(
                                color: Colors.red[800],
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'UGX ${NumberFormat('#,###').format(debtProvider.totalUnpaid)}',
                              style: TextStyle(
                                color: Colors.red[800],
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: debts.length,
                  itemBuilder: (context, index) {
                    final debt = debts[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        debt.customerName,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        DateFormat('MMM d, yyyy').format(debt.date),
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                        ),
                                      ),
                                      if (debt.notes != null) ...[
                                        const SizedBox(height: 8),
                                        Text(
                                          debt.notes!,
                                          style: TextStyle(
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'UGX ${NumberFormat('#,###').format(debt.remainingAmount)}',
                                      style: const TextStyle(
                                        color: Colors.red,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () => _sendWhatsAppReminder(context, debt),
                                    icon: const Icon(Icons.send),
                                    label: const Text('REMIND VIA WHATSAPP'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF25D366),
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => showDialog(
                                    context: context,
                                    builder: (context) => DebtFormModal(debt: debt),
                                  ),
                                  color: Colors.grey[600],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showDialog(
          context: context,
          builder: (context) => const DebtFormModal(),
        ),
        icon: const Icon(Icons.add),
        label: const Text('ADD DEBT'),
        backgroundColor: const Color(0xFFFFC107),
        foregroundColor: Colors.black,
      ),
    );
  }
}
