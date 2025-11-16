class PriceFormatter {
  static String formatNaira(double price) {
    // Format price with commas and Naira symbol
    final priceString = price.toStringAsFixed(0);
    final buffer = StringBuffer();
    
    // Add commas every 3 digits from right to left
    for (int i = 0; i < priceString.length; i++) {
      if (i > 0 && (priceString.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(priceString[i]);
    }
    
    return '₦${buffer.toString()}';
  }
  
  static String formatNairaPerNight(double price) {
    return '${formatNaira(price)}/night';
  }
}

