# Kubera

Kubera is a modern, local-first personal finance app designed to help you track expenses, analyze spending, and gain meaningful insights into your financial habits, all while keeping your data completely private.

---

## Features

### Expense Tracking
- Add, edit, and manage transactions easily
- Support for income, expense, and transfers
- Recurring transactions support

---

### Smart Analytics
- Spending breakdown by category and group
- Budget vs actual insights
- Monthly comparisons and trends
- Transaction size distribution
- Tag-wise analytics

---

### Smart Insights
- Automatically generated financial insights such as:
  - Top spending categories
  - Weekday vs weekend spending patterns
  - Month-over-month comparisons
  - Savings trends

---

### Accounts Management
- Manage bank, cash, and credit accounts
- Track balances and credit utilization
- View last transaction activity per account

---

### Budgets
- Create category-based budgets
- Track progress with alerts
- Monitor spending against limits

---

### Powerful Filtering
- Unified command bar for:
  - Search
  - Quick filters (Expense / Income)
  - Advanced filters
- Real-time transaction count updates

---

### Privacy First
- 100% local-first architecture
- No cloud sync
- No data collection
- No tracking

Your financial data never leaves your device.

---

### Modern UI/UX
- Clean, consistent design system
- Smooth animations and transitions
- Dark theme support
- Optimized for speed and usability

---

## Tech Stack

- Flutter
- Isar (local database)
- Zustand-like state management patterns
- Material Design (customized)

---

## Getting Started

### Prerequisites
- Flutter SDK installed

---

### Run Locally

```bash
git clone https://github.com/your-username/kubera.git
cd kubera
flutter pub get
flutter run
---

## Brand Icon (vector)

The Kuber brand mark (dark tile, accent circle, angular rupee) exists in two forms:

- **Raster (launcher / stores)**: `android/play_store_512.png` and the `android/app/src/main/res/mipmap-*/` launcher PNGs. Static Signature-blue; used by the OS launcher and the Android 12+ system launch screen, which cannot follow the in-app theme.
- **Vector (in-app, theme-aware)**: `lib/shared/widgets/brand_icon.dart` — `KuberBrandMarkPainter`, a CustomPainter whose geometry was traced 1:1 from `play_store_512.png` (512-unit coordinate space). Colors derive from the active theme family: circle = `colorScheme.primary`, tile + glyph = `KuberBrandMarkPainter.deepShade(primary)` (HSL: saturation x0.85, lightness 0.26). With the Signature theme it reproduces the launcher icon (`#0E397C` tile, `#4388FD` circle). Used by the splash screen, onboarding brand row, and tutorial header via the `BrandIcon` widget.

If the launcher icon art ever changes, re-trace the glyph geometry in `KuberBrandMarkPainter.paint` so the two stay in sync.
