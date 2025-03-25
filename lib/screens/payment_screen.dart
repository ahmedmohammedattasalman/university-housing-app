import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:universityhousing/constants/colors.dart';
import 'package:universityhousing/providers/auth_provider.dart';
import 'package:universityhousing/widgets/custom_button.dart';
import 'package:universityhousing/widgets/custom_text_field.dart';
import 'package:fluttertoast/fluttertoast.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  // Payment info controllers
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _cardNameController = TextEditingController();
  final TextEditingController _cardExpiryController = TextEditingController();
  final TextEditingController _cardCvvController = TextEditingController();
  final TextEditingController _amountController =
      TextEditingController(text: '450.00');

  bool _isProcessing = false;
  String _selectedPaymentMethod = 'credit_card';

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

  Future<void> _processPayment() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isProcessing = true;
      });

      try {
        // In a real app, this would call a payment API
        await Future.delayed(const Duration(seconds: 2)); // Simulate API call

        if (mounted) {
          Fluttertoast.showToast(
            msg: "Payment processed successfully!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: AppColors.successColor,
            textColor: Colors.white,
          );

          // Reset form and switch to history tab
          _formKey.currentState!.reset();
          _tabController.animateTo(1); // Switch to history tab
        }
      } catch (e) {
        if (mounted) {
          Fluttertoast.showToast(
            msg: "Payment processing failed",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: AppColors.errorColor,
            textColor: Colors.white,
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isProcessing = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payments'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Make Payment'),
            Tab(text: 'Payment History'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPaymentForm(),
          _buildPaymentHistory(),
        ],
      ),
    );
  }

  Widget _buildPaymentForm() {
    final authProvider = Provider.of<AuthProvider>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Payment amount
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Payment Details',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.account_balance, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text('Student: ${authProvider.studentName}'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.home, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text('Room: ${authProvider.roomNumber}'),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Amount to Pay',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    CustomTextField(
                      controller: _amountController,
                      labelText: 'Amount (\$)',
                      prefixIcon: Icons.attach_money,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+\.?\d{0,2}')),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an amount';
                        }
                        final amount = double.tryParse(value);
                        if (amount == null || amount <= 0) {
                          return 'Please enter a valid amount';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Payment For',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.home, color: AppColors.primaryColor),
                          const SizedBox(width: 8),
                          const Text(
                            'Housing Fee - April 2023',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Payment method selection
            const Text(
              'Payment Method',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),

            // Payment method radio buttons
            RadioListTile<String>(
              title: const Row(
                children: [
                  Icon(Icons.credit_card),
                  SizedBox(width: 12),
                  Text('Credit/Debit Card'),
                ],
              ),
              value: 'credit_card',
              groupValue: _selectedPaymentMethod,
              onChanged: (value) {
                setState(() {
                  _selectedPaymentMethod = value!;
                });
              },
            ),
            RadioListTile<String>(
              title: const Row(
                children: [
                  Icon(Icons.account_balance),
                  SizedBox(width: 12),
                  Text('Bank Transfer'),
                ],
              ),
              value: 'bank_transfer',
              groupValue: _selectedPaymentMethod,
              onChanged: (value) {
                setState(() {
                  _selectedPaymentMethod = value!;
                });
              },
            ),
            RadioListTile<String>(
              title: const Row(
                children: [
                  Icon(Icons.paypal),
                  SizedBox(width: 12),
                  Text('PayPal'),
                ],
              ),
              value: 'paypal',
              groupValue: _selectedPaymentMethod,
              onChanged: (value) {
                setState(() {
                  _selectedPaymentMethod = value!;
                });
              },
            ),
            const SizedBox(height: 20),

            // Credit Card Form
            if (_selectedPaymentMethod == 'credit_card') ...[
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Card Details',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Card Number
                      CustomTextField(
                        controller: _cardNumberController,
                        labelText: 'Card Number',
                        prefixIcon: Icons.credit_card,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(16),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your card number';
                          }
                          if (value.length < 16) {
                            return 'Card number must be 16 digits';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Cardholder Name
                      CustomTextField(
                        controller: _cardNameController,
                        labelText: 'Cardholder Name',
                        prefixIcon: Icons.person,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the cardholder name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Expiry Date and CVV
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              controller: _cardExpiryController,
                              labelText: 'Expiry (MM/YY)',
                              prefixIcon: Icons.calendar_today,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(4),
                                _ExpiryDateInputFormatter(),
                              ],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Enter expiry date';
                                }
                                if (value.length < 5) {
                                  return 'Invalid expiry date';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: CustomTextField(
                              controller: _cardCvvController,
                              labelText: 'CVV',
                              prefixIcon: Icons.security,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(3),
                              ],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Enter CVV';
                                }
                                if (value.length < 3) {
                                  return 'Invalid CVV';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // Bank transfer instructions
            if (_selectedPaymentMethod == 'bank_transfer') ...[
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Bank Transfer Details',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildBankDetail(
                          'Account Name', 'University Housing Authority'),
                      _buildBankDetail('Bank', 'City National Bank'),
                      _buildBankDetail('Account Number', '4567890123'),
                      _buildBankDetail('Routing Number', '123456789'),
                      _buildBankDetail('Reference', authProvider.studentId),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.warningColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.warningColor),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info, color: AppColors.warningColor),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                'Please include your Student ID in the reference field when making a transfer.',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // PayPal instructions
            if (_selectedPaymentMethod == 'paypal') ...[
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PayPal',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                          'You will be redirected to PayPal to complete your payment securely.'),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 30),

            // Payment button
            _isProcessing
                ? const Center(child: CircularProgressIndicator())
                : CustomButton(
                    text: 'Pay Now \$${_amountController.text}',
                    onPressed: _processPayment,
                  ),
            const SizedBox(height: 16),

            // Cancel button
            CustomButton(
              text: 'Cancel',
              backgroundColor: Colors.grey[200],
              textColor: Colors.black87,
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBankDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
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
                    child: Icon(
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
                        style: TextStyle(
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
                        child: Text(
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
