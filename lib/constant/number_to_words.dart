// lib/number_to_words.dart

String convertNumberToWords(double number) {
  if (number == 0) return 'Zero';

  const List<String> thousands = [
    '',
    'Thousand',
    'Million',
    'Billion',
  ];

  String words = '';

  int intPart = number.toInt();
  int decimalPart = ((number - intPart) * 100).round();

  if (intPart > 999) {
    int thousandCounter = 0;
    while (intPart > 0) {
      int chunk = intPart % 1000;
      if (chunk > 0) {
        words =
            '${_convertChunkToWords(chunk)}${thousands[thousandCounter] != '' ? ' ' + thousands[thousandCounter] : ''} $words';
      }
      intPart ~/= 1000;
      thousandCounter++;
    }
  } else {
    words = _convertChunkToWords(intPart);
  }

  if (decimalPart > 0) {
    words += ' and ${_convertChunkToWords(decimalPart)} Cents';
  }

  return words.trim();
}

String _convertChunkToWords(int number) {
  const List<String> units = [
    '',
    'One',
    'Two',
    'Three',
    'Four',
    'Five',
    'Six',
    'Seven',
    'Eight',
    'Nine',
    'Ten',
    'Eleven',
    'Twelve',
    'Thirteen',
    'Fourteen',
    'Fifteen',
    'Sixteen',
    'Seventeen',
    'Eighteen',
    'Nineteen',
  ];

  const List<String> tens = [
    '',
    '',
    'Twenty',
    'Thirty',
    'Forty',
    'Fifty',
    'Sixty',
    'Seventy',
    'Eighty',
    'Ninety',
  ];

  String words = '';

  if (number >= 100) {
    words += '${units[number ~/ 100]} Hundred ';
    number %= 100;
  }

  if (number >= 20) {
    words += '${tens[number ~/ 10]} ';
    number %= 10;
  }

  if (number > 0) {
    words += '${units[number]} ';
  }

  return words.trim();
}
