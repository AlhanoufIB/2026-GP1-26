import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ImageUploadService {
  ImageUploadService._();
  static final instance = ImageUploadService._();

  static const _cloudName = 'fakhkcsv';
  static const _uploadPreset = 'mullak_unsigned';

  /// يرفع ملفاً ويرجّع الرابط الآمن (https)
  Future<String> upload(String filePath) async {
    final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/$_cloudName/image/upload');
    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = _uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', File(filePath).path));

    final response = await request.send();
    final body = await response.stream.bytesToString();
    if (response.statusCode != 200) {
      throw Exception('فشل رفع الصورة (${response.statusCode}): $body');
    }
    return jsonDecode(body)['secure_url'] as String;
  }
}