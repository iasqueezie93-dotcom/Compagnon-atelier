import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'atelier_api.dart';
import 'models.dart';

class AppState extends ChangeNotifier {
  static const channel=MethodChannel('compagnon_atelier/network');
  final AtelierApi api=AtelierApi();
  SharedPreferences? _prefs;
  String storeCode=''; // Do not present any centre as verified before whoami succeeds.
  String technician='';
  String networkMessage='Non vérifié';
  String lastError='';
  bool connected=false;
  bool loading=false;
  bool wifiBound=false;
  String mode='atelier';
  List<RepairOrder> orders=[];
  List<ActivityEntry> activities=[];
  Map<String,InspectionDraft> drafts={};

  Future<void> initialize() async {
    _prefs=await SharedPreferences.getInstance();
    storeCode=_prefs!.getString('storeCode') ?? ''; // previously confirmed code, if any
    technician=_prefs!.getString('technician') ?? '';
    mode=_prefs!.getString('mode') ?? 'atelier';
    try {
      activities=(jsonDecode(_prefs!.getString('activities') ?? '[]') as List)
          .map(ActivityEntry.fromJson).toList();
    } catch (_) {activities=[];}
    try {
      final saved=asMap(jsonDecode(_prefs!.getString('drafts') ?? '{}'));
      drafts=saved.map((k,v)=>MapEntry(k,InspectionDraft.fromJson(v)));
    } catch (_) {drafts={};}
    notifyListeners();
    await reconnect();
  }

  Future<void> reconnect() async {
    loading=true; connected=false; lastError='';notifyListeners();
    try {
      try {
        final data=await channel.invokeMapMethod<String,dynamic>('bindWifi');
        wifiBound=data?['bound']==true;
        networkMessage=(data?['message'] ?? 'État réseau inconnu').toString();
      } on MissingPluginException { networkMessage='Canal Android indisponible (mode non natif)'; }
      catch (e) {networkMessage='Wi-Fi : $e';}
      final detected=await api.identifyStore();
      storeCode=detected;await _prefs?.setString('storeCode',storeCode);
      connected=true;
      await refreshOrders();
    } catch (e) {lastError=e.toString();connected=false;}
    loading=false;notifyListeners();
  }

  Future<void> refreshOrders() async {
    loading=true;lastError='';notifyListeners();
    try {
      if(storeCode.isEmpty) throw const FormatException('Aucun centre identifié : lancer whoami depuis le Wi-Fi atelier.');
      orders=await api.getOrders(storeCode);
    } catch (e) {lastError=e.toString();}
    loading=false;notifyListeners();
  }

  Future<void> saveSettings({String? newStoreCode,String? newTechnician,String? newMode}) async {
    if(newStoreCode!=null && RegExp(r'^\d{1,6}$').hasMatch(newStoreCode)){
      storeCode=newStoreCode;await _prefs?.setString('storeCode',storeCode);
    }
    if(newTechnician!=null){technician=newTechnician.trim();await _prefs?.setString('technician',technician);}
    if(newMode!=null){mode=newMode;await _prefs?.setString('mode',mode);}
    notifyListeners();
  }

  InspectionDraft draftFor(String orderId) => drafts.putIfAbsent(orderId,()=>InspectionDraft());
  Future<void> saveDraft(String orderId,{Map<String,String>? points,String? note}) async {
    final current=draftFor(orderId);
    if(points!=null) current.points=points;
    if(note!=null) current.note=note;
    current.updatedAt=DateTime.now();
    await _persistDrafts();notifyListeners();
  }

  Future<String?> addPhoto(String orderId,ImageSource source) async {
    final d=draftFor(orderId);
    if(d.photos.length>=10) return 'Maximum 10 photos pour ce diagnostic.';
    try {
      final picked=await ImagePicker().pickImage(source:source,imageQuality:75,maxWidth:1920);
      if(picked==null) return null;
      final root=await getApplicationDocumentsDirectory();
      final dir=Directory('${root.path}/diagnostics');await dir.create(recursive:true);
      final file=await File(picked.path).copy('${dir.path}/${DateTime.now().microsecondsSinceEpoch}.jpg');
      d.photos.add(file.path);d.updatedAt=DateTime.now();
      await _persistDrafts();notifyListeners();
      return null;
    }catch(e){return 'Erreur photo : $e';}
  }

  Future<void> removePhoto(String orderId,String path) async {
    draftFor(orderId).photos.remove(path);
    try {await File(path).delete();}catch (_){ }
    await _persistDrafts();notifyListeners();
  }
  Future<void> _persistDrafts() async {
    await _prefs?.setString('drafts',jsonEncode(drafts.map((k,v)=>MapEntry(k,v.toJson()))));
  }

  Future<void> addActivity({required String label,required double amount,String orderId=''}) async {
    activities.insert(0,ActivityEntry(id:DateTime.now().microsecondsSinceEpoch.toString(),
      label:label,orderId:orderId,technician:technician,date:DateTime.now(),amount:amount));
    await _saveActivities();notifyListeners();
  }
  Future<void> deleteActivity(String id) async {
    activities.removeWhere((a)=>a.id==id);await _saveActivities();notifyListeners();
  }
  Future<void> _saveActivities() async {
    await _prefs?.setString('activities',jsonEncode(activities.map((e)=>e.toJson()).toList()));
  }
  double get monthlyRevenue {
    final now=DateTime.now();
    return activities.where((a)=>a.date.year==now.year && a.date.month==now.month).fold(0.0,(sum,a)=>sum+a.amount);
  }
}
