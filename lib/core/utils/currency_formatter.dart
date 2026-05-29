/// Masks a pre-formatted amount string when privacy mode is on.
///
/// Currency formatting itself lives in [AppFormatter] (`formatterProvider`),
/// which honours the user's number-system setting (Indian vs Western grouping).
/// Use that everywhere; this file only keeps the privacy mask helper.
String maskAmount(String formattedAmount, bool isPrivate) {
  return isPrivate ? '****' : formattedAmount;
}
