import 'dart:async';
import 'dart:convert';
import 'dart:io';

class SheetsException implements Exception {
  final String message;
  const SheetsException(this.message);
  @override
  String toString() => message;
}

/// Az Apps Script webapp kliense (dart:io, külön csomag nélkül).
/// A Google a webapp-hívásokat átirányítja; POST után a válasz GET-tel jön.
class SheetsClient {
  final String url;
  final String token;
  final Duration timeout;
  const SheetsClient(this.url, this.token, {this.timeout = const Duration(seconds: 30)});

  Future<Map<String, dynamic>> get(String action, [Map<String, String> extra = const {}]) {
    final base = Uri.parse(url.trim());
    final uri = base.replace(queryParameters: {...base.queryParameters, 'action': action, 'token': token, ...extra});
    return _send(uri, null);
  }

  Future<Map<String, dynamic>> push(Map<String, dynamic> body) {
    return _send(Uri.parse(url.trim()), jsonEncode({...body, 'token': token, 'action': 'push'}));
  }

  Future<Map<String, dynamic>> _send(Uri uri, String? body) async {
    final client = HttpClient()..connectionTimeout = timeout;
    try {
      var method = body == null ? 'GET' : 'POST';
      var payload = body;
      var cur = uri;
      for (var hop = 0; hop < 6; hop++) {
        final req = await client.openUrl(method, cur).timeout(timeout);
        req.followRedirects = false;
        if (payload != null) {
          req.headers.contentType = ContentType('text', 'plain', charset: 'utf-8');
          req.add(utf8.encode(payload));
        }
        final res = await req.close().timeout(timeout);
        if (const [301, 302, 303, 307, 308].contains(res.statusCode)) {
          final loc = res.headers.value('location');
          await res.drain<void>();
          if (loc == null) throw const SheetsException('Átirányítás cél nélkül');
          cur = cur.resolve(loc);
          method = 'GET'; // Apps Script: a POST eredménye a átirányított címen GET-tel olvasható
          payload = null;
          continue;
        }
        final text = await utf8.decodeStream(res).timeout(timeout);
        if (res.statusCode != 200) throw SheetsException('HTTP ${res.statusCode}');
        Object? decoded;
        try {
          decoded = jsonDecode(text);
        } on FormatException {
          throw const SheetsException('Nem JSON a válasz. Ellenőrizd az URL-t és hogy a webapp hozzáférése „Bárki”.');
        }
        if (decoded is! Map<String, dynamic>) throw const SheetsException('Váratlan válasz');
        if (decoded['ok'] != true) {
          final err = '${decoded['error'] ?? 'ismeretlen hiba'}';
          throw SheetsException(err == 'unauthorized' ? 'Hibás token' : err);
        }
        return decoded;
      }
      throw const SheetsException('Túl sok átirányítás');
    } on TimeoutException {
      throw const SheetsException('Időtúllépés (nincs net?)');
    } on SocketException {
      throw const SheetsException('Nincs hálózat');
    } on HandshakeException {
      throw const SheetsException('Biztonságos kapcsolat hiba');
    } finally {
      client.close(force: true);
    }
  }
}
