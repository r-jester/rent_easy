import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/property.dart';
import '../../providers/auth_provider.dart';
import '../../providers/payment_provider.dart';
import '../../providers/property_provider.dart';
import '../../utils/extensions.dart';
import '../../widgets/custom_button.dart';
import 'payment_success_screen.dart';

class FakePaymentScreen extends StatefulWidget {
  final Property property;

  const FakePaymentScreen({super.key, required this.property});

  @override
  State<FakePaymentScreen> createState() => _FakePaymentScreenState();
}

class _FakePaymentScreenState extends State<FakePaymentScreen> {
  String _selectedMethod = 'ABA Pay (Mock)';
  DateTime? _moveInDate;
  int _leaseMonths = 12;
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pay() async {
    final auth = context.read<AuthProvider>();
    final payment = await context.read<PaymentProvider>().processPayment(
          propertyId: widget.property.id,
          userId: auth.currentUserId ?? '',
          amount: widget.property.pricePerMonth,
          method: _selectedMethod,
        );

    if (payment.status == 'Success') {
      await context.read<PropertyProvider>().createBooking(
            propertyId: widget.property.id,
            renterId: auth.currentUserId ?? '',
            moveInDate: _moveInDate,
            leaseMonths: _leaseMonths,
            note: _noteController.text,
            paymentId: payment.id,
          );
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentSuccessScreen(payment: payment),
        ),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mock payment failed. Try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PaymentProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Fake Payment')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pay ${widget.property.pricePerMonth.toUsd()} for ${widget.property.title}',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 16),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Preferred Move-in Date'),
                          subtitle: Text(
                            _moveInDate == null
                                ? 'Not selected'
                                : '${_moveInDate!.day}/${_moveInDate!.month}/${_moveInDate!.year}',
                          ),
                          trailing: TextButton(
                            onPressed: () async {
                              final now = DateTime.now();
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: now.add(const Duration(days: 7)),
                                firstDate: now,
                                lastDate: now.add(const Duration(days: 365)),
                              );
                              if (picked != null) {
                                setState(() => _moveInDate = picked);
                              }
                            },
                            child: const Text('Select'),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text('Lease Term (months)'),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 8,
                          children: [6, 12, 18, 24]
                              .map(
                                (m) => ChoiceChip(
                                  label: Text('$m'),
                                  selected: _leaseMonths == m,
                                  onSelected: (_) => setState(() => _leaseMonths = m),
                                ),
                              )
                              .toList(),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _noteController,
                          minLines: 2,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Message to owner (optional)',
                            hintText: 'Tell owner your move-in preferences...',
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text('Select Payment Method'),
                        const SizedBox(height: 8),
                        ...const ['ABA Pay (Mock)', 'Wing (Mock)', 'Credit Card (Mock)']
                            .map(
                              (method) => RadioListTile<String>(
                                value: method,
                                groupValue: _selectedMethod,
                                onChanged: (value) =>
                                    setState(() => _selectedMethod = value!),
                                title: Text(method),
                              ),
                            ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                CustomButton(
                  label: 'Confirm Payment',
                  onPressed: _pay,
                  isBusy: provider.isProcessing,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
