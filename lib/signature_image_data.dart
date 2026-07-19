import 'dart:convert';

enum SignatureSourceType { network, base64 }

class SignatureImageSource {
  const SignatureImageSource({
    required this.type,
    this.networkUrl,
    this.base64Data,
  });

  final SignatureSourceType type;
  final String? networkUrl;
  final String? base64Data;
}

SignatureImageSource? resolveSignatureSource(Map<String, dynamic> hourData) {
  final signatureUrl = hourData['signatureUrl']?.toString().trim();
  if (signatureUrl != null && signatureUrl.isNotEmpty) {
    return SignatureImageSource(
      type: SignatureSourceType.network,
      networkUrl: signatureUrl,
    );
  }

  final signatureBase64 = hourData['signatureBase64']?.toString().trim();
  if (signatureBase64 != null && signatureBase64.isNotEmpty) {
    return SignatureImageSource(
      type: SignatureSourceType.base64,
      base64Data: signatureBase64,
    );
  }

  return null;
}

String? decodeSignatureBase64(String? value) {
  if (value == null || value.isEmpty) {
    return null;
  }

  try {
    return base64Decode(value).isEmpty ? null : value;
  } catch (_) {
    return null;
  }
}