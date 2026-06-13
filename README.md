# Local POS - Uganda Retail Management System

A complete Point of Sale (POS) and business management system designed for Ugandan retailers, with MTN Mobile Money integration.

## Features

- 📱 **8 Main Screens**: Terminal (POS), Stock, Buy List, Reports, History, Debts, Expenditure, Profile
- 💳 **MTN Mobile Money Integration**: USSD-based payment processing
- 📊 **Analytics**: Sales reports, expense tracking, revenue charts
- 📦 **Inventory Management**: Stock tracking, low-stock alerts
- 💵 **Debt Tracking**: Customer credit management with WhatsApp reminders
- 📸 **Barcode Scanner**: Quick product addition via barcode
- 📝 **Local Storage**: Hive-based fast, offline data persistence
- 🎨 **Beautiful UI**: Material Design with Ugandan market focus

## Getting Started

### Prerequisites

1. Flutter SDK is already installed at: `C:\Users\DELL\Flutter\flutter`
2. Verify installation:
   ```powershell
   C:\Users\DELL\Flutter\flutter\bin\flutter.bat --version
   C:\Users\DELL\Flutter\flutter\bin\flutter.bat doctor
   ```

### Installation Steps

1. Open PowerShell and navigate to the project directory:
   ```powershell
   cd c:\Users\DELL\Documents\trae_projects\LOCAL_POS
   ```

2. Install dependencies:
   ```powershell
   C:\Users\DELL\Flutter\flutter\bin\flutter.bat pub get
   ```

3. Generate Hive Type Adapters:
   ```powershell
   C:\Users\DELL\Flutter\flutter\bin\flutter.bat packages pub run build_runner build
   ```

4. Run the app:
   ```powershell
   C:\Users\DELL\Flutter\flutter\bin\flutter.bat run
   ```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── product.dart
│   ├── transaction.dart
│   ├── debt.dart
│   ├── expense.dart
│   ├── purchase_order.dart
│   └── business_profile.dart
├── providers/                # State management
│   ├── product_provider.dart
│   ├── transaction_provider.dart
│   ├── debt_provider.dart
│   ├── expense_provider.dart
│   ├── purchase_order_provider.dart
│   └── business_profile_provider.dart
├── screens/                  # UI Screens
│   ├── terminal_screen.dart
│   ├── stock_screen.dart
│   ├── buy_list_screen.dart
│   ├── reports_screen.dart
│   ├── history_screen.dart
│   ├── debts_screen.dart
│   ├── expenditure_screen.dart
│   └── profile_screen.dart
└── widgets/                  # Reusable components
    ├── product_form_modal.dart
    ├── debt_form_modal.dart
    └── expense_form_modal.dart
```

## Key Technologies

- **Flutter**: Cross-platform UI framework
- **Hive**: Local NoSQL storage
- **Provider**: State management
- **mobile_scanner**: Barcode/QR code scanning
- **share_plus**: WhatsApp sharing
- **image_picker**: Receipt photo capture
- **fl_chart**: Data visualization
- **ussd_launcher**: MTN MoMo USSD integration

## Notes

- All data starts empty (no hardcoded demo data)
- Empty states guide users to add their first items
- Designed for UGX currency format
- MTN MoMo integration may require additional permissions on Android/iOS
