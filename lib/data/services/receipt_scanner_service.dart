import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class ReceiptScannerService {
  final ImagePicker _picker = ImagePicker();
  final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  Future<double?> scanReceiptAsAmount() async {
    try {
      // 1. Pick Image
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image == null) return null;

      // 2. Recognize Text
      final inputImage = InputImage.fromFilePath(image.path);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);

      // 3. Extract Amount
      return extractTotalAmount(recognizedText.text);
    } catch (e) {
      print('Error scanning receipt: $e');
      return null;
    } finally {
      // Clean up text recognizer
      _textRecognizer.close();
    }
  }

  static double? extractTotalAmount(String text) {
    final amounts = extractPossibleAmounts(text);
    if (amounts.isEmpty) return null;
    return amounts.reduce((a, b) => a > b ? a : b);
  }

  static List<double> extractPossibleAmounts(String text) {
    final Set<double> possibleAmounts = {};
    
    // Find all currency-like numbers (e.g., 294.75, 1.250,00, 856.96) anywhere in the text
    // Ignore prefix text blocks, giving the user direct control over the bounding box
    final numberRegex = RegExp(r'(?:[\*]?\s*)(\d{1,6}[\.,]\d{2})(?!\d)');
    final matches = numberRegex.allMatches(text);

    for (var match in matches) {
      String numStr = match.group(1)!;

      // Dynamically handle Turkish (comma decimal) and standard (dot decimal) formats
      if (numStr.contains(',') && numStr.contains('.')) {
        numStr = numStr.replaceAll('.', '').replaceAll(',', '.');
      } else if (numStr.contains(',')) {
        numStr = numStr.replaceAll(',', '.');
      }

      final amount = double.tryParse(numStr);
      if (amount != null) {
        possibleAmounts.add(amount);
      }
    }
    
    final resultList = possibleAmounts.toList();
    resultList.sort((a, b) => b.compareTo(a)); // Descending order
    return resultList;
  }
}
