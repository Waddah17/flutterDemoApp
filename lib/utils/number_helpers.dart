extension NumberHelpers on double{

  String toFixedPrice() {
    String price = toStringAsFixed(2);

    return price.replaceAll('.00', '');
  }
}