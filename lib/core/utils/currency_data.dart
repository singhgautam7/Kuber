// Every active ISO 4217 currency, bundled offline (no network). Funds,
// precious metals and test codes are left out. Decimals are ISO minor units.
// Names are English only: there is no reliable offline source of localised
// currency names. The 26 currencies Kuber offered before vNext keep their
// symbols exactly. Display goes through AppFormatter only.

class KuberCurrency {
  final String code;
  final String name;

  /// Distinguishing symbol (e.g. A$, HK$) used by default.
  final String symbol;

  /// Local narrow symbol (e.g. $ for A$). Shown in compact spots only.
  final String narrow;

  /// ISO 4217 minor units: JPY 0, INR 2, KWD 3.
  final int decimals;

  /// Symbol after the amount ("1,200 kr").
  final bool after;

  /// ISO 3166 alpha-2 regions that use it (phone region suggestion).
  final List<String> regions;

  /// Country names for search.
  final String countries;

  const KuberCurrency({
    required this.code,
    required this.name,
    required this.symbol,
    String? narrow,
    this.decimals = 2,
    this.after = false,
    this.regions = const [],
    this.countries = '',
  }) : narrow = narrow ?? symbol;

  /// A space between amount and symbol: always when the symbol comes after,
  /// and for letter symbols before ("CHF 1,200", "KSh 1,200"). Single
  /// glyphs and "$" symbols sit tight ("₹1,200", "A$1,200").
  bool get spaced =>
      after || (symbol.runes.length > 1 && !symbol.endsWith(r'$'));

  /// Indian lakh / crore grouping is automatic only for INR.
  bool get indianGrouping => code == 'INR';

  bool matches(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return code.toLowerCase().contains(q) ||
        name.toLowerCase().contains(q) ||
        countries.toLowerCase().contains(q) ||
        symbol.toLowerCase() == q;
  }
}

const kCurrencies = <KuberCurrency>[
  // The pre-vNext list first, symbols unchanged.
  KuberCurrency(code: 'INR', name: 'Indian Rupee', symbol: '₹', regions: ['IN'], countries: 'India, Bhutan'),
  KuberCurrency(code: 'USD', name: 'US Dollar', symbol: r'$', regions: ['US', 'EC', 'SV', 'PA', 'PR', 'TL', 'ZW', 'FM', 'MH', 'PW', 'VG', 'TC', 'BQ'], countries: 'United States, Ecuador, El Salvador, Panama, Puerto Rico, Timor-Leste, Zimbabwe'),
  KuberCurrency(code: 'EUR', name: 'Euro', symbol: '€', regions: ['DE', 'FR', 'IT', 'ES', 'NL', 'BE', 'AT', 'PT', 'IE', 'FI', 'GR', 'SK', 'SI', 'LU', 'LV', 'LT', 'EE', 'CY', 'MT', 'HR', 'BG', 'ME', 'XK', 'AD', 'MC', 'SM', 'VA'], countries: 'Eurozone, Germany, France, Italy, Spain, Netherlands, Belgium, Austria, Portugal, Ireland, Finland, Greece, Slovakia, Slovenia, Luxembourg, Latvia, Lithuania, Estonia, Cyprus, Malta, Croatia, Bulgaria, Montenegro, Kosovo, Andorra, Monaco, San Marino, Vatican'),
  KuberCurrency(code: 'GBP', name: 'British Pound', symbol: '£', regions: ['GB', 'IM', 'JE', 'GG'], countries: 'United Kingdom, Isle of Man, Jersey, Guernsey'),
  KuberCurrency(code: 'JPY', name: 'Japanese Yen', symbol: '¥', decimals: 0, regions: ['JP'], countries: 'Japan'),
  KuberCurrency(code: 'CNY', name: 'Chinese Yuan', symbol: '¥', regions: ['CN'], countries: 'China'),
  KuberCurrency(code: 'KRW', name: 'South Korean Won', symbol: '₩', decimals: 0, regions: ['KR'], countries: 'South Korea'),
  KuberCurrency(code: 'AUD', name: 'Australian Dollar', symbol: r'A$', narrow: r'$', regions: ['AU', 'KI', 'NR', 'TV', 'CX', 'CC', 'NF'], countries: 'Australia, Kiribati, Nauru, Tuvalu'),
  KuberCurrency(code: 'CAD', name: 'Canadian Dollar', symbol: r'C$', narrow: r'$', regions: ['CA'], countries: 'Canada'),
  KuberCurrency(code: 'CHF', name: 'Swiss Franc', symbol: 'CHF', regions: ['CH', 'LI'], countries: 'Switzerland, Liechtenstein'),
  KuberCurrency(code: 'SEK', name: 'Swedish Krona', symbol: 'kr', after: true, regions: ['SE'], countries: 'Sweden'),
  KuberCurrency(code: 'NOK', name: 'Norwegian Krone', symbol: 'kr', after: true, regions: ['NO', 'SJ', 'BV'], countries: 'Norway'),
  KuberCurrency(code: 'DKK', name: 'Danish Krone', symbol: 'kr', after: true, regions: ['DK', 'GL', 'FO'], countries: 'Denmark, Greenland, Faroe Islands'),
  KuberCurrency(code: 'SGD', name: 'Singapore Dollar', symbol: r'S$', narrow: r'$', regions: ['SG'], countries: 'Singapore'),
  KuberCurrency(code: 'HKD', name: 'Hong Kong Dollar', symbol: r'HK$', narrow: r'$', regions: ['HK'], countries: 'Hong Kong'),
  KuberCurrency(code: 'MYR', name: 'Malaysian Ringgit', symbol: 'RM', regions: ['MY'], countries: 'Malaysia'),
  KuberCurrency(code: 'THB', name: 'Thai Baht', symbol: '฿', regions: ['TH'], countries: 'Thailand'),
  KuberCurrency(code: 'PHP', name: 'Philippine Peso', symbol: '₱', regions: ['PH'], countries: 'Philippines'),
  KuberCurrency(code: 'IDR', name: 'Indonesian Rupiah', symbol: 'Rp', regions: ['ID'], countries: 'Indonesia'),
  KuberCurrency(code: 'BRL', name: 'Brazilian Real', symbol: r'R$', narrow: r'$', regions: ['BR'], countries: 'Brazil'),
  KuberCurrency(code: 'MXN', name: 'Mexican Peso', symbol: r'MX$', narrow: r'$', regions: ['MX'], countries: 'Mexico'),
  KuberCurrency(code: 'ZAR', name: 'South African Rand', symbol: 'R', regions: ['ZA'], countries: 'South Africa'),
  KuberCurrency(code: 'AED', name: 'UAE Dirham', symbol: 'د.إ', regions: ['AE'], countries: 'United Arab Emirates, UAE, Dubai'),
  KuberCurrency(code: 'SAR', name: 'Saudi Riyal', symbol: '﷼', regions: ['SA'], countries: 'Saudi Arabia'),
  KuberCurrency(code: 'TRY', name: 'Turkish Lira', symbol: '₺', regions: ['TR'], countries: 'Turkey, Türkiye'),
  // The rest of ISO 4217, by code.
  KuberCurrency(code: 'AFN', name: 'Afghan Afghani', symbol: '؋', regions: ['AF'], countries: 'Afghanistan'),
  KuberCurrency(code: 'ALL', name: 'Albanian Lek', symbol: 'Lek', regions: ['AL'], countries: 'Albania'),
  KuberCurrency(code: 'AMD', name: 'Armenian Dram', symbol: '֏', regions: ['AM'], countries: 'Armenia'),
  KuberCurrency(code: 'AOA', name: 'Angolan Kwanza', symbol: 'Kz', regions: ['AO'], countries: 'Angola'),
  KuberCurrency(code: 'ARS', name: 'Argentine Peso', symbol: r'AR$', narrow: r'$', regions: ['AR'], countries: 'Argentina'),
  KuberCurrency(code: 'AWG', name: 'Aruban Florin', symbol: 'Afl.', regions: ['AW'], countries: 'Aruba'),
  KuberCurrency(code: 'AZN', name: 'Azerbaijani Manat', symbol: '₼', after: true, regions: ['AZ'], countries: 'Azerbaijan'),
  KuberCurrency(code: 'BAM', name: 'Bosnia-Herzegovina Convertible Mark', symbol: 'KM', after: true, regions: ['BA'], countries: 'Bosnia and Herzegovina'),
  KuberCurrency(code: 'BBD', name: 'Barbadian Dollar', symbol: r'Bds$', narrow: r'$', regions: ['BB'], countries: 'Barbados'),
  KuberCurrency(code: 'BDT', name: 'Bangladeshi Taka', symbol: '৳', regions: ['BD'], countries: 'Bangladesh'),
  KuberCurrency(code: 'BGN', name: 'Bulgarian Lev', symbol: 'лв', after: true, countries: 'Bulgaria (before the euro)'),
  KuberCurrency(code: 'BHD', name: 'Bahraini Dinar', symbol: 'BD', decimals: 3, regions: ['BH'], countries: 'Bahrain'),
  KuberCurrency(code: 'BIF', name: 'Burundian Franc', symbol: 'FBu', decimals: 0, regions: ['BI'], countries: 'Burundi'),
  KuberCurrency(code: 'BMD', name: 'Bermudian Dollar', symbol: r'BD$', narrow: r'$', regions: ['BM'], countries: 'Bermuda'),
  KuberCurrency(code: 'BND', name: 'Brunei Dollar', symbol: r'B$', narrow: r'$', regions: ['BN'], countries: 'Brunei'),
  KuberCurrency(code: 'BOB', name: 'Bolivian Boliviano', symbol: 'Bs', regions: ['BO'], countries: 'Bolivia'),
  KuberCurrency(code: 'BSD', name: 'Bahamian Dollar', symbol: r'B$', narrow: r'$', regions: ['BS'], countries: 'Bahamas'),
  KuberCurrency(code: 'BTN', name: 'Bhutanese Ngultrum', symbol: 'Nu.', regions: ['BT'], countries: 'Bhutan'),
  KuberCurrency(code: 'BWP', name: 'Botswana Pula', symbol: 'P', regions: ['BW'], countries: 'Botswana'),
  KuberCurrency(code: 'BYN', name: 'Belarusian Ruble', symbol: 'Br', after: true, regions: ['BY'], countries: 'Belarus'),
  KuberCurrency(code: 'BZD', name: 'Belize Dollar', symbol: r'BZ$', narrow: r'$', regions: ['BZ'], countries: 'Belize'),
  KuberCurrency(code: 'CDF', name: 'Congolese Franc', symbol: 'FC', regions: ['CD'], countries: 'DR Congo, Democratic Republic of the Congo'),
  KuberCurrency(code: 'CLP', name: 'Chilean Peso', symbol: r'CL$', narrow: r'$', decimals: 0, regions: ['CL'], countries: 'Chile'),
  KuberCurrency(code: 'COP', name: 'Colombian Peso', symbol: r'CO$', narrow: r'$', regions: ['CO'], countries: 'Colombia'),
  KuberCurrency(code: 'CRC', name: 'Costa Rican Colón', symbol: '₡', regions: ['CR'], countries: 'Costa Rica'),
  KuberCurrency(code: 'CUP', name: 'Cuban Peso', symbol: r'CU$', narrow: r'$', regions: ['CU'], countries: 'Cuba'),
  KuberCurrency(code: 'CVE', name: 'Cape Verdean Escudo', symbol: 'Esc', regions: ['CV'], countries: 'Cape Verde, Cabo Verde'),
  KuberCurrency(code: 'CZK', name: 'Czech Koruna', symbol: 'Kč', after: true, regions: ['CZ'], countries: 'Czech Republic, Czechia'),
  KuberCurrency(code: 'DJF', name: 'Djiboutian Franc', symbol: 'Fdj', decimals: 0, regions: ['DJ'], countries: 'Djibouti'),
  KuberCurrency(code: 'DOP', name: 'Dominican Peso', symbol: r'RD$', narrow: r'$', regions: ['DO'], countries: 'Dominican Republic'),
  KuberCurrency(code: 'DZD', name: 'Algerian Dinar', symbol: 'DA', regions: ['DZ'], countries: 'Algeria'),
  KuberCurrency(code: 'EGP', name: 'Egyptian Pound', symbol: 'E£', narrow: '£', regions: ['EG'], countries: 'Egypt'),
  KuberCurrency(code: 'ERN', name: 'Eritrean Nakfa', symbol: 'Nfk', regions: ['ER'], countries: 'Eritrea'),
  KuberCurrency(code: 'ETB', name: 'Ethiopian Birr', symbol: 'Br', regions: ['ET'], countries: 'Ethiopia'),
  KuberCurrency(code: 'FJD', name: 'Fijian Dollar', symbol: r'FJ$', narrow: r'$', regions: ['FJ'], countries: 'Fiji'),
  KuberCurrency(code: 'FKP', name: 'Falkland Islands Pound', symbol: 'FK£', narrow: '£', regions: ['FK'], countries: 'Falkland Islands'),
  KuberCurrency(code: 'GEL', name: 'Georgian Lari', symbol: '₾', after: true, regions: ['GE'], countries: 'Georgia'),
  KuberCurrency(code: 'GHS', name: 'Ghanaian Cedi', symbol: 'GH₵', narrow: '₵', regions: ['GH'], countries: 'Ghana'),
  KuberCurrency(code: 'GIP', name: 'Gibraltar Pound', symbol: '£', regions: ['GI'], countries: 'Gibraltar'),
  KuberCurrency(code: 'GMD', name: 'Gambian Dalasi', symbol: 'D', regions: ['GM'], countries: 'Gambia'),
  KuberCurrency(code: 'GNF', name: 'Guinean Franc', symbol: 'FG', decimals: 0, regions: ['GN'], countries: 'Guinea'),
  KuberCurrency(code: 'GTQ', name: 'Guatemalan Quetzal', symbol: 'Q', regions: ['GT'], countries: 'Guatemala'),
  KuberCurrency(code: 'GYD', name: 'Guyanese Dollar', symbol: r'GY$', narrow: r'$', regions: ['GY'], countries: 'Guyana'),
  KuberCurrency(code: 'HNL', name: 'Honduran Lempira', symbol: 'L', regions: ['HN'], countries: 'Honduras'),
  KuberCurrency(code: 'HTG', name: 'Haitian Gourde', symbol: 'G', regions: ['HT'], countries: 'Haiti'),
  KuberCurrency(code: 'HUF', name: 'Hungarian Forint', symbol: 'Ft', after: true, regions: ['HU'], countries: 'Hungary'),
  KuberCurrency(code: 'ILS', name: 'Israeli New Shekel', symbol: '₪', regions: ['IL', 'PS'], countries: 'Israel, Palestine'),
  KuberCurrency(code: 'IQD', name: 'Iraqi Dinar', symbol: 'IQD', decimals: 3, regions: ['IQ'], countries: 'Iraq'),
  KuberCurrency(code: 'IRR', name: 'Iranian Rial', symbol: 'IRR', regions: ['IR'], countries: 'Iran'),
  KuberCurrency(code: 'ISK', name: 'Icelandic Króna', symbol: 'kr', decimals: 0, after: true, regions: ['IS'], countries: 'Iceland'),
  KuberCurrency(code: 'JMD', name: 'Jamaican Dollar', symbol: r'J$', narrow: r'$', regions: ['JM'], countries: 'Jamaica'),
  KuberCurrency(code: 'JOD', name: 'Jordanian Dinar', symbol: 'JD', decimals: 3, regions: ['JO'], countries: 'Jordan'),
  KuberCurrency(code: 'KES', name: 'Kenyan Shilling', symbol: 'KSh', regions: ['KE'], countries: 'Kenya'),
  KuberCurrency(code: 'KGS', name: 'Kyrgyzstani Som', symbol: 'сом', after: true, regions: ['KG'], countries: 'Kyrgyzstan'),
  KuberCurrency(code: 'KHR', name: 'Cambodian Riel', symbol: '៛', regions: ['KH'], countries: 'Cambodia'),
  KuberCurrency(code: 'KMF', name: 'Comorian Franc', symbol: 'CF', decimals: 0, regions: ['KM'], countries: 'Comoros'),
  KuberCurrency(code: 'KPW', name: 'North Korean Won', symbol: '₩', regions: ['KP'], countries: 'North Korea'),
  KuberCurrency(code: 'KWD', name: 'Kuwaiti Dinar', symbol: 'KD', decimals: 3, regions: ['KW'], countries: 'Kuwait'),
  KuberCurrency(code: 'KYD', name: 'Cayman Islands Dollar', symbol: r'CI$', narrow: r'$', regions: ['KY'], countries: 'Cayman Islands'),
  KuberCurrency(code: 'KZT', name: 'Kazakhstani Tenge', symbol: '₸', after: true, regions: ['KZ'], countries: 'Kazakhstan'),
  KuberCurrency(code: 'LAK', name: 'Lao Kip', symbol: '₭', regions: ['LA'], countries: 'Laos'),
  KuberCurrency(code: 'LBP', name: 'Lebanese Pound', symbol: 'L£', narrow: '£', regions: ['LB'], countries: 'Lebanon'),
  KuberCurrency(code: 'LKR', name: 'Sri Lankan Rupee', symbol: 'Rs', regions: ['LK'], countries: 'Sri Lanka'),
  KuberCurrency(code: 'LRD', name: 'Liberian Dollar', symbol: r'L$', narrow: r'$', regions: ['LR'], countries: 'Liberia'),
  KuberCurrency(code: 'LSL', name: 'Lesotho Loti', symbol: 'L', regions: ['LS'], countries: 'Lesotho'),
  KuberCurrency(code: 'LYD', name: 'Libyan Dinar', symbol: 'LD', decimals: 3, regions: ['LY'], countries: 'Libya'),
  KuberCurrency(code: 'MAD', name: 'Moroccan Dirham', symbol: 'MAD', regions: ['MA', 'EH'], countries: 'Morocco, Western Sahara'),
  KuberCurrency(code: 'MDL', name: 'Moldovan Leu', symbol: 'L', after: true, regions: ['MD'], countries: 'Moldova'),
  KuberCurrency(code: 'MGA', name: 'Malagasy Ariary', symbol: 'Ar', regions: ['MG'], countries: 'Madagascar'),
  KuberCurrency(code: 'MKD', name: 'Macedonian Denar', symbol: 'ден', after: true, regions: ['MK'], countries: 'North Macedonia'),
  KuberCurrency(code: 'MMK', name: 'Myanmar Kyat', symbol: 'K', regions: ['MM'], countries: 'Myanmar, Burma'),
  KuberCurrency(code: 'MNT', name: 'Mongolian Tögrög', symbol: '₮', regions: ['MN'], countries: 'Mongolia'),
  KuberCurrency(code: 'MOP', name: 'Macanese Pataca', symbol: r'MOP$', narrow: r'$', regions: ['MO'], countries: 'Macau, Macao'),
  KuberCurrency(code: 'MRU', name: 'Mauritanian Ouguiya', symbol: 'UM', regions: ['MR'], countries: 'Mauritania'),
  KuberCurrency(code: 'MUR', name: 'Mauritian Rupee', symbol: 'Rs', regions: ['MU'], countries: 'Mauritius'),
  KuberCurrency(code: 'MVR', name: 'Maldivian Rufiyaa', symbol: 'Rf', regions: ['MV'], countries: 'Maldives'),
  KuberCurrency(code: 'MWK', name: 'Malawian Kwacha', symbol: 'MK', regions: ['MW'], countries: 'Malawi'),
  KuberCurrency(code: 'MZN', name: 'Mozambican Metical', symbol: 'MT', regions: ['MZ'], countries: 'Mozambique'),
  KuberCurrency(code: 'NAD', name: 'Namibian Dollar', symbol: r'N$', narrow: r'$', regions: ['NA'], countries: 'Namibia'),
  KuberCurrency(code: 'NGN', name: 'Nigerian Naira', symbol: '₦', regions: ['NG'], countries: 'Nigeria'),
  KuberCurrency(code: 'NIO', name: 'Nicaraguan Córdoba', symbol: r'C$', narrow: r'$', regions: ['NI'], countries: 'Nicaragua'),
  KuberCurrency(code: 'NPR', name: 'Nepalese Rupee', symbol: 'Rs', regions: ['NP'], countries: 'Nepal'),
  KuberCurrency(code: 'NZD', name: 'New Zealand Dollar', symbol: r'NZ$', narrow: r'$', regions: ['NZ', 'CK', 'NU', 'PN', 'TK'], countries: 'New Zealand, Cook Islands, Niue'),
  KuberCurrency(code: 'OMR', name: 'Omani Rial', symbol: 'OMR', decimals: 3, regions: ['OM'], countries: 'Oman'),
  KuberCurrency(code: 'PAB', name: 'Panamanian Balboa', symbol: 'B/.', regions: ['PA'], countries: 'Panama'),
  KuberCurrency(code: 'PEN', name: 'Peruvian Sol', symbol: 'S/', regions: ['PE'], countries: 'Peru'),
  KuberCurrency(code: 'PGK', name: 'Papua New Guinean Kina', symbol: 'K', regions: ['PG'], countries: 'Papua New Guinea'),
  KuberCurrency(code: 'PKR', name: 'Pakistani Rupee', symbol: 'Rs', regions: ['PK'], countries: 'Pakistan'),
  KuberCurrency(code: 'PLN', name: 'Polish Złoty', symbol: 'zł', after: true, regions: ['PL'], countries: 'Poland'),
  KuberCurrency(code: 'PYG', name: 'Paraguayan Guaraní', symbol: '₲', decimals: 0, regions: ['PY'], countries: 'Paraguay'),
  KuberCurrency(code: 'QAR', name: 'Qatari Riyal', symbol: 'QR', regions: ['QA'], countries: 'Qatar'),
  KuberCurrency(code: 'RON', name: 'Romanian Leu', symbol: 'lei', after: true, regions: ['RO'], countries: 'Romania'),
  KuberCurrency(code: 'RSD', name: 'Serbian Dinar', symbol: 'din', after: true, regions: ['RS'], countries: 'Serbia'),
  KuberCurrency(code: 'RUB', name: 'Russian Ruble', symbol: '₽', after: true, regions: ['RU'], countries: 'Russia'),
  KuberCurrency(code: 'RWF', name: 'Rwandan Franc', symbol: 'RF', decimals: 0, regions: ['RW'], countries: 'Rwanda'),
  KuberCurrency(code: 'SBD', name: 'Solomon Islands Dollar', symbol: r'SI$', narrow: r'$', regions: ['SB'], countries: 'Solomon Islands'),
  KuberCurrency(code: 'SCR', name: 'Seychellois Rupee', symbol: 'SR', regions: ['SC'], countries: 'Seychelles'),
  KuberCurrency(code: 'SDG', name: 'Sudanese Pound', symbol: 'SDG', regions: ['SD'], countries: 'Sudan'),
  KuberCurrency(code: 'SHP', name: 'Saint Helena Pound', symbol: '£', regions: ['SH'], countries: 'Saint Helena'),
  KuberCurrency(code: 'SLE', name: 'Sierra Leonean Leone', symbol: 'Le', regions: ['SL'], countries: 'Sierra Leone'),
  KuberCurrency(code: 'SOS', name: 'Somali Shilling', symbol: 'Sh', regions: ['SO'], countries: 'Somalia'),
  KuberCurrency(code: 'SRD', name: 'Surinamese Dollar', symbol: r'Sr$', narrow: r'$', regions: ['SR'], countries: 'Suriname'),
  KuberCurrency(code: 'SSP', name: 'South Sudanese Pound', symbol: 'SS£', narrow: '£', regions: ['SS'], countries: 'South Sudan'),
  KuberCurrency(code: 'STN', name: 'São Tomé and Príncipe Dobra', symbol: 'Db', regions: ['ST'], countries: 'São Tomé and Príncipe'),
  KuberCurrency(code: 'SVC', name: 'Salvadoran Colón', symbol: '₡', countries: 'El Salvador'),
  KuberCurrency(code: 'SYP', name: 'Syrian Pound', symbol: 'LS', regions: ['SY'], countries: 'Syria'),
  KuberCurrency(code: 'SZL', name: 'Swazi Lilangeni', symbol: 'E', regions: ['SZ'], countries: 'Eswatini, Swaziland'),
  KuberCurrency(code: 'TJS', name: 'Tajikistani Somoni', symbol: 'SM', after: true, regions: ['TJ'], countries: 'Tajikistan'),
  KuberCurrency(code: 'TMT', name: 'Turkmenistani Manat', symbol: 'm', after: true, regions: ['TM'], countries: 'Turkmenistan'),
  KuberCurrency(code: 'TND', name: 'Tunisian Dinar', symbol: 'DT', decimals: 3, regions: ['TN'], countries: 'Tunisia'),
  KuberCurrency(code: 'TOP', name: 'Tongan Paʻanga', symbol: r'T$', narrow: r'$', regions: ['TO'], countries: 'Tonga'),
  KuberCurrency(code: 'TTD', name: 'Trinidad and Tobago Dollar', symbol: r'TT$', narrow: r'$', regions: ['TT'], countries: 'Trinidad and Tobago'),
  KuberCurrency(code: 'TWD', name: 'New Taiwan Dollar', symbol: r'NT$', narrow: r'$', regions: ['TW'], countries: 'Taiwan'),
  KuberCurrency(code: 'TZS', name: 'Tanzanian Shilling', symbol: 'TSh', regions: ['TZ'], countries: 'Tanzania'),
  KuberCurrency(code: 'UAH', name: 'Ukrainian Hryvnia', symbol: '₴', after: true, regions: ['UA'], countries: 'Ukraine'),
  KuberCurrency(code: 'UGX', name: 'Ugandan Shilling', symbol: 'USh', decimals: 0, regions: ['UG'], countries: 'Uganda'),
  KuberCurrency(code: 'UYU', name: 'Uruguayan Peso', symbol: r'$U', narrow: r'$', regions: ['UY'], countries: 'Uruguay'),
  KuberCurrency(code: 'UZS', name: 'Uzbekistani Som', symbol: 'soʻm', after: true, regions: ['UZ'], countries: 'Uzbekistan'),
  KuberCurrency(code: 'VES', name: 'Venezuelan Bolívar', symbol: 'Bs.S', regions: ['VE'], countries: 'Venezuela'),
  KuberCurrency(code: 'VND', name: 'Vietnamese Đồng', symbol: '₫', decimals: 0, after: true, regions: ['VN'], countries: 'Vietnam'),
  KuberCurrency(code: 'VUV', name: 'Vanuatu Vatu', symbol: 'VT', decimals: 0, regions: ['VU'], countries: 'Vanuatu'),
  KuberCurrency(code: 'WST', name: 'Samoan Tala', symbol: r'WS$', narrow: r'$', regions: ['WS'], countries: 'Samoa'),
  KuberCurrency(code: 'XAF', name: 'Central African CFA Franc', symbol: 'FCFA', decimals: 0, regions: ['CM', 'CF', 'TD', 'CG', 'GQ', 'GA'], countries: 'Cameroon, Central African Republic, Chad, Congo, Equatorial Guinea, Gabon'),
  KuberCurrency(code: 'XCD', name: 'East Caribbean Dollar', symbol: r'EC$', narrow: r'$', regions: ['AG', 'DM', 'GD', 'KN', 'LC', 'VC', 'AI', 'MS'], countries: 'Antigua and Barbuda, Dominica, Grenada, Saint Kitts and Nevis, Saint Lucia, Saint Vincent, Anguilla, Montserrat'),
  KuberCurrency(code: 'XCG', name: 'Caribbean Guilder', symbol: 'Cg', regions: ['CW', 'SX'], countries: 'Curaçao, Sint Maarten'),
  KuberCurrency(code: 'XOF', name: 'West African CFA Franc', symbol: 'CFA', decimals: 0, regions: ['BJ', 'BF', 'CI', 'GW', 'ML', 'NE', 'SN', 'TG'], countries: 'Benin, Burkina Faso, Ivory Coast, Côte d’Ivoire, Guinea-Bissau, Mali, Niger, Senegal, Togo'),
  KuberCurrency(code: 'XPF', name: 'CFP Franc', symbol: 'CFPF', decimals: 0, regions: ['PF', 'NC', 'WF'], countries: 'French Polynesia, New Caledonia, Wallis and Futuna'),
  KuberCurrency(code: 'YER', name: 'Yemeni Rial', symbol: 'YR', regions: ['YE'], countries: 'Yemen'),
  KuberCurrency(code: 'ZMW', name: 'Zambian Kwacha', symbol: 'ZK', regions: ['ZM'], countries: 'Zambia'),
  KuberCurrency(code: 'ZWG', name: 'Zimbabwe Gold', symbol: 'ZiG', regions: ['ZW'], countries: 'Zimbabwe'),
];

final Map<String, KuberCurrency> _byCode = {for (final c in kCurrencies) c.code: c};

/// The currency for an ISO code; unknown codes fall back to INR (as before).
KuberCurrency currencyFromCode(String code) => _byCode[code] ?? kCurrencies.first;

/// The currency used in a region (ISO 3166 alpha-2), for the "Suggested"
/// section of the picker.
KuberCurrency? currencyForRegion(String? region) {
  if (region == null || region.isEmpty) return null;
  final r = region.toUpperCase();
  for (final c in kCurrencies) {
    if (c.regions.contains(r)) return c;
  }
  return null;
}
