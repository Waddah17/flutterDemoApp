

import 'package:thevendor/shared/models/currency.dart';

extension PowerString on String {

  String smallSentence() {
    if (length > 40) {
      return substring(0, 40);
    } else {
      return this;
    }
  }

  String firstFewWords(int wordsCount) {
    int startIndex = 0, indexOfSpace=0;

    for (int i = 0; i < wordsCount; i++) {
      indexOfSpace = indexOf(' ', startIndex);
      if (indexOfSpace == -1) {
        //-1 is when character is not found
        return this;
      }
      startIndex = indexOfSpace + 1;
    }

    return substring(0, indexOfSpace);
  }

   String toFixedPrice() {
    double number=  double.parse(this);
    String price = number.toStringAsFixed(2);

    return price.replaceAll('.00', '');
  }

  String toPriceStr(Currency currency) {
   return '${toString().toFixedPrice()} ${currency.name}';
  }
}