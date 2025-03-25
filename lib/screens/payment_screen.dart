import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:universityhousing/constants/colors.dart';
import 'package:universityhousing/providers/auth_provider.dart';
import 'package:universityhousing/widgets/custom_button.dart';
import 'package:universityhousing/widgets/custom_text_field.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:universityhousing/services/housing_service.dart';

class PaymentScreen extends StatefulWidget {
  final double? amountDue;
  final String? paymentFor;

  const PaymentScreen({
    super.key,
    this.amountDue,
    this.paymentFor,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final _housingService = HousingService();
  bool _isLoading = false;
  double _outstandingBalance = 0.0;

  // Payment info controllers
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _cardNameController = TextEditingController();
  final TextEditingController _cardExpiryController = TextEditingController();
  final TextEditingController _cardCvvController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  String _selectedPaymentMethod = 'Credit Card';
  String _selectedPaymentType = 'Housing Fee';

  // Payment method options
  final List<String> _paymentMethodOptions = [
    'Credit Card',
    'Debit Card',
    'Bank Transfer'
  ];

  // Payment type options
  final List<String> _paymentTypeOptions = [
    'Housing Fee',
    'Late Fee',
    'Damage Deposit',
    'Other'
  ];

  // Sample payment history data
  final List<Map<String, dynamic>> _paymentHistory = [
    {
      'id': 'PAY-1234',
      'date': DateTime.now().subtract(const Duration(days: 30)),
      'amount': 450.0,
      'status': 'completed',
      'type': 'Housing Fee - March 2023',
    },
    {
      'id': 'PAY-1235',
      'date': DateTime.now().subtract(const Duration(days: 60)),
      'amount': 450.0,
      'status': 'completed',
      'type': 'Housing Fee - February 2023',
    },
    {
      'id': 'PAY-1236',
      'date': DateTime.now().subtract(const Duration(days: 90)),
      'amount': 450.0,
      'status': 'completed',
      'type': 'Housing Fee - January 2023',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    if (widget.amountDue != null) {
      _amountController.text = widget.amountDue!.toStringAsFixed(2);
      _outstandingBalance = widget.amountDue!;
    } else {
      // In a real app, we would fetch the balance from the backend
      _outstandingBalance = 450.0;
    }

    if (widget.paymentFor != null) {
      _selectedPaymentType = widget.paymentFor!;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _cardNumberController.dispose();
    _cardNameController.dispose();
    _cardExpiryController.dispose();
    _cardCvvController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  String? _validateCardNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your card number';
    }

    // Remove spaces and check if it's a valid card number format
    final cardNumber = value.replaceAll(' ', '');
    if (cardNumber.length < 13 || cardNumber.length > 19) {
      return 'Card number must be between 13 and 19 digits';
    }

    if (!RegExp(r'^[0-9]+$').hasMatch(cardNumber)) {
      return 'Card number must contain only digits';
    }

    return null;
  }

  String? _validateExpiryDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter expiry date';
    }

    if (!RegExp(r'^(0[1-9]|1[0-2])\/([0-9]{2})$').hasMatch(value)) {
      return 'Please use MM/YY format';
    }

    final parts = value.split('/');
    final month = int.parse(parts[0]);
    final year = int.parse('20${parts[1]}');

    final expiryDate =
        DateTime(year, month + 1, 0); // Last day of the expiry month
    final currentDate = DateTime.now();

    if (expiryDate.isBefore(currentDate)) {
      return 'Card has expired';
    }

    return null;
  }

  String? _validateCVV(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter CVV';
    }

    if (!RegExp(r'^[0-9]{3,4}$').hasMatch(value)) {
      return 'CVV must be 3 or 4 digits';
    }

    return null;
  }

  Future<void> _processPayment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final amount = double.parse(_amountController.text);

      if (authProvider.user == null) {
        throw Exception('You must be logged in to make a payment');
      }

      // Generate a reference number for this payment
      final referenceNumber = 'PAY-${DateTime.now().millisecondsSinceEpoch}';

      await _housingService.initiatePayment(
        amount: amount,
        paymentMethod: _selectedPaymentMethod,
        paymentType: _selectedPaymentType,
        referenceNumber: referenceNumber,
        notes: 'Payment initiated from app',
      );

      // In a real app, you would integrate with a payment gateway here
      // For this example, we'll simulate a successful payment
      await Future.delayed(const Duration(seconds: 2));

      // Complete the payment (mark as successful)
      await _housingService.completePayment(
        paymentId: referenceNumber,
        isSuccessful: true,
      );

      // Update the local balance
      setState(() {
        _outstandingBalance = _outstandingBalance - amount;
        if (_outstandingBalance < 0) _outstandingBalance = 0;
      });

      if (mounted) {
        Fluttertoast.showToast(
          msg: 'Payment processed successfully!',
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );

        // Navigate back to previous screen
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        Fluttertoast.showToast(
          msg: 'Error processing payment: ${e.toString()}',
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Make a Payment'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Payment Summary Card
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Payment Summary',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Student: '),
                                Text(
                                  '${authProvider.user?.userMetadata?['first_name'] ?? ''} ${authProvider.user?.userMetadata?['last_name'] ?? ''}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Student ID: '),
                                Text(
                                  authProvider.user?.id ?? 'Unknown',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Divider(),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Outstanding Balance: '),
                                Text(
                                  currencyFormat.format(_outstandingBalance),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: _outstandingBalance > 0
                                        ? Colors.red
                                        : Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    Text(
                      'Payment Details',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),

                    // Payment Type dropdown
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Payment Type',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category),
                      ),
                      value: _selectedPaymentType,
                      items: _paymentTypeOptions.map((type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedPaymentType = value!;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a payment type';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Amount field
                    TextFormField(
                      controller: _amountController,
                      decoration: const InputDecoration(
                        labelText: 'Amount',
                        hintText: 'Enter payment amount',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an amount';
                        }
                        try {
                          final amount = double.parse(value);
                          if (amount <= 0) {
                            return 'Amount must be greater than zero';
                          }
                          return null;
                        } catch (e) {
                          return 'Please enter a valid amount';
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Payment Method dropdown
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Payment Method',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.payment),
                      ),
                      value: _selectedPaymentMethod,
                      items: _paymentMethodOptions.map((method) {
                        return DropdownMenuItem<String>(
                          value: method,
                          child: Text(method),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedPaymentMethod = value!;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a payment method';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    if (_selectedPaymentMethod.contains('Card')) ...[
                      Text(
                        'Card Information',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 16),

                      // Card Number field
                      TextFormField(
                        controller: _cardNumberController,
                        decoration: const InputDecoration(
                          labelText: 'Card Number',
                          hintText: '1234 5678 9012 3456',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.credit_card),
                        ),
                        keyboardType: TextInputType.number,
                        validator: _validateCardNumber,
                      ),
                      const SizedBox(height: 16),

                      // Cardholder Name field
                      TextFormField(
                        controller: _cardNameController,
                        decoration: const InputDecoration(
                          labelText: 'Cardholder Name',
                          hintText: 'John Doe',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter cardholder name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Row for Expiry Date and CVV
                      Row(
                        children: [
                          // Expiry Date field
                          Expanded(
                            child: TextFormField(
                              controller: _cardExpiryController,
                              decoration: const InputDecoration(
                                labelText: 'Expiry Date',
                                hintText: 'MM/YY',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.date_range),
                              ),
                              validator: _validateExpiryDate,
                            ),
                          ),
                          const SizedBox(width: 16),
                          // CVV field
                          Expanded(
                            child: TextFormField(
                              controller: _cardCvvController,
                              decoration: const InputDecoration(
                                labelText: 'CVV',
                                hintText: '123',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.security),
                              ),
                              obscureText: true,
                              keyboardType: TextInputType.number,
                              validator: _validateCVV,
                            ),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Security notice
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.security, color: Colors.green.shade800),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Your payment information is secure and encrypted. We do not store your card details.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Submit button
                    CustomButton(
                      text: 'Process Payment',
                      isLoading: _isLoading,
                      onPressed: _processPayment,
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildPaymentHistory() {
    final dateFormat = DateFormat('MMM dd, yyyy');

    return _paymentHistory.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.receipt_long,
                  size: 80,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No Payment History',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'You haven\'t made any payments yet',
                  style: TextStyle(
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _paymentHistory.length,
            itemBuilder: (context, index) {
              final payment = _paymentHistory[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                    child: const Icon(
                      Icons.receipt,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  title: Text(
                    payment['type'] as String,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('Payment ID: ${payment['id']}'),
                      Text(
                          'Date: ${dateFormat.format(payment['date'] as DateTime)}'),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${payment['amount'].toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.successColor,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.successColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'COMPLETED',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.successColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  isThreeLine: true,
                  onTap: () {
                    // TODO: Show payment details
                  },
                ),
              );
            },
          );
  }
}

class _ExpiryDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;

    if (text.length > 2) {
      return TextEditingValue(
        text: '${text.substring(0, 2)}/${text.substring(2)}',
        selection: TextSelection.collapsed(
          offset: text.length + 1,
        ),
      );
    }

    return newValue;
  }
}
