# Changelog

All notable changes to this project will be documented in this file.

## [1.0.6] - Unreleased

### Feature Enhancements
- Enhanced daily statistics bar chart interaction
  - Added full date information display when clicking on chart columns
  - Improved tooltip formatting with formatted amounts and income/expense type labels
- Implemented credential refresh option in sync settings for token renewal without data loss

## [1.0.5-beta.1] - 2025-09-02

### New Features
- Add webRTC video chat

## [1.0.4-alpha.2] - 2025-08-27

### Bug Fixes
- Bottom bar center “+” button: prevent taps on surrounding area from triggering expand/add; only the inner circular button responds

## [1.0.4-alpha.1] - 2025-08-27

### Feature Enhancements
- Daily statistics (Calendar) rebuilt with Syncfusion SfCalendar
  - Localized month/week labels; only current-month days shown
  - New income/expense multi-select toggles; calendar cells render amounts per selection
  - Visual polish: tighter cells, theme-adaptive colors, hidden overflow menu
- Items calendar switched to SfCalendar with markers; improved selection style and no build-phase setState
- Daily bar chart consolidated as `DailyStatisticBar` (unified card + chart)

### Tooling/Config
- Gradle 8.7, AGP 8.6.0, Kotlin 2.1.0; JDK 17 recommended
- l10n: removed deprecated synthetic-package option

## [1.0.3] - 2025-08-27

### Feature Enhancements
- Added UI Layout Configuration page with debt display toggle
  - New settings page accessible via "Mine" tab → "System Settings" → "UI Layout Settings"
  - Configurable debt information display in accounting page
- Added daily income/expense statistics feature
  - New daily statistics component (bar chart) with toggle between income and expense views
  - New daily statistics component (calendar view)
  - Configurable display options in UI settings
  - Integrated into accounting page with responsive chart visualization

## [1.0.2] - 2025-08-20

### Feature Enhancements
- New ItemsPage for displaying transactions by filter, using ItemsProvider for state management
- Route `AppRoutes.items` added, supports passing `BookMetaVO`, `ItemFilterDTO`, and optional `title`
- Statistics page category click now navigates to ItemsPage with category filter and the selected time range applied
- ItemsPage supports custom title (e.g., category name) and search; add button removed per design
- Category statistics card defaults to list view instead of pie chart
- Category, Fund, Merchant, Tag, and Project lists now support clicking an entry to navigate to ItemsPage with the corresponding filter applied
- CommonSimpleCrudList supports optional onItemTap callback for page-level navigation (kept generic; no business logic inside component)

### Bug Fixes
- Fixed initial flicker where statistics briefly showed an incorrect overall range before switching to monthly
- Ensured statistics load with a consistent initial time range (current month) and preserve the selected range

## [1.0.1] - 2025-08-12

### Feature Enhancements
- Add attachment_list_page to view attachments

## [1.0.0] - 2025-07-22

### Feature Enhancements
- Upgrade to v1.0.0
- Adapted to the latest Flutter version
- Optimized note group filter UI
- Fixed compatibility issues and improved overall stability

## [1.0.0-alpha.23] - 2024-07-20

### Feature Enhancements
- Statistics page: Only loads and displays data for the currently selected time range, avoiding duplicate/overlapping data loads
- Category statistics: Now displays the number of records (笔数) for each category in the list
- UI: Category pie chart and list are now merged into a single card with toggle switch for better user experience

### Bug Fixes
- Fixed issue where statistics page would briefly show monthly data then switch to all data
- Fixed duplicate data loading when switching books or time ranges

## [1.0.0-alpha.22] - 2025-07-14

### Feature Enhancements
- Statistics page: Time range selector refactored as an independent component, with improved Material 3 style and theme adaptation
- Statistics data now supports filtering by custom time range (all/year/month/week/custom)
- Optimized time range selector padding for a more compact layout

### Bug Fixes
- Calculator panel: Fixed bug where only the first operand could have a decimal, now both operands support decimals
- Calculator panel: Fixed floating-point precision issue when chaining operations (e.g., 1+2+3)

## [1.0.0-alpha.21] - 2025-07-13

### Feature Enhancements
- Enhanced note group filtering functionality
  - Added dynamic group filter component with multi-select support
  - Implemented automatic group list refresh when new groups are created
  - Added event-driven group list updates for real-time synchronization
  - Optimized group filter layout with wrap display for better space utilization

## [1.0.0-alpha.20] - 2025-07-02

### Feature Enhancements
- Added conditional rendering for tag badges with primary color styling

### Code Improvements
- Fixed syntax errors in conditional rendering logic
- Replaced deprecated `withOpacity` method calls with `withAlpha`
- Optimized layout structure for better maintainability
- Adjusted UI element order and spacing for improved visual hierarchy

## [1.0.0-alpha.19] - 2025-05-08

### Feature Enhancements
- Added a search bar to the `item_list_page` navigation bar, styled similarly to the `notes_tab`.
  - Integrated `CommonSearchField` for consistent design.
  - Enabled search functionality to filter items based on keywords.

### Code Improvements
- Refactored `item_list_page` to include search functionality and improve user experience.

## [1.0.0-alpha.18] - 2024-04-05

### Feature Enhancements
- Enhanced image preview functionality
  - Added semi-transparent background for better visual experience
  - Improved image preview controls and interactions
  - Enhanced error handling and loading states
  - Optimized image display performance

### Code Optimization
- Improved code structure and maintainability
  - Removed deprecated API usage
  - Enhanced error handling mechanisms
  - Optimized file operations

### Internationalization
- Added new translations for image preview actions
  - Save to gallery button text
  - Open with external app button text
  - Save success message
  - Error message handling

## [1.0.0-alpha.17] - 2024-04-04

### Feature Enhancements
- Enhanced QuillEditor image support
  - Added support for displaying uploaded images in QuillEditor
  - Integrated with attachment system for image handling
  - Improved image rendering and layout in editor
  - Enhanced user experience with visual feedback

## [1.0.0-alpha.16] - 2024-04-03

### Feature Enhancements
- Added attachment support for notes
  - Support uploading and managing multiple attachments in notes
  - Support viewing and deleting attachments
  - Support various file types including images and documents
  - Optimized attachment storage and retrieval mechanism

### Code Optimization
- Enhanced note attachment handling
  - Implemented efficient attachment state management
  - Added robust error handling for file operations
  - Improved attachment synchronization with backend
  - Optimized attachment upload and deletion process

### Enhancements
- Enhanced note editor functionality
  - Migrated note form state management to Provider pattern
  - Improved attachment handling with better error management
  - Optimized UI responsiveness and state updates

### Code Optimization
- Refactored note form page structure
  - Separated state management into dedicated provider
  - Enhanced code maintainability and reusability
  - Improved error handling and user feedback

## [1.0.0-alpha.15] - 2024-03-27

### Enhancements
- Enhanced data synchronization mechanism
  - Added automatic sync trigger for newly created transactions
  - Added automatic sync trigger for newly created notes
  - Added automatic sync trigger for newly created debts
  - Optimized sync state management to prevent duplicate syncs

### Bug Fixes
- Fixed sync service URL not taking effect immediately
  - Previously required app restart to apply changes
  - Now updates take effect as soon as the URL is modified

## [1.0.0-alpha.14] - 2024-03-20

### Enhancements
- Improved account type switching experience
  - Automatically convert amount to positive when switching from expense to income
  - Automatically convert amount to negative when switching from income to expense
  - Optimized amount conversion logic to maintain data consistency

## [1.0.0-alpha.13] - 2024-03-16

### Enhancements
- Optimized account display in transaction list
  - Display account name as a badge after category name
  - Limit account name to maximum 10 characters
  - Adjusted badge style with borders and lighter colors
  - Improved text alignment and spacing
- Enhanced attachment selection experience
  - Added image_picker for photo gallery selection
  - Optimized bottom menu style
  - Improved visual feedback following Material Design 3 guidelines

### Code Optimization
- Optimized ItemsContainer component layout structure
- Enhanced CommonAttachmentField component file selection functionality
- Improved code maintainability and reusability

## [1.0.0-alpha.12] - 2024-03-15

### Enhancements
- Improved attachment upload user experience
  - Fixed image selection issues on certain devices
  - Optimized file picker implementation
  - Enhanced file selection compatibility

### Code Optimization
- Enhanced CommonAttachmentField component implementation
  - Integrated image_picker for gallery selection
  - Utilized file_picker for file selection
  - Improved code maintainability

## [1.0.0-alpha.11] - 2025-03-12

### Bug Fixes
- Fixed transaction time resetting to 00:00 bug
- Fixed synchronization issue caused by null account type check

## [1.0.0-alpha.10] - 2025-03-11

### Code Refactoring
- Optimized data driver layer code structure
  - Reorganized LogDataDriver class methods by CRUD order (Create, Read, Update, Delete)
  - Grouped methods by business domain (User, Book, Transaction, Category, Merchant, Tag, Fund Account, Note, Debt)
  - Maintained consistent method order between LogDataDriver and BookDataDriver
  - Enhanced code readability and maintainability

## [1.0.0-alpha.9] - 2025-03-10

### Feature Enhancements
- Added refund functionality
  - Support refund operation for expense transactions
  - Automatically link refund records as income to original transactions
  - Optimized refund form with auto-filled original transaction information
  - Support modification of refund amount, account, and date

### UI Improvements
- Enhanced transaction edit page
  - Show refund button only for expense transactions
  - Improved form layout and interaction experience
- Optimized form components
  - Removed unnecessary Provider dependencies
  - Simplified component structure for better maintainability

### Code Quality Improvements
- Refactored RefundFormPage component
  - Removed nested components for simpler code structure
  - Optimized state management for better performance
  - Added error handling and user feedback
- Added event notification mechanism
  - Send event notifications after refund operations
  - Optimized data update process

### Framework Updates
- Upgraded Flutter to 3.29.1

## [1.0.0-alpha.8] - 2025-03-05

### Feature Optimization
- Refactored event handling system
  - Merged transaction/debt/note events into unified file
  - Added debt and transaction change event bus subscriptions
  - Improved event dispatch mechanism using database entity updates
  - Optimized event response process for better app responsiveness

- Enhanced UI component interaction
  - Optimized list container header with navigation support
  - Updated statistics card to show monthly data
  - Improved selection box filtering to avoid duplicate options
  - Enhanced form component interaction experience

- Code Quality Improvements
  - Split note form page save method into create/update
  - Added type-safe handling
  - Optimized data deletion process with validation
  - Improved code maintainability and readability

### Internationalization Improvements
- Added multilingual support for new texts like "Current Month"
- Updated Chinese/Traditional Chinese/English translations

### Bug Fixes
- Fixed duplicate "Add New" option in filtered selection boxes
- Fixed fund account selection logic
- Fixed symbol matching mechanism

## [1.0.0-alpha.7] - 2025-03-04

### Technical Improvements
- Enhanced statistics data management
  - Improved statistics data loading with event-driven auto-updates
  - Optimized data synchronization during book switching
  - Enhanced statistics data loading performance and reliability
  - Improved state management, reduced redundant code
  - Optimized memory usage, prevented memory leaks

- Improved category statistics list
  - Limited default display count for faster page loading
  - Added "View More" functionality
  - Supported customizable default display count
  - Added internationalization for "Collapse" and "View More"
  
- Enhanced statistics page layout
  - Added book statistics card showing total income, expenses, and balance
  - Optimized data loading for better page responsiveness
  - Improved state management for better code maintainability
  - Added time range selection for "Last Day", "This Month", and "All"
  - Optimized statistics card layout, adjusted expense and income display order

### Bug Fixes
- Fixed statistics data not loading during app initialization
- Fixed statistics not updating immediately when switching books

## [1.0.0-alpha.6] - 2025-03-03

### UI Improvements
- Comprehensive optimization of statistical charts
  - Replaced FL Chart with Syncfusion Flutter Charts
  - Implemented modern pie chart design
  - Added cool-toned tech-eco theme color scheme
  - Enhanced chart animations and interactions
  - Improved data label display

### Technical Improvements
- Enhanced version management
  - Used package_info_plus for dynamic version retrieval
  - Removed hardcoded version numbers
- Updated dependency versions
- Optimized code structure and performance

## [1.0.0-alpha.5] - 2025-03-03

### New Features
- Added category pie chart in statistics page
- Enhanced data visualization capabilities
- Added income and expense category statistics

### Improvements
- Optimized statistics data loading performance
- Enhanced empty state display
- Improved UI responsiveness

### Bug Fixes
- Fixed statistics calculation errors
- Fixed theme switching display issues
- Fixed missing internationalization texts

## [1.0.0-alpha.4] - 2025-03-02

### Changed
- Optimized BookStatisticCard component design and functionality
  - Added default display mode parameter
  - Updated date format
  - Removed toggle button for simpler design
  - Converted to StatelessWidget
  - Enhanced visual effects
  - Added internationalization support for total label

## [1.0.0-alpha.3] - 2024-03-01

### UI Improvements
- Enhanced debt container layout, highlighting receivable/payable amounts
- De-emphasized total amount display as secondary information
- Added debt progress bar for intuitive completion status
- Improved debt type labels and icons

### Feature Improvements
- Added automatic sync on app startup
- Enhanced number formatting with thousand separators
- Improved debt management workflow

### Bug Fixes
- Fixed Android signing configuration
- Fixed debt amount calculation
- Fixed various layout issues

## [1.0.0-alpha.2] - 2024-03-01

### New Features
- Added debt management
- Added multilingual support
- Added data backup and restore

### Improvements
- Enhanced user interface
- Improved application performance
- Enhanced data synchronization

### Bug Fixes
- Fixed book switching issues
- Fixed data import errors
- Fixed UI display anomalies

## [1.0.0-alpha.1] - 2024-03-01

### Initial Release
- Basic accounting functionality
- Multi-book management
- Data statistics and analysis
- Basic settings functionality