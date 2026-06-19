/// Maps a keyword (matched case-insensitively against the parsed merchant
/// name) to a suggested category *name*. The actual category id is resolved
/// later against the user's real Kuber categories — if no category with a
/// matching name exists, the suggestion is dropped and the user picks one.
const Map<String, String> categoryKeywords = {
  // Food and dining
  'swiggy': 'Food',
  'zomato': 'Food',
  'dominos': 'Food',
  'mcdonalds': 'Food',
  'kfc': 'Food',
  'subway': 'Food',
  'eatfit': 'Food',
  'faasos': 'Food',
  'box8': 'Food',
  // Groceries
  'blinkit': 'Groceries',
  'bigbasket': 'Groceries',
  'zepto': 'Groceries',
  'dmart': 'Groceries',
  'jiomart': 'Groceries',
  'instamart': 'Groceries',
  'grofers': 'Groceries',
  // Entertainment
  'netflix': 'Entertainment',
  'hotstar': 'Entertainment',
  'disney': 'Entertainment',
  'spotify': 'Entertainment',
  'prime': 'Entertainment',
  'youtube': 'Entertainment',
  'bookmyshow': 'Entertainment',
  'pvr': 'Entertainment',
  'inox': 'Entertainment',
  // Transport
  'uber': 'Transport',
  'ola': 'Transport',
  'rapido': 'Transport',
  'irctc': 'Transport',
  'redbus': 'Transport',
  'fastag': 'Transport',
  'metro': 'Transport',
  // Travel
  'makemytrip': 'Travel',
  'goibibo': 'Travel',
  'cleartrip': 'Travel',
  'indigo': 'Travel',
  'vistara': 'Travel',
  'airbnb': 'Travel',
  'oyo': 'Travel',
  // Utilities
  'electricity': 'Utilities',
  'bescom': 'Utilities',
  'tata power': 'Utilities',
  'airtel': 'Utilities',
  'jio': 'Utilities',
  'vi ': 'Utilities',
  'vodafone': 'Utilities',
  'broadband': 'Utilities',
  'gas': 'Utilities',
  'recharge': 'Utilities',
  // Shopping
  'amazon': 'Shopping',
  'flipkart': 'Shopping',
  'myntra': 'Shopping',
  'meesho': 'Shopping',
  'ajio': 'Shopping',
  'nykaa': 'Shopping',
  'tatacliq': 'Shopping',
  // Health
  'apollo': 'Health',
  'medplus': 'Health',
  'pharmeasy': 'Health',
  '1mg': 'Health',
  'netmeds': 'Health',
  'practo': 'Health',
  'cult': 'Health',
  // Rent and housing
  'rent': 'Housing',
  'maintenance': 'Housing',
  'nobroker': 'Housing',
  // Salary / income keywords
  'salary': 'Salary',
  'payroll': 'Salary',
  'stipend': 'Salary',
};

/// Returns the suggested category name for [merchant], or null if no keyword
/// matches. Case-insensitive substring match.
String? suggestCategoryName(String? merchant) {
  if (merchant == null || merchant.trim().isEmpty) return null;
  final lower = merchant.toLowerCase();
  for (final entry in categoryKeywords.entries) {
    if (lower.contains(entry.key)) return entry.value;
  }
  return null;
}
