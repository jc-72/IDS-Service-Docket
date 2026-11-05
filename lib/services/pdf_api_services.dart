
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../main.dart' show ProjectRecord;

class PdfApiService {
  // Replace this with your actual Oracle backend URL after deployment.
  static const String baseUrl = 'https://YOUR-ORACLE-API-URL';

  static Future<Uint8List> generatePdf(ProjectRecord record) async {
    final uri = Uri.parse('$baseUrl/api/pdf/generate');

    final response = await http
        .post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/pdf',
          },
          body: jsonEncode(record.toJson()),
        )
        .timeout(const Duration(seconds: 60));

    if (response.statusCode != 200) {
      String message = 'PDF generation failed.';

      try {
        final error = jsonDecode(utf8.decode(response.bodyBytes));
        if (error is Map && error['message'] != null) {
          message = error['message'].toString();
        }
      } catch (_) {
        // Keep the default error message.
      }

      throw Exception('$message (HTTP ${response.statusCode})');
    }

    final contentType =
        response.headers['content-type']?.toLowerCase() ?? '';

    if (!contentType.contains('application/pdf')) {
      throw Exception(
        'The server did not return a PDF file. '
        'Received: $contentType',
      );
    }

    return Uint8List.fromList(response.bodyBytes);
  }
}
