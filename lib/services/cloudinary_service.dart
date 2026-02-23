import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CloudinaryService {
  static const _cloudName = 'dcktapkfm';
  static const _uploadPreset = 'tondo_uploads';

  Future<String?> uploadImage(File imageFile) async {
    try {
      final uri =
          Uri.parse('https://api.cloudinary.com/v1_1/$_cloudName/image/upload');

      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = _uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      final response = await request.send();
      final body = await response.stream.bytesToString();
      final json = jsonDecode(body);

      if (response.statusCode == 200) {
        return json['secure_url'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
