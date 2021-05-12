library dart_base45;

import 'dart:typed_data';

class Base45 {

  static const int baseSize = 45;
  static const int baseSizeSquared = 2025;
  static const int chunkSize = 2;
  static const int encodedChunkSize = 3;
  static const int smallEncodedChunkSize = 2;
  static const int byteSize = 256;

  static const List<String> encoding = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
  "A", "B", "C", "D", "E", "F", "G", "H", "I", "J",
  "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T",
  "U", "V", "W", "X", "Y", "Z", " ", "\$", "%", "*",
  "+", "-", ".", "/", ":"];

  static Map<String, int> decoding;

  static Uint8List decode(String input){

    if( null == input) {
      throw ArgumentError.notNull(input);
    }

    if(0 == input.length){
      return Uint8List(0);
    }

    var remainderSize = input.length % encodedChunkSize;
    if( remainderSize == 1){
      throw ArgumentError.value(input, "input", "has incorrect length");
    }

    if (null == decoding) {
      decoding = new Map<String, int>();
      for (int i = 0; i < encoding.length; ++i) {
        decoding[encoding[i]] = i;
      }
    }

    var buffer = new Uint8List(input.length);
    for (var i = 0; i < input.length; ++i) {
      var found = decoding[input[i]];
      if (null == found){
        throw new Exception("Invalid character at position $i.");
      }
      buffer[i] = found;
    }

    var wholeChunkCount = (buffer.length / encodedChunkSize).truncate();

    var result = new Uint8List(wholeChunkCount * chunkSize + (remainderSize == chunkSize ? 1 : 0));
    var resultIndex = 0;
    var wholeChunkLength = wholeChunkCount * encodedChunkSize;
    for (var i = 0; i < wholeChunkLength;) {
      var val = buffer[i++] + baseSize * buffer[i++] + baseSizeSquared * buffer[i++];
      result[resultIndex++] = (val / byteSize).truncate(); //result is always in the range 0-255 - % ByteSize omitted.
      result[resultIndex++] = val % byteSize;
    }

    if (remainderSize == 0)
      return result;

    result[result.length - 1] = buffer[buffer.length - 2] + baseSize * buffer[buffer.length - 1]; //result is always in the range 0-255 - % ByteSize omitted.
    return result;
  }

}






















