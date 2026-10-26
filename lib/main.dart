import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'app_state.dart';
import 'models.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AtelierApp());
}

const emerald=Color(0xFF9BEB62);
const surface=Color(0xFF192329);
const muted=Color(0xFF9DAAB1);
const points=['Pneumatiques','Freinage','Éclairage','Fluides / vidange','Suspension','Batterie','Contrôle technique'];
const states=['Non contrôlé','OK','À surveiller','À remplacer'];

class AtelierApp extends StatefulWidget {
  const AtelierApp({super.key});
  @override State<AtelierApp> createState()=>_AtelierAppState();
}
class _AtelierAppState extends State<AtelierApp> {
  final app=AppState();
  @override void initState(){super.initState();app.initialize();}
  @override void dispose(){app.dispose();super.dispose();}
  @override Widget build(BuildContext context)=>MaterialApp(
    debugShowCheckedModeBanner:false,
    title:'Compagnon Atelier',
    theme: ThemeData(useMaterial3:true,brightness:Brightness.dark,
      scaffoldBackgroundColor:const Color(0xFF0E171C),
      colorScheme:ColorScheme.fromSeed(seedColor:emerald,brightness:Brightness.dark,primary:emerald,surface:surface),
      cardTheme:CardThemeData(color:surface,elevation:0,shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(18))),
      inputDecorationTheme:InputDecorationTheme(filled:true,fillColor:surface,contentPadding:const EdgeInsets.symmetric(horizontal:15,vertical:13),
        border:OutlineInputBorder(borderRadius:BorderRadius.circular(14),borderSide:BorderSide.none)),
      appBarTheme:const AppBarTheme(backgroundColor:Color(0xFF0E171C),centerTitle:false),
    ),
    home:AnimatedBuilder(animation:app,builder:(context,_)=>Shell(app:app)),
  );
}

class Shell extends StatefulWidget {
  final AppState app;
  const Shell({required this.app,super.key});
  @override State<Shell> createState()=>_ShellState();
}
class _ShellState extends State<Shell>{
  int page=0;
  String? selectedId;
  void openDiag(RepairOrder order)=>setState((){selectedId=order.id;page=1;});
  @override Widget build(BuildContext context){
    final app=widget.app;
    final labels=['Ordres de réparation','Diagnostic','Activité MO','Planning & pièces','Paramètres'];
    return Scaffold(
      appBar:AppBar(
        leading:Padding(padding:const EdgeInsets.all(9),child:Image.asset('assets/images/fv-logo.png',fit:BoxFit.contain)),
        title:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          const Text('COMPAGNON  /  ATELIER',style:TextStyle(fontSize:13,fontWeight:FontWeight.w800,letterSpacing:1.0)),
          Text('Centre ${app.connected ? app.storeCode : 'non vérifié'} · ${app.mode=='atelier'?'Mode atelier':'Mode magasin'}',style:const TextStyle(fontSize:11,color:muted))
        ]),
        actions:[
          Icon(app.connected?Icons.wifi_rounded:Icons.wifi_off_rounded,color:app.connected?emerald:Colors.orangeAccent),
          IconButton(tooltip:'Actualiser la connexion',onPressed:app.loading?null:app.reconnect,icon:const Icon(Icons.refresh_rounded)),
        ],
      ),
      body:SafeArea(child:Column(children:[
        if(!app.connected || app.lastError.isNotEmpty)
          Material(color:const Color(0xFF402D19),child:InkWell(onTap:app.reconnect,child:Padding(
            padding:const EdgeInsets.all(10),child:Row(children:[const Icon(Icons.info_outline,size:18),const SizedBox(width:8),
              Expanded(child:Text(app.loading?'Connexion en cours…':app.lastError.isEmpty?'Atelier non connecté. Appuyer pour réessayer.':app.lastError,
                style:const TextStyle(fontSize:11),maxLines:2,overflow:TextOverflow.ellipsis)),
              const Icon(Icons.chevron_right)])))),
        Expanded(child:Padding(padding:const EdgeInsets.fromLTRB(15,8,15,3),child: switch(page){
          0=>OrdersPage(app:app,onInspect:openDiag),
          1=>DiagnosticPage(app:app,selectedId:selectedId,onPickOrder:(id)=>setState(()=>selectedId=id)),
          2=>ActivityPage(app:app),
          3=>ServicesPage(app:app),
          _=>SettingsPage(app:app),
        })),
      ])),
      bottomNavigationBar:NavigationBar(height:69,selectedIndex:page,onDestinationSelected:(i)=>setState(()=>page=i),
        labelBehavior:NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(icon:Icon(Icons.assignment_outlined),selectedIcon:Icon(Icons.assignment),label:'OR'),
          NavigationDestination(icon:Icon(Icons.fact_check_outlined),selectedIcon:Icon(Icons.fact_check),label:'Diag'),
          NavigationDestination(icon:Icon(Icons.payments_outlined),selectedIcon:Icon(Icons.payments),label:'Activité'),
          NavigationDestination(icon:Icon(Icons.event_note_outlined),selectedIcon:Icon(Icons.event_note),label:'Planning'),
          NavigationDestination(icon:Icon(Icons.tune_outlined),selectedIcon:Icon(Icons.tune),label:'Réglages'),
        ]),
    );
  }
}

class Headline extends StatelessWidget {
  final String title,subtitle;
  final Widget? trailing;
  const Headline(this.title,this.subtitle,{this.trailing,super.key});
  @override Widget build(BuildContext context)=>Padding(padding:const EdgeInsets.only(bottom:12,top:6),child:
    Row(children:[Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Text(title,style:const TextStyle(fontSize:23,fontWeight:FontWeight.w900)),
      Text(subtitle,style:const TextStyle(fontSize:12,color:muted))])),if(trailing!=null) trailing!]));
}
class InlineEmpty extends StatelessWidget {
  final IconData icon;final String title,body;
  const InlineEmpty(this.icon,this.title,this.body,{super.key});
  @override Widget build(BuildContext context)=>Center(child:Column(mainAxisSize:MainAxisSize.min,children:[
    Icon(icon,size:54,color:muted),const SizedBox(height:12),Text(title,style:const TextStyle(fontWeight:FontWeight.bold,fontSize:17)),
    Padding(padding:const EdgeInsets.only(top:6,left:24,right:24),child:Text(body,textAlign:TextAlign.center,style:const TextStyle(color:muted,fontSize:13)))
  ]));
}
Widget panel(Widget child)=>Card(child:Padding(padding:const EdgeInsets.all(15),child:child));

class OrdersPage extends StatefulWidget {
  final AppState app;final ValueChanged<RepairOrder> onInspect;
  const OrdersPage({required this.app,required this.onInspect,super.key});
  @override State<OrdersPage> createState()=>_OrdersPageState();
}
class _OrdersPageState extends State<OrdersPage>{
  String query='';String filter='Tous';
  @override Widget build(BuildContext context){
    final app=widget.app;
    final filtered=app.orders.where((o){
      final q=query.toLowerCase();
      final matches='${o.label} ${o.plate} ${o.vehicle}'.toLowerCase().contains(q);
      final today=DateTime.now().toIso8601String().substring(0,10);
      return matches && (filter=='Tous' || (filter=='Aujourd’hui' && o.date.startsWith(today)));
    }).toList();
    return Column(children:[
      Headline('Ordres de réparation','Données serveur · ${app.orders.length} dossier(s)',
        trailing:IconButton.filledTonal(onPressed:app.loading?null:app.refreshOrders,icon:const Icon(Icons.sync))),
      TextField(onChanged:(v)=>setState(()=>query=v),decoration:const InputDecoration(hintText:'Rechercher une plaque ou un OR',prefixIcon:Icon(Icons.search))),
      const SizedBox(height:9),
      Row(children:[for(final f in ['Tous','Aujourd’hui']) Padding(padding:const EdgeInsets.only(right:8),child:ChoiceChip(
        label:Text(f),selected:filter==f,onSelected:(_)=>setState(()=>filter=f)))]),
      const SizedBox(height:6),
      Expanded(child:app.loading && app.orders.isEmpty?const Center(child:CircularProgressIndicator()):
        filtered.isEmpty?InlineEmpty(Icons.car_repair_outlined,app.orders.isEmpty?'Aucun OR chargé':'Aucun résultat',
          app.connected?'Vérifie la réponse du serveur et les filtres.':'Connecte-toi au Wi-Fi atelier pour récupérer les vrais OR.'):
        RefreshIndicator(onRefresh:app.refreshOrders,child:ListView.builder(itemCount:filtered.length,itemBuilder:(context,i){
          final o=filtered[i];
          return Card(child:ListTile(
            contentPadding:const EdgeInsets.symmetric(horizontal:15,vertical:6),
            title:Text(o.plate.isNotEmpty?o.plate:'OR ${o.label}',style:const TextStyle(fontWeight:FontWeight.w800)),
            subtitle:Text('OR ${o.label}\n${o.vehicle.isEmpty?o.status:o.vehicle}  ·  ${o.status}',maxLines:3),
            isThreeLine:true,
            trailing:const Icon(Icons.arrow_forward_ios,size:15,color:emerald),
            onTap:()=>widget.onInspect(o)));
        }))),
    ]);
  }
}

class DiagnosticPage extends StatefulWidget {
  final AppState app; final String? selectedId;final ValueChanged<String> onPickOrder;
  const DiagnosticPage({required this.app,required this.selectedId,required this.onPickOrder,super.key});
  @override State<DiagnosticPage> createState()=>_DiagnosticPageState();
}
class _DiagnosticPageState extends State<DiagnosticPage>{
  final note=TextEditingController();String? currentId;
  @override void dispose(){note.dispose();super.dispose();}
  @override Widget build(BuildContext context){
    final app=widget.app;
    final orders=app.orders;
    final id=orders.any((e)=>e.id==widget.selectedId)?widget.selectedId:(orders.isEmpty?null:orders.first.id);
    if(id!=currentId){currentId=id;note.text=id==null?'':app.draftFor(id).note;}
    if(id==null)return const InlineEmpty(Icons.fact_check_outlined,'Diagnostic en attente','Charge des ordres de réparation pour démarrer un diagnostic.');
    final order=orders.firstWhere((o)=>o.id==id);
    final draft=app.draftFor(id);
    return Column(children:[
      Headline('Diagnostic','Brouillon local · non envoyé au serveur'),
      DropdownButtonFormField<String>(key:ValueKey(id),value:id,isExpanded:true,
        items:[for(final o in orders) DropdownMenuItem(value:o.id,child:Text('${o.plate.isEmpty?'OR '+o.label:o.plate} · ${o.label}',overflow:TextOverflow.ellipsis))],
        onChanged:(v){if(v!=null)widget.onPickOrder(v);}),
      const SizedBox(height:10),
      Expanded(child:ListView(children:[
        panel(Row(children:[const Icon(Icons.directions_car,color:emerald),const SizedBox(width:9),Expanded(child:Column(
          crossAxisAlignment:CrossAxisAlignment.start,children:[Text(order.plate.isEmpty?'OR ${order.label}':order.plate,style:const TextStyle(fontWeight:FontWeight.w800)),
          Text(order.vehicle.isEmpty?'Dossier ${order.label}':order.vehicle,style:const TextStyle(color:muted,fontSize:12))]))])),
        for(final point in points) Card(child:Padding(padding:const EdgeInsets.symmetric(horizontal:12,vertical:5),child:Row(children:[
          Expanded(child:Text(point,style:const TextStyle(fontWeight:FontWeight.w600,fontSize:13))),
          DropdownButton<String>(value:states.contains(draft.points[point])?draft.points[point]:'Non contrôlé',
            underline:const SizedBox.shrink(),isDense:true,style:const TextStyle(fontSize:12,color:emerald),
            items:[for(final s in states) DropdownMenuItem(value:s,child:Text(s))],onChanged:(s){if(s!=null){
              final changes=Map<String,String>.from(draft.points);changes[point]=s;app.saveDraft(id,points:changes);
            }})]))),
        const SizedBox(height:8),
        TextField(controller:note,minLines:2,maxLines:4,decoration:const InputDecoration(hintText:'Notes de diagnostic / observations')),
        const SizedBox(height:8),
        FilledButton.icon(onPressed:()=>app.saveDraft(id,note:note.text).then((_){
          if(context.mounted)ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Diagnostic enregistré localement, pas transmis au serveur.')));
        }),icon:const Icon(Icons.save_outlined),label:const Text('Enregistrer le brouillon')),
        const SizedBox(height:10),
        Row(children:[Expanded(child:Text('Photos · ${draft.photos.length}/10',style:const TextStyle(fontWeight:FontWeight.bold))),
          IconButton(tooltip:'Appareil photo',onPressed:()=>_photo(app,id,ImageSource.camera),icon:const Icon(Icons.photo_camera_outlined)),
          IconButton(tooltip:'Galerie',onPressed:()=>_photo(app,id,ImageSource.gallery),icon:const Icon(Icons.add_photo_alternate_outlined))]),
        if(draft.photos.isNotEmpty) SizedBox(height:110,child:ListView(scrollDirection:Axis.horizontal,children:[
          for(final p in draft.photos) Padding(padding:const EdgeInsets.only(right:7),child:Stack(children:[
            ClipRRect(borderRadius:BorderRadius.circular(12),child:Image.file(File(p),width:108,height:108,fit:BoxFit.cover,
              errorBuilder:(_,__,___)=>const SizedBox(width:108,child:Icon(Icons.broken_image_outlined)))),
            Positioned(right:0,top:0,child:IconButton.filledTonal(icon:const Icon(Icons.close,size:16),
              onPressed:()=>app.removePhoto(id,p)))]))])),
        const SizedBox(height:15),
      ])),
    ]);
  }
  Future<void> _photo(AppState app,String id,ImageSource source) async {
    final error=await app.addPhoto(id,source);
    if(error!=null && mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(error)));
  }
}

class ActivityPage extends StatelessWidget {
  final AppState app;
  const ActivityPage({required this.app,super.key});
  @override Widget build(BuildContext context){
    final now=DateTime.now();
    final thisMonth=app.activities.where((e)=>e.date.month==now.month && e.date.year==now.year).toList();
    return Column(children:[
      Headline('Activité main-d’œuvre','Saisie manuelle · montants TTC',trailing:IconButton.filledTonal(
        onPressed:()=>_newEntry(context),icon:const Icon(Icons.add))),
      panel(Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        const Text('TOTAL DU MOIS · LOCAL',style:TextStyle(color:muted,fontSize:11,letterSpacing:1.1)),
        const SizedBox(height:5),Text('${app.monthlyRevenue.toStringAsFixed(2).replaceAll('.',',')} €',
          style:const TextStyle(color:emerald,fontSize:32,fontWeight:FontWeight.w900)),
        Text('${thisMonth.length} entrée(s) · pas de synchronisation avec Feu Vert',style:const TextStyle(color:muted,fontSize:11))])),
      const SizedBox(height:8),
      Expanded(child:thisMonth.isEmpty?const InlineEmpty(Icons.euro_outlined,'Pas encore d’activité','Ajoute une ligne de main-d’œuvre pour commencer ton suivi.'):
        ListView.builder(itemCount:thisMonth.length,itemBuilder:(context,i){
          final e=thisMonth[i];return Card(child:ListTile(
            title:Text(e.label,style:const TextStyle(fontWeight:FontWeight.w700)),
            subtitle:Text('${e.date.day}/${e.date.month} · ${e.technician.isEmpty?'Sans technicien':e.technician}${e.orderId.isNotEmpty?' · OR ${e.orderId}':''}'),
            trailing:Row(mainAxisSize:MainAxisSize.min,children:[Text('${e.amount.toStringAsFixed(2)} €',style:const TextStyle(color:emerald,fontWeight:FontWeight.bold)),
              IconButton(onPressed:()=>app.deleteActivity(e.id),icon:const Icon(Icons.delete_outline,size:18))])));
        })),
    ]);
  }
  void _newEntry(BuildContext context){
    final label=TextEditingController();final amount=TextEditingController();final order=TextEditingController();
    showDialog<void>(context:context,builder:(dialogContext)=>AlertDialog(title:const Text('Ajouter une MO TTC'),content:Column(mainAxisSize:MainAxisSize.min,children:[
      TextField(controller:label,decoration:const InputDecoration(labelText:'Prestation (ex. vidange)')),
      const SizedBox(height:10),TextField(controller:amount,keyboardType:const TextInputType.numberWithOptions(decimal:true),
        decoration:const InputDecoration(labelText:'Montant TTC (€)')),
      const SizedBox(height:10),TextField(controller:order,decoration:const InputDecoration(labelText:'N° OR (facultatif)')),
    ]),actions:[TextButton(onPressed:()=>Navigator.pop(dialogContext),child:const Text('Annuler')),
      FilledButton(onPressed:(){
        final value=double.tryParse(amount.text.trim().replaceAll(',','.'));
        if(label.text.trim().isEmpty || value==null || value<0) return;
        app.addActivity(label:label.text.trim(),amount:value,orderId:order.text.trim());
        Navigator.pop(dialogContext);
      },child:const Text('Enregistrer'))]));
  }
}

class ServicesPage extends StatelessWidget {
  final AppState app;const ServicesPage({required this.app,super.key});
  Future<void> _open(BuildContext context,String url) async {
    final ok=await launchUrl(Uri.parse(url),mode:LaunchMode.externalApplication);
    if(!ok && context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Impossible d’ouvrir le service.')));
  }
  @override Widget build(BuildContext context)=>ListView(children:[
    const Headline('Planning & pièces','Accès officiels et informations disponibles'),
    panel(Column(children:[
      ListTile(leading:const Icon(Icons.calendar_month,color:emerald),title:const Text('Planning atelier'),
        subtitle:const Text('Ouvrir le planning officiel'),trailing:const Icon(Icons.open_in_new,size:18),
        onTap:()=>_open(context,'https://planning.feuvert.fr/task')),
      const Divider(),
      ListTile(leading:const Icon(Icons.inventory_2_outlined,color:emerald),title:const Text('MCP / pièces'),
        subtitle:const Text('Ouvrir le portail officiel'),trailing:const Icon(Icons.open_in_new,size:18),
        onTap:()=>_open(context,'https://vmtorino.feuvert.fr')),
    ])),
    const SizedBox(height:10),
    const Text('PIÈCES CONNUES PAR LES OR',style:TextStyle(letterSpacing:1,color:muted,fontSize:11)),
    const SizedBox(height:7),
    ...app.orders.take(30).map((o){
      final parts=o.raw['parts'] ?? o.raw['pieces'] ?? o.raw['articles'] ?? o.raw['items'];
      final count=parts is List?parts.length:null;
      if(count==null)return const SizedBox.shrink();
      return Card(child:ListTile(leading:const Icon(Icons.handyman_outlined),title:Text('OR ${o.label}'),
        subtitle:Text('$count ligne(s) de pièces dans la réponse OR'),
        trailing:const Icon(Icons.info_outline,size:18),onTap:()=>showDialog<void>(context:context,
          builder:(ctx)=>AlertDialog(title:Text('Pièces · OR ${o.label}'),content:SingleChildScrollView(
            child:Text(parts.toString(),style:const TextStyle(fontSize:12))),actions:[TextButton(onPressed:()=>Navigator.pop(ctx),child:const Text('Fermer'))]))));
    }),
    const SizedBox(height:9),
    const Text('L’import automatique MCP et le pointage des pièces restent désactivés tant que leurs routes n’ont pas été vérifiées sur le réseau atelier.',style:TextStyle(fontSize:12,color:muted)),
  ]);
}

class SettingsPage extends StatefulWidget {
  final AppState app;const SettingsPage({required this.app,super.key});
  @override State<SettingsPage> createState()=>_SettingsPageState();
}
class _SettingsPageState extends State<SettingsPage>{
  late final TextEditingController store=TextEditingController(text:widget.app.storeCode);
  late final TextEditingController tech=TextEditingController(text:widget.app.technician);
  @override void dispose(){store.dispose();tech.dispose();super.dispose();}
  @override Widget build(BuildContext context){final app=widget.app;return ListView(children:[
    const Headline('Paramètres','Connexion et profil du poste'),
    panel(Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      const Text('RÉSEAU',style:TextStyle(color:emerald,fontWeight:FontWeight.bold,fontSize:12)),
      const SizedBox(height:8),
      Text(app.networkMessage,style:const TextStyle(fontSize:13)),const SizedBox(height:6),
      Text('Serveur : ${app.api.baseUrl}',style:const TextStyle(color:muted,fontSize:11)),
      const SizedBox(height:6),
      Text(app.connected?'Identification centre confirmée.':'Identification centre non confirmée.',
        style:TextStyle(color:app.connected?emerald:Colors.orangeAccent,fontWeight:FontWeight.bold)),
      const SizedBox(height:8),
      SizedBox(width:double.infinity,child:FilledButton.icon(onPressed:app.loading?null:app.reconnect,
        icon:const Icon(Icons.wifi),label:const Text('Détecter le Wi-Fi et se connecter'))),
    ])),
    panel(Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      const Text('POSTE',style:TextStyle(color:emerald,fontWeight:FontWeight.bold,fontSize:12)),
      const SizedBox(height:10),
      TextField(controller:store,keyboardType:TextInputType.number,decoration:const InputDecoration(labelText:'Code centre manuel (optionnel)')),
      const SizedBox(height:12),
      TextField(controller:tech,decoration:const InputDecoration(labelText:'Nom / identifiant technicien')),
      const SizedBox(height:12),
      SegmentedButton<String>(showSelectedIcon:false,segments:const [
        ButtonSegment(value:'atelier',label:Text('Atelier'),icon:Icon(Icons.handyman)),
        ButtonSegment(value:'magasin',label:Text('Magasin'),icon:Icon(Icons.storefront)),
      ],selected:{app.mode},onSelectionChanged:(v)=>app.saveSettings(newMode:v.first)),
      const SizedBox(height:12),
      SizedBox(width:double.infinity,child:FilledButton.tonal(onPressed:(){
        app.saveSettings(newStoreCode:store.text.trim(),newTechnician:tech.text.trim());
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Paramètres enregistrés localement.')));
      },child:const Text('Enregistrer le poste'))),
    ])),
    const Padding(padding:EdgeInsets.symmetric(horizontal:7,vertical:10),child:Text(
      'Version 0.1 · Refonte indépendante · La consultation des OR est en lecture seule. Les diagnostics, photos et activités restent sur cet appareil et ne modifient pas les systèmes Feu Vert.',
      style:TextStyle(color:muted,fontSize:12))),
  ]);}
}
