import 'package:flutter_test/flutter_test.dart';
import 'package:served/signature_image_data.dart';

void main() {
  group('signature source resolution', () {
    test('returns a network URL when one is stored', () {
      final source = resolveSignatureSource({
        'signatureUrl': 'https://example.com/signature.png',
      });

      expect(source?.type, SignatureSourceType.network);
      expect(source?.networkUrl, 'https://example.com/signature.png');
    });

    test('returns base64 data when no URL is available', () {
      final source = resolveSignatureSource({
        'signatureBase64': 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAACklEQVR4nGMAAA3ABQABJQABJQABJQABJQABJQABJQABJQABJQABJQABJQABJQABJQABJQABJQABJQABJQABJQABJQABJQABJQABJQABJQABJQABJQABJQABJQABJQABJQABJQABJQABJQABJQABJQABJQABJQABJQABJQABJQABJQABJQABJQABJQABJQABJQABJQABJQABJQABJQABJQABJQABJQABJQABJQABJQABJQABQABJQABJQABJQAAABJRU5ErkJggg==',
      });

      expect(source?.type, SignatureSourceType.base64);
      expect(source?.base64Data, isNotEmpty);
    });
  });
}
