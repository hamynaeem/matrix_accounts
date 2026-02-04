# WhatsApp Integration for Matrix Accounts

This directory contains the WhatsApp API integration for Matrix Accounts, allowing users to share content directly to WhatsApp.

## Features

- **Share Text Messages**: Send plain text messages to WhatsApp
- **Share Files**: Share documents, images, and other files
- **Contact-Specific Sharing**: Share content to specific WhatsApp contacts
- **Business Card Sharing**: Share contact information in a formatted way
- **Invoice Sharing**: Share invoice details with professional formatting
- **Financial Report Sharing**: Share financial summaries and reports
- **Backup Notifications**: Share backup status notifications
- **Custom Accounting Utils**: Pre-built functions for common accounting operations

## Files Structure

```
lib/core/
├── services/
│   └── whatsapp_service.dart          # Main WhatsApp service
├── providers/
│   └── whatsapp_provider.dart         # Riverpod providers
├── widgets/
│   └── whatsapp_share_widgets.dart    # Reusable UI components
└── utils/
    └── whatsapp_accounting_utils.dart # Accounting-specific utilities

lib/features/shared/screens/
└── whatsapp_share_example_screen.dart # Example implementation
```

## Quick Start

### 1. Basic Text Sharing

```dart
// Using the service directly
final whatsappService = WhatsAppService();
await whatsappService.shareText('Hello from Matrix Accounts!');

// Using the widget
WhatsAppShareButton(
  text: 'Your message here',
  buttonText: 'Share to WhatsApp',
  onSuccess: () => print('Shared successfully!'),
)
```

### 2. Share to Specific Contact

```dart
await whatsappService.shareToContact(
  'Invoice details attached',
  '+1234567890', // Phone number with country code
);
```

### 3. Share Files

```dart
await whatsappService.shareFile(
  '/path/to/invoice.pdf',
  text: 'Here is your invoice',
);
```

### 4. Share Business Card

```dart
await whatsappService.shareBusinessCard(
  contactName: 'John Doe',
  phoneNumber: '+1234567890',
  email: 'john@example.com',
  organization: 'ABC Company',
);
```

### 5. Share Invoice (Accounting-specific)

```dart
import '../core/utils/whatsapp_accounting_utils.dart';

await WhatsAppAccountingUtils.shareDetailedInvoice(
  invoiceNumber: 'INV-2026-001',
  customerName: 'ABC Corp',
  subtotal: 1000.0,
  tax: 100.0,
  total: 1100.0,
  currency: '\$',
  dueDate: DateTime.now().add(Duration(days: 30)),
  items: [
    {
      'description': 'Service Fee',
      'quantity': 1,
      'unitPrice': 1000.0,
      'total': 1000.0,
    }
  ],
);
```

## UI Components

### WhatsAppShareButton

A customizable button for text sharing:

```dart
WhatsAppShareButton(
  text: 'Content to share',
  phoneNumber: '+1234567890', // Optional
  buttonText: 'Custom Button Text',
  icon: Icons.share,
  color: Colors.green,
  onSuccess: () {}, // Success callback
  onError: () {},   // Error callback
)
```

### WhatsAppFileShareButton

A button for file sharing:

```dart
WhatsAppFileShareButton(
  filePath: '/path/to/file.pdf',
  text: 'Optional accompanying text',
  buttonText: 'Share File',
)
```

### WhatsAppShareFAB

A floating action button for quick sharing:

```dart
WhatsAppShareFAB(
  text: 'Quick share content',
  onSuccess: () => print('Shared!'),
)
```

## Riverpod Integration

The service is integrated with Riverpod for state management:

```dart
// Get the service
final whatsappService = ref.read(whatsappServiceProvider);

// Check WhatsApp availability
final whatsappAvailable = ref.watch(whatsappAvailabilityProvider);
```

## Accounting-Specific Utilities

### Share Expense

```dart
await WhatsAppAccountingUtils.shareExpense(
  expenseId: 'EXP-001',
  amount: 250.0,
  currency: '\$',
  category: 'Office Supplies',
  description: 'Printer paper and ink',
  date: DateTime.now(),
);
```

### Share Financial Summary

```dart
await WhatsAppAccountingUtils.shareFinancialSummary(
  companyName: 'ABC Corp',
  month: DateTime.now(),
  totalIncome: 10000.0,
  totalExpenses: 6000.0,
  netProfit: 4000.0,
  currency: '\$',
  expensesByCategory: {
    'Office Supplies': 1000.0,
    'Marketing': 2000.0,
    'Utilities': 1500.0,
  },
);
```

### Share Party/Contact Information

```dart
await WhatsAppAccountingUtils.sharePartyInfo(
  partyName: 'ABC Supplier',
  partyType: 'Vendor',
  phone: '+1234567890',
  email: 'contact@abcsupplier.com',
  balance: 2500.0,
  currency: '\$',
);
```

## Error Handling

The service includes comprehensive error handling:

```dart
try {
  final success = await whatsappService.shareText('Message');
  if (success) {
    print('Shared successfully');
  } else {
    print('Sharing failed');
  }
} catch (e) {
  print('Error: $e');
}
```

## Platform Support

- **Android**: Full support with direct WhatsApp integration
- **iOS**: Full support with direct WhatsApp integration  
- **Web**: Falls back to system share dialog
- **Desktop**: Falls back to system share dialog

## Dependencies

The WhatsApp integration uses the following packages:

- `share_plus`: For cross-platform sharing functionality
- `flutter_riverpod`: For state management
- Standard Flutter packages (`dart:io`, `flutter/services`)

## Optional Enhancements

For enhanced functionality, you can add these dependencies to `pubspec.yaml`:

```yaml
dependencies:
  url_launcher: ^6.2.4  # For direct WhatsApp URL opening
  permission_handler: ^11.3.1  # For permissions management
```

## Example Screen

See `whatsapp_share_example_screen.dart` for a complete example of all functionality in action.

## Notes

- Phone numbers should include country codes (e.g., +1234567890)
- The service gracefully falls back to system sharing if WhatsApp is not available
- All sharing functions return a boolean indicating success/failure
- File paths should be absolute paths to existing files
- The service handles URL encoding automatically for special characters

## Future Enhancements

Potential future improvements:

1. **WhatsApp Business API**: Integration with WhatsApp Business API for automated messaging
2. **Template Messages**: Pre-defined message templates for common scenarios
3. **Contact Sync**: Sync WhatsApp contacts with app contacts
4. **Group Management**: Create and manage WhatsApp groups for team communication
5. **Status Updates**: Share to WhatsApp Status in addition to direct messages