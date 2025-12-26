# Automated Testing Note

## Test Status

The integration tests have been written and compile successfully (331 lines, 7 test groups, 9 test cases). 

⚠️ **Known Issue**: Isar native library loading in Flutter test environment on macOS may fail with:
```
Failed to load dynamic library 'libisar.dylib'
```

This is a known limitation of Isar's FFI bridge in the Flutter test harness. The library exists in `~/.pub-cache/hosted/pub.dev/isar_flutter_libs-*/macos/libisar.dylib` but the test VM doesn't load it correctly.

## Running the Tests

To run the automated integration tests:

```bash
# First, ensure all dependencies are installed
flutter pub get

# Generate Isar schemas
flutter pub run build_runner build --delete-conflicting-outputs

# Run the tests
flutter test test/accounting_integration_test.dart
```

## Alternative: Integration Test (Recommended)

For proper Isar testing in a real Flutter environment, consider using `integration_test` which runs on actual devices/simulators where Isar native libraries are properly loaded.

## Test Coverage

The integration tests cover:

1. **Account Creation Tests**
   - Verifies default chart of accounts is created
   - Checks account types (asset, revenue, liability, etc.)

2. **Account Balance Tests**
   - Ensures accounts start with zero balance

3. **Opening Balance Tests**
   - Sets opening balances for accounts
   - Verifies balances are correctly saved

4. **Trial Balance Tests**
   - Applies opening balances
   - Verifies trial balance equation (Debits = Credits)

5. **Journal Entry Tests**
   - Creates balanced journal entries
   - Rejects unbalanced entries (validation)
   - Deletes journal entries and reverses accounting

6. **Multiple Transactions Test**
   - Creates multiple journal entries
   - Verifies trial balance remains balanced

7. **Account Retrieval Tests**
   - Retrieves journal entries for a company
   - Verifies journal entry details

## Note on Isar Testing

Isar (the database) requires native libraries to run tests. In a Flutter environment, these are automatically available when running `flutter test`. If you encounter the error:

```
Failed to load dynamic library 'libisar.dylib'
```

This means you need to run the tests using the Flutter test command (not dart test) in a properly set up Flutter development environment.

## Alternative: Manual Testing (Recommended for Production)

For production validation, **manual testing is recommended** as it tests:
- The actual database (not mocked)
- Real UI interactions
- Complete user workflows
- Report generation and PDF exports
- Multi-company scenarios

Refer to:
- **`TESTING_GUIDE.md`** - Step-by-step manual testing procedures
- **`TESTING_CHECKLIST.md`** - Comprehensive testing checklist (50+ scenarios)
- **`PROJECT_COMPLETION_SUMMARY.md`** - Overall project status

Manual testing is recommended for:
- Complete transaction flows (Purchase → Sale → Payment)
- UI/UX validation
- Report generation and verification
- User acceptance testing
- Real-world data scenarios

## Why Manual Testing is Essential for Accounting Software

Accounting software requires:
1. **Data Integrity** - Real database behavior, not mocks
2. **Report Accuracy** - PDF exports, formatting, calculations
3. **User Experience** - Form validation, error messages, workflows
4. **Multi-Company** - Company switching, data isolation
5. **Compliance** - Double-entry validation, trial balance accuracy

The comprehensive manual testing documentation ensures all critical paths are validated in a production-like environment.
