enum SearchSort { relevance, newest, lowestPrice, highestPrice }

extension ParseToString on SearchSort {
  String toShortString() {
    return toString().split('.').last;
  }
}