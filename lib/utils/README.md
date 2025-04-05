# Utility Classes Documentation

## NRC Data Utility (`nrc_data.dart`)

This utility class provides comprehensive data for Myanmar's National Registration Card (NRC) system, helping implement NRC selection in forms.

### Key Features

- Complete list of state/region codes (၁-၁၄)
- Complete list of township codes for each state/region
- NRC type options (နိုင်, ဧည့်, ပြု, သ)
- Helper functions for generating the complete NRC string

### Usage

1. Import the utility:
```dart
import 'package:donation/utils/nrc_data.dart';
```

2. Access available NRC data:
```dart
// Get state codes
List<String> stateCodes = NrcData.nrc_initial_options;

// Get NRC types
List<String> nrcTypes = NrcData.nrc_type_options;

// Get township codes for a specific state
List<String> kachinTownships = NrcData.kachin;  // For state code "၁"

// Get township codes using the state code
List<String> townshipsForState = NrcData.stateToTownshipMap["၁၀"];  // For Mon State
```

3. Format complete NRC:
```dart
// Parameters: nrcType (0=normal, 1=MME), stateCode, townshipCode, nrcTypeCode, nrcNumber
String formattedNrc = NrcData.getCompleteNrc(0, "၁၀", "မလမ", "နိုင်", "123456");
// Output: "၁၀/မလမ(နိုင်)123456"

// For MME format
String formattedMmeNrc = NrcData.getCompleteNrc(1, "", "", "", "123456");
// Output: "MME-123456"
```

## Implementation Example

To implement the NRC selection in a form, see the member creation form in `lib/src/features/donation_member/presentation/member_list.dart` for a complete implementation example.
