class GstResult {
  final double preGst; // amount excluding GST
  final double gstAmount;
  final double grossAmount; // amount including GST
  final double cgst;
  final double sgst;

  const GstResult({
    required this.preGst,
    required this.gstAmount,
    required this.grossAmount,
    required this.cgst,
    required this.sgst,
  });
}

/// Add GST to a pre-GST [amount]: gst = amount·rate/100.
GstResult addGst(double amount, double ratePercent) {
  final gst = amount * ratePercent / 100;
  return GstResult(
    preGst: amount,
    gstAmount: gst,
    grossAmount: amount + gst,
    cgst: gst / 2,
    sgst: gst / 2,
  );
}

/// Remove GST from a GST-inclusive [amount]: base = amount/(1+rate/100).
GstResult removeGst(double amount, double ratePercent) {
  final base = amount / (1 + ratePercent / 100);
  final gst = amount - base;
  return GstResult(
    preGst: base,
    gstAmount: gst,
    grossAmount: amount,
    cgst: gst / 2,
    sgst: gst / 2,
  );
}
