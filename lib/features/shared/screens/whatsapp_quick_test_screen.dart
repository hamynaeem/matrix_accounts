import 'package:flutter/material.dart';
import '../../../core/services/whatsapp_service.dart';

/// Quick WhatsApp test screen for immediate testing
/// Add this to your app for easy WhatsApp functionality verification
class WhatsAppQuickTestScreen extends StatefulWidget {
  const WhatsAppQuickTestScreen({super.key});

  @override
  State<WhatsAppQuickTestScreen> createState() =>
      _WhatsAppQuickTestScreenState();
}

class _WhatsAppQuickTestScreenState extends State<WhatsAppQuickTestScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _messageController = TextEditingController(
    text:
        'Hello! This is a test message from Matrix Accounts app. 🚀\n\nWhatsApp integration is working perfectly!',
  );
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WhatsApp Test'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Card
            Card(
              color: Colors.green.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 48),
                    const SizedBox(height: 8),
                    Text(
                      'WhatsApp Integration Ready!',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.green.shade800,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Test the enhanced WhatsApp functionality below',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.green.shade600,
                          ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Phone Number Input
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Phone Number (Optional)',
                hintText: '+923001234567 or 03001234567',
                prefixIcon: Icon(Icons.phone),
                helperText: 'Leave empty for general WhatsApp share',
              ),
              keyboardType: TextInputType.phone,
            ),

            const SizedBox(height: 16),

            // Message Input
            TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Test Message',
                prefixIcon: Icon(Icons.message),
              ),
              maxLines: 4,
            ),

            const SizedBox(height: 24),

            // Test Buttons
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _testBasicShare,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.share),
              label: Text(_isLoading ? 'Testing...' : 'Test WhatsApp Share'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),

            const SizedBox(height: 12),

            OutlinedButton.icon(
              onPressed: _isLoading ? null : _testInvoiceShare,
              icon: const Icon(Icons.receipt),
              label: const Text('Test Invoice Share'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.green,
                side: const BorderSide(color: Colors.green),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),

            const SizedBox(height: 12),

            OutlinedButton.icon(
              onPressed: _isLoading ? null : _testBusinessCard,
              icon: const Icon(Icons.contact_page),
              label: const Text('Test Business Card'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.blue,
                side: const BorderSide(color: Colors.blue),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),

            const SizedBox(height: 24),

            // Instructions
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text(
                          'Testing Instructions',
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade800,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildInstruction('1.',
                        'Enter a phone number to test direct chat opening'),
                    _buildInstruction('2.',
                        'Leave phone empty to test general WhatsApp opening'),
                    _buildInstruction('3.',
                        'WhatsApp should open directly with message ready'),
                    _buildInstruction('4.',
                        'Check that the message is pre-filled and ready to send'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstruction(String number, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            number,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade700,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: Colors.blue.shade700),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _testBasicShare() async {
    setState(() => _isLoading = true);

    try {
      final whatsappService = WhatsAppService();
      final phoneNumber = _phoneController.text.trim();
      final message = _messageController.text.trim();

      final success = await whatsappService.shareText(
        message.isEmpty ? 'Hello from Matrix Accounts! 🚀' : message,
        phoneNumber: phoneNumber.isEmpty ? null : phoneNumber,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success
                ? '✅ WhatsApp opened successfully!'
                : '❌ Failed to open WhatsApp'),
            backgroundColor: success ? Colors.green : Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testInvoiceShare() async {
    setState(() => _isLoading = true);

    try {
      final whatsappService = WhatsAppService();
      final phoneNumber = _phoneController.text.trim();

      final success = await whatsappService.shareInvoice(
        invoiceNumber: 'TEST-${DateTime.now().millisecondsSinceEpoch}',
        amount: 1500.00,
        currency: 'Rs',
        customerName: 'Test Customer',
        customerPhone: phoneNumber.isEmpty ? null : phoneNumber,
        invoiceType: 'Test Invoice',
        additionalDetails:
            'Date: ${DateTime.now().toString().split(' ')[0]}\nTest invoice for WhatsApp functionality verification',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success
                ? '✅ Invoice test completed!'
                : '❌ Invoice test failed'),
            backgroundColor: success ? Colors.green : Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testBusinessCard() async {
    setState(() => _isLoading = true);

    try {
      final whatsappService = WhatsAppService();

      final success = await whatsappService.shareBusinessCard(
        contactName: 'John Doe',
        phoneNumber: '+923001234567',
        email: 'john.doe@example.com',
        organization: 'Matrix Accounts',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success
                ? '✅ Business card test completed!'
                : '❌ Business card test failed'),
            backgroundColor: success ? Colors.green : Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _messageController.dispose();
    super.dispose();
  }
}
