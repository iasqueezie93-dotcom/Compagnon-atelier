import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models.dart';

/// Read-only adapter for the routes observed in the original APK.
/// Never invent an endpoint to write diagnostics, reservations or parts.
class AtelierApi {
  final http.Client _client;
  String baseUrl;
  AtelierApi({this.baseUrl='http://bulbizar.feuvert.fr',http.Client? client}) : _client=client ?? http.Client();

  Future<dynamic> getJson(String path) async {
    final uri=Uri.parse('${baseUrl.replaceAll(RegExp(r'/$'), '')}$path');
    final response=await _client.get(uri,headers:{'Accept':'application/json'})
        .timeout(const Duration(seconds:20));
    if(response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError('Serveur ${response.statusCode} sur $path');
    }
    try { return jsonDecode(utf8.decode(response.bodyBytes)); }
    on FormatException { throw const FormatException('Réponse serveur non JSON : vérifie le Wi-Fi et la session officielle.'); }
  }

  /// GET /rdmstore/store/whoami is attested in the original .so.
  Future<String> identifyStore() async {
    final result=await getJson('/rdmstore/store/whoami');
    final code=_findStoreCode(result);
    if(code.isEmpty) {throw const FormatException('Centre absent de la réponse whoami.');}
    return code;
  }

  /// Verified API prefix and /repair-orders path; actual data shape needs on-site testing.
  Future<List<RepairOrder>> getOrders(String code) async {
    if(!RegExp(r'^\d{1,6}$').hasMatch(code)) throw const FormatException('Code centre invalide');
    final result=await getJson('/smartdiag/store-codes/$code/repair-orders');
    final list=_findList(result);
    if(list==null) throw const FormatException('Format des OR non reconnu. Adapter le parseur avec une réponse anonymisée.');
    return [for(var i=0;i<list.length;i++) RepairOrder.fromJson(list[i],i)];
  }

  static String _findStoreCode(dynamic value,[int depth=0]) {
    if(depth>6 || value==null) return '';
    if(value is num || value is String) {
      final str=value.toString().trim();
      return RegExp(r'^\d{1,6}$').hasMatch(str) ? str : '';
    }
    if(value is Map) {
      final map=asMap(value);
      final code=pick(map,['storeCode','store_code','centerCode','centreCode','codeMagasin','codeCentre']);
      if(RegExp(r'^\d{1,6}$').hasMatch(code)) return code;
      final direct=pick(map,['code']);
      if(RegExp(r'^\d{1,6}$').hasMatch(direct)) return direct;
      for(final field in ['store','centre','center','shop','data','result','user']) {
        final found=_findStoreCode(map[field],depth+1);
        if(found.isNotEmpty) return found;
      }
    }
    if(value is List) {
      for(final item in value) { final found=_findStoreCode(item,depth+1);if(found.isNotEmpty) return found; }
    }
    return '';
  }

  static List<dynamic>? _findList(dynamic obj,[int depth=0]) {
    if(obj is List) return obj;
    if(depth>4 || obj is! Map) return null;
    final map=asMap(obj);
    for(final k in ['repairOrders','repair_orders','orders','items','results','data','content']) {
      final found=_findList(map[k],depth+1);
      if(found!=null) return found;
    }
    return null;
  }
  void close() => _client.close();
}
