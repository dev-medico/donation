# Claude Code Development Summary

## Server Access Configuration

### SSH Access to Production Server
```bash
# Server: redjuniors.mooo.com (54.206.49.166)
# User: ubuntu
# Key: ~/.ssh/id_ed25519

ssh -i ~/.ssh/id_ed25519 ubuntu@54.206.49.166

# Pull latest backend changes:
cd /var/www/donation_backend && sudo git pull origin main

# Run Yii commands:
sudo php yii <command>
```

### Backend Deployment Steps
1. Commit and push changes to GitHub
2. SSH into server
3. Navigate to `/var/www/donation_backend`
4. Run `sudo git pull origin main`
5. If needed: `sudo php yii cache/flush-all`

### Database Management Commands
```bash
# Merge duplicate donors (run on server):
sudo php yii merge-donors/dry-run  # Preview what will be merged
sudo php yii merge-donors/merge    # Actually merge duplicates
sudo php yii merge-donors/find     # List potential duplicates
```

## Recent Changes Made

### 1. Donar List Screen API Optimization
- **Problem**: The donar list screen was making 24 API calls (12 for donors + 12 for expenses) when selecting a year
- **Solution**: 
  - Implemented lazy loading to fetch only the selected month's data
  - Added caching to prevent repeated API calls for previously viewed months
  - Reduced initial load to only current month data
  - Updated UI to be more compact and space-efficient

### 2. Dashboard Request Give Chart Implementation
- **Problem**: Request give chart showing 404 error in dashboard
- **Solution**:
  - Added `BloodRequestGiveChartScreen` to dashboard for both mobile and desktop layouts
  - Integrated with existing `/report/by-request-give` API endpoint
  - Added proper error handling and loading states

### 3. Request Give Data Management
- **Features Added**:
  - Floating action button in dashboard to add new request/give data
  - New `RequestGiveListScreen` for viewing all request/give records
  - Add/Edit dialog with date picker for request and give amounts
  - Integrated with existing `RequestGiveService` API

### 4. API Structure (Already Exists)
The following API endpoints are already implemented in the backend:
- `GET /request-give` - List all request/give records
- `POST /request-give/create` - Create new request/give record
- `GET /request-give/view/:id` - Get specific record
- `POST /request-give/update/:id` - Update record
- `POST /request-give/delete/:id` - Delete record
- `GET /report/by-request-give` - Get stats for chart

### 5. Files Modified/Created
#### Modified:
- `lib/src/features/dashboard/dashboard.dart` - Added chart and FAB
- `lib/src/features/dashboard/ui/dashboard_card.dart` - Added navigation to request give list
- `lib/src/features/donar/donar_list_screen.dart` - Optimized API calls

#### Created:
- `lib/src/features/finder/request_give_list_screen.dart` - New screen for managing request/give data

### 6. Performance Improvements
- **Before**: 24 API calls on year selection
- **After**: 1-2 API calls on initial load, additional calls only when needed
- **UI**: Reduced summary card height by ~40% for better space utilization

## How to Test
1. **Dashboard**: Open dashboard to see request/give chart and FAB button
2. **Add Data**: Click FAB or click on the chart itself to add new request/give records with month selection
3. **Chart Interaction**: The chart now shows a small add icon (12px) and is fully clickable without extra material wrapper
4. **View List**: Click on "သွေးတောင်းခံ/လှူဒါန်းမှု" card to see list screen
5. **Donar Screen**: Navigate to donar list to see optimized loading (only current month loads initially)

## Backend Implementation Status ✅
**Fixed 404 Error**: Added the missing `/report/by-request-give` endpoint to the backend.

### Backend Changes Made:
- **File**: `donation_backend/controllers/ReportController.php`
- **Added**: `actionByRequestGive()` method that:
  - Groups request/give data by month and year using SQL
  - Returns formatted chart data for frontend consumption
  - Follows existing API response format with `status: 'ok'` and `data` array

### Frontend Service Updates:
- **File**: `lib/src/features/services/request_give_service.dart`
- **Updated**: All API endpoints to match backend Yii2 routing conventions
- **Fixed**: Response parsing to handle backend's `status: 'ok'` format
- **Routes**: 
  - `GET /request-give/index` - List records
  - `GET /request-give/view?id=X` - Get single record
  - `POST /request-give/create` - Create record
  - `POST /request-give/update?id=X` - Update record
  - `POST /request-give/delete?id=X` - Delete record

### Testing Status:
- ✅ Backend endpoint implemented and committed
- ✅ Frontend services updated to match backend format
- ✅ Sample data exists in database (16 records from 2022-2024)
- ✅ PostgreSQL compatibility fixed (EXTRACT instead of YEAR/MONTH functions)
- ✅ Chart integration ready for testing

### Recent Fix:
**Database Error Resolved**: Fixed PostgreSQL compatibility issue
- **Error**: `SQLSTATE[42883]: Undefined function: YEAR(timestamp without time zone) does not exist`
- **Solution**: Updated SQL query to use `EXTRACT(YEAR FROM date)` instead of `YEAR(date)`
- **Commit**: `a005162` - PostgreSQL compatibility fix applied

The request give functionality should now work end-to-end with the backend API.

### Patient List Implementation (Latest)
**Problem**: Patient list functionality was not working properly
**Solution**: Implemented complete patient list feature with backend API and frontend integration

**Backend Implementation**:
- **File**: `donation_backend/controllers/DonationController.php`
- **New Endpoint**: `GET /donation/patient-list?page=X&limit=Y&q=SEARCH&order=desc`
- **Features**:
  - Groups donations by unique patient names
  - Returns latest donation info for each patient
  - Includes donation count per patient
  - Supports search by patient name, disease, hospital, or address
  - PostgreSQL-compatible with ILIKE for case-insensitive search
  - Includes member blood type information

**Frontend Implementation**:
- **Files Updated**:
  - `lib/src/features/patient/patient_list_screen.dart` - Main patient list screen with search
  - `lib/src/features/patient/models/patient.dart` - Patient data model
  - `lib/src/features/patient/providers/patient_provider.dart` - State management
  - `lib/src/features/services/patient_service.dart` - API service
  - `lib/src/features/dashboard/dashboard.dart` - Dashboard patient count display

- **Features Added**:
  - Paginated patient list with infinite scroll
  - Real-time search functionality
  - Patient card showing:
    - Name, age, address, disease
    - Hospital, blood group
    - Total donation count
    - Latest donation date
  - Tap on patient to view donation history
  - Floating action button to add new patient (redirects to new donation screen)
  - Dashboard integration showing total unique patient count

**Dashboard Integration**:
- **Backend**: Already had `/report/dashboard` endpoint with patient count
- **Frontend**: 
  - Added dashboard stats loading on init
  - Display total patient count in dashboard card
  - Uses existing report service for fetching stats

**API Response Format (Patient List)**:
```json
{
  "status": "ok",
  "data": [
    {
      "patient_name": "John Doe",
      "patient_age": "30",
      "patient_address": "Yangon",
      "patient_disease": "Anemia",
      "hospital": "General Hospital",
      "blood_group": "A+",
      "latest_id": 123,
      "latest_donation_date": "2024-01-15",
      "donation_count": 5
    }
  ],
  "total": 150,
  "page": 0,
  "limit": 20,
  "hasMore": true
}
```

**Testing Status**:
- ✅ Backend patient-list endpoint implemented
- ✅ Frontend patient list screen with search and pagination
- ✅ Dashboard shows total patient count
- ✅ Navigation to donation history and new donation
- ✅ PostgreSQL compatibility with ILIKE search

### Latest Updates:
**Chart Interaction Improvements**:
- **Month Picker**: Changed from specific date to month picker for better UX
- **Smaller Add Icon**: Reduced add button size to 12px with minimal padding 
- **Cleaner Design**: Removed redundant Material wrapper since chart is already in card
- **Consistent UX**: All add dialogs now use month picker (Dashboard, Chart, List screen)

### Blood Donation Report Fixes (Latest):
**Problem**: Blood donation reports by year/month were not working correctly
- **Backend Error**: Report endpoints weren't filtering by year/month parameters
- **Frontend Error**: `type 'Null' is not a subtype of type 'int'` due to field name mismatch

**Backend Fixes Applied**:
- **File**: `donation_backend/controllers/ReportController.php`
- **Changes**:
  - Added `$year` and `$month` parameters to all report methods (`actionByDisease`, `actionByGender`, `actionByBloodType`, `actionByHospital`)
  - Added PostgreSQL-compatible date filtering using `EXTRACT(YEAR/MONTH FROM donation_date)`
  - Fixed field name mapping: `patient_disease` → `name`, `quantity` → `count` for Flutter compatibility
  - Added null safety checks for percentage calculations (avoid division by zero)
  - Filtered total donations count to match the same year/month criteria

**Frontend Fixes Applied**:
- **File**: `lib/src/features/services/report_service.dart`
- **Changes**:
  - Updated all report methods to accept `year` and `month` parameters
  - Added query parameter building for API requests
  - Made parameters optional for backward compatibility

- **Files**: Chart components (`donation_chart_by_*.dart`)
- **Changes**:
  - Converted providers to `.family` providers to accept year/month parameters
  - Added year/month properties to all chart widgets
  - Added null safety checks for data parsing
  - Fixed type casting issues (`as int?` instead of `as int`)

- **File**: `lib/src/features/donation/blood_donation_report.dart`
- **Changes**:
  - Pass year and month parameters to all chart widgets
  - Handle yearly vs monthly filtering (month = null for yearly reports)
  - Convert month index to 1-based for backend (widget.month + 1)

**Testing Status**:
- ✅ Backend APIs now accept and filter by year/month parameters
- ✅ Flutter chart widgets receive filtered data for specific time periods
- ✅ Null safety issues resolved with proper type casting
- ✅ Field name mapping fixed between backend and frontend
- ✅ Report generation works for both yearly and monthly views

### Blood Donation Report Performance Optimization (Latest):
**Problem**: Multiple API calls causing slow loading times
- **Before**: 3 separate API calls (diseases, blood types, hospitals) + individual providers
- **After**: Single API call with all data combined

**Backend Optimization**:
- **File**: `donation_backend/controllers/ReportController.php`
- **New Endpoint**: `GET /report/donation-summary?year=X&month=Y`
- **Features**:
  - Single query with shared base filters for year/month
  - All chart data returned in one response (diseases, blood types, hospitals, gender stats)
  - Optimized database queries using query cloning
  - Proper data formatting for Flutter consumption

**Frontend Optimization**:
- **New File**: `lib/src/features/donation/donation_summary_widget.dart`
- **Features**:
  - Single provider call instead of 3 separate providers
  - Combined summary view with total donations count prominently displayed
  - Responsive design for mobile and desktop
  - Clean, card-based layout with proper spacing
  - Error handling and loading states

- **Updated File**: `lib/src/features/donation/blood_donation_report.dart`
- **Changes**:
  - Replaced individual chart widgets with single summary widget
  - Removed unnecessary imports and code
  - Simplified screen structure

**Performance Improvements**:
- **API Calls**: Reduced from 3 calls to 1 call (67% reduction)
- **Loading Time**: Significantly faster due to single database query
- **UI Responsiveness**: Immediate display of total count with detailed breakdown
- **Memory Usage**: Reduced provider overhead and state management
- **Data Consistency**: All data comes from same query ensuring consistency

**New API Response Format**:
```json
{
  "status": "ok",
  "data": {
    "totalDonations": 150,
    "diseases": [{"name": "Disease", "count": 10, "percentage": 6.7}],
    "bloodTypes": {"A (Rh +)": {"quantity": 30, "percentage": 20.0}},
    "hospitals": [{"hospital": "Hospital", "quantity": 25, "percentage": 16.7}],
    "genderStats": [{"patient_gender": "male", "quantity": 80, "percentage": 53}],
    "period": {"year": 2024, "month": 1}
  }
}
```

**Testing Status**:
- ✅ Single API call returns all report data
- ✅ Loading time dramatically improved
- ✅ UI shows total donations prominently
- ✅ Responsive design works on mobile and desktop
- ✅ Year and month filtering works correctly

### Corrected Implementation Approach (Final):
**Issue**: Initially modified existing dashboard functionality incorrectly
**Solution**: Reverted to proper approach - keeping existing functionality intact

**What Was Reverted**:
- ✅ **Dashboard charts**: Restored original `DonationChartByBlood()` and `DonationChartByHospital()` widgets
- ✅ **Existing APIs**: Kept original report endpoints working without parameters
- ✅ **Chart widgets**: Restored to original state without year/month parameters
- ✅ **Report service**: Kept original methods functioning as before

**What Remains Optimized**:
- ✅ **New API**: `/report/donation-summary` with year/month filtering  
- ✅ **Blood donation reports**: Use new optimized `DonationSummaryWidget`
- ✅ **Single API call**: Only for specific year/month blood donation reports
- ✅ **Backwards compatibility**: All existing functionality preserved

**Final Architecture**:
- **Dashboard/General Reports**: Use existing chart widgets and APIs (as before)
- **Blood Donation Year/Month Reports**: Use new optimized summary API and widget
- **Performance**: Optimized only where specifically needed (blood donation time-filtered reports)
- **Compatibility**: Zero breaking changes to existing functionality

**Result**: 
- Existing dashboard and general reports work exactly as before
- Blood donation reports by year/month are now optimized with single API call
- No disruption to current user workflows

### BloodDonationReportScreen Optimization (Latest):
**Problem**: BloodDonationReportScreen was making multiple API calls in loops
**Solution**: Created dedicated single API endpoint with comprehensive data

**New Backend API**:
- **Endpoint**: `GET /report/blood-donation-report?year=X&month=Y`
- **Features**:
  - Single query with all required data
  - Blood type statistics with counts and percentages
  - Disease statistics with counts and percentages  
  - Hospital statistics with counts and percentages
  - Monthly breakdown for yearly reports
  - Proper year/month filtering

**New Frontend Implementation**:
- **File**: `lib/src/features/donation/blood_donation_report_widget.dart`
- **Features**:
  - Single API call instead of multiple loops
  - Comprehensive data display with percentages
  - Monthly breakdown for yearly views
  - Enhanced error handling and loading states
  - Responsive design for mobile and desktop
  - Clean card-based layout

- **Updated**: `lib/src/features/donation/blood_donation_report.dart`
- **Changes**: Now uses `BloodDonationReportWidget` instead of `DonationSummaryWidget`

**API Response Format**:
```json
{
  "status": "ok",
  "data": {
    "totalDonations": 2792,
    "bloodTypes": [
      {"blood_type": "A (Rh +)", "count": 621, "percentage": 22.2},
      {"blood_type": "B (Rh +)", "count": 558, "percentage": 20.0}
    ],
    "diseases": [
      {"disease": "Heart Disease", "count": 89, "percentage": 3.2}
    ],
    "hospitals": [
      {"hospital": "General Hospital", "count": 156, "percentage": 5.6}
    ],
    "monthlyBreakdown": [
      {"month": 1, "count": 234},
      {"month": 2, "count": 267}
    ],
    "period": {"year": 2024, "month": null, "isYearly": true}
  }
}
```

**Performance Impact**:
- **API Calls**: Reduced from multiple loop calls to 1 single call
- **Loading Time**: Dramatically faster
- **Data Consistency**: All data from single query
- **User Experience**: Enhanced with monthly breakdown and percentages