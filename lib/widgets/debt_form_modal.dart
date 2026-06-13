import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/debt_provider.dart';
import '../models/debt.dart';

class DebtFormModal extends StatefulWidget {
  final Debt? debt;

  const DebtFormModal({super.key, this.debt});

  @override
  State<DebtFormModal> createState() => _DebtFormModalState();
}

class _DebtFormModalState extends State<DebtFormModal> {
  final _formKey = GlobalKey<FormState>();
  final _customerNameController = TextEditingController();
  final _customerPhoneController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime? _dueDate;

  @override
  void initState() {
    super.initState();
    if (widget.debt != null) {
      _customerNameController.text = widget.debt!.customerName;
      _customerPhoneController.text = widget.debt!.customerPhone ?? '';
      _amountController.text = widget.debt!.amount.toString();
      _notesController.text = widget.debt!.notes ?? '';
      _dueDate = widget.debt!.dueDate;
    }
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveDebt() async {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<DebtProvider>(context, listen: false);
      if (widget.debt != null) {
        final debt = widget.debt!;
        debt.customerName = _customerNameController.text;
        debt.customerPhone = _customerPhoneController.text.isEmpty ? null : _customerPhoneController.text;
        debt.amount = double.parse(_amountController.text);
        debt.notes = _notesController.text.isEmpty ? null : _notesController.text;
        debt.dueDate = _dueDate;
        await provider.updateDebt(debt);
      } else {
        final debt = Debt(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          customerName: _customerNameController.text,
          customerPhone: _customerPhoneController.text.isEmpty ? null : _customerPhoneController.text,
          amount: double.parse(_amountController.text),
          date: DateTime.now(),
          dueDate: _dueDate,
          notes: _notesController.text.isEmpty ? null : _notesController.text,
          payments: [],
        );
        await provider.addDebt(debt);
      }
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.debt != null ? 'Edit Debt' : 'Add New Debt'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _customerNameController,
                decoration: const InputDecoration(
                  labelText: 'Customer Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter a name' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _customerPhoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Customer Phone (optional)',
                  border: OutlineInputBorder(),
                  hintText: '077xxxxxxx',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Amount (UGX)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter an amount' : null,
              ),
              const SizedBox(height: 12),
              ListTile(
                title: const Text('Due Date (optional)'),
                subtitle: _dueDate != null
                    ? Text('${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}')
                    : null,
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    setState(() {
                      _dueDate = date;
                    });
                  }
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveDebt,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFC107),
            foregroundColor: Colors.black,
          ),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
