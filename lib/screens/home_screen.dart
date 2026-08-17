import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/agenda_provider.dart';
import '../models/agendamento.dart';
import '../widgets/agendamento_card.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _selectedDate = DateTime.now();

  Future<void> _openWhatsApp(String tel) async {
    if (tel.isEmpty) return;
    String clean = tel.replaceAll(RegExp(r'[^0-9]'), '');
    if (clean.length <= 11) clean = '55$clean';
    final app = Uri.parse('whatsapp://send?phone=$clean');
    final web = Uri.parse('https://wa.me/$clean');
    if (await canLaunchUrl(app)) {
      await launchUrl(app, mode: LaunchMode.externalApplication);
    } else {
      await launchUrl(web, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _backup() async {
    final p = Provider.of<AgendaProvider>(context, listen: false);
    final data = {'agendamentos': p.agendamentos.map((e)=>e.toJson()).toList(), 'servicos': p.servicos};
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/backup_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.json');
    await file.writeAsString(jsonEncode(data));
    await Share.shareXFiles([XFile(file.path)], text: 'Backup Agenda Facil MEI');
  }

  void _showFinanceiro() {
    final provider = Provider.of<AgendaProvider>(context, listen: false);
    final ags = provider.getAgendamentosPorData(_selectedDate);
    final total = provider.getTotalDoDia(_selectedDate);
    final pend = provider.getPendenteDoDia(_selectedDate);
    showDialog(context: context, builder: (ctx)=>AlertDialog(
      title: Text('Financeiro - ${DateFormat('dd/MM').format(_selectedDate)}'),
      content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Clientes: ${ags.length}'),
        Text('Total: R\$${total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
        Text('Pendente: R\$${pend.toStringAsFixed(2)}', style: const TextStyle(color: Colors.red)),
      ]),
      actions: [TextButton(onPressed: ()=>Navigator.pop(ctx), child: const Text('OK'))],
    ));
  }

  void _showAddDialog() {
    final nome = TextEditingController();
    final tel = TextEditingController();
    final servNovo = TextEditingController();
    TimeOfDay hora = const TimeOfDay(hour: 7, minute: 0);
    String? sel;

    showDialog(context: context, builder: (ctx){
      return StatefulBuilder(builder: (context, setD){
        return Consumer<AgendaProvider>(builder: (context, provider, _) {
          return AlertDialog(
            title: const Text('Novo Agendamento'),
            content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(controller: nome, decoration: const InputDecoration(labelText: 'Nome', prefixIcon: Icon(Icons.person))),
              const SizedBox(height:8),
              TextField(controller: tel, decoration: const InputDecoration(labelText: 'WhatsApp', prefixIcon: Icon(Icons.phone)), keyboardType: TextInputType.phone),
              const SizedBox(height:12),
              DropdownButtonFormField<String>(value: sel, decoration: const InputDecoration(labelText: 'Servico', border: OutlineInputBorder()), items: provider.servicos.map((s)=>DropdownMenuItem(value:s, child:Text(s, overflow: TextOverflow.ellipsis))).toList(), onChanged: (v)=>setD(()=>sel=v)),
              const SizedBox(height:8),
              TextField(controller: servNovo, decoration: const InputDecoration(labelText: 'Novo servico (ex: Corte + Luzes R\$150)', border: OutlineInputBorder())),
              const SizedBox(height:6),
              SizedBox(width: double.infinity, child: ElevatedButton.icon(icon: const Icon(Icons.save), label: const Text('SALVAR SERVICO'), onPressed: () async {
                final n = servNovo.text.trim();
                if (n.isEmpty) return;
                await provider.addServico(n);
                setD(()=> sel=n);
                servNovo.clear();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Servico ${n} salvo!'), backgroundColor: Colors.green));
              })),
              const SizedBox(height:12),
              Row(children: [const Icon(Icons.access_time), const SizedBox(width:8), Text('Horario: ${hora.format(context)}', style: const TextStyle(fontWeight: FontWeight.bold)), const Spacer(), TextButton(onPressed: () async { final t=await showTimePicker(context:context, initialTime:hora); if (t!=null) setD(()=>hora=t); }, child: const Text('Alterar'))]),
            ])),
            actions: [
              TextButton(onPressed: ()=>Navigator.pop(ctx), child: const Text('Cancelar')),
              ElevatedButton(onPressed: (){
                if (nome.text.trim().isEmpty) return;
                final ag = Agendamento(id: DateTime.now().millisecondsSinceEpoch.toString(), nomeCliente: nome.text.trim(), telefone: tel.text.trim(), servico: sel ?? servNovo.text.trim(), data: _selectedDate, horario: hora, createdAt: DateTime.now(), pago: false);
                provider.addAgendamento(ag);
                Navigator.pop(ctx);
              }, child: const Text('Agendar')),
            ],
          );
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agenda Facil MEI'), backgroundColor: Colors.deepPurple, foregroundColor: Colors.white, actions: [
        IconButton(icon: const Text('\$', style: TextStyle(fontSize:20, fontWeight: FontWeight.bold, color: Colors.white)), onPressed: _showFinanceiro),
        IconButton(icon: const Icon(Icons.cloud_upload), onPressed: _backup),
      ]),
      body: Consumer<AgendaProvider>(builder: (context, provider, _) {
        final ags = provider.getAgendamentosPorData(_selectedDate);
        ags.sort((a,b){ int c=a.horario.hour.compareTo(b.horario.hour); if(c!=0) return c; return a.horario.minute.compareTo(b.horario.minute); });
        final total = provider.getTotalDoDia(_selectedDate);
        final pend = provider.getPendenteDoDia(_selectedDate);
        return Column(children: [
          SizedBox(height: 80, child: ListView.builder(scrollDirection: Axis.horizontal, itemCount: 30, itemBuilder: (ctx,i){ final d=DateTime.now().add(Duration(days:i-5)); final isSel=DateUtils.isSameDay(d,_selectedDate); return GestureDetector(onTap: ()=>setState(()=>_selectedDate=d), child: Container(width:70, margin: const EdgeInsets.all(6), decoration: BoxDecoration(color: isSel?Colors.deepPurple:Colors.grey[200], borderRadius: BorderRadius.circular(12)), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text(DateFormat('EEE','pt_BR').format(d), style: TextStyle(color: isSel?Colors.white:Colors.black, fontSize:12)), Text('${d.day}', style: TextStyle(color: isSel?Colors.white:Colors.black, fontWeight: FontWeight.bold, fontSize:18)), Text(DateFormat('MMM','pt_BR').format(d), style: TextStyle(color: isSel?Colors.white70:Colors.black54, fontSize:10))])));
          })),
          Padding(padding: const EdgeInsets.symmetric(horizontal:12, vertical:6), child: Row(children: [
            Expanded(child: Text('${DateFormat('EEEE, d de MMMM','pt_BR').format(_selectedDate)}\n${ags.length} clientes - Total: R\$${total.toStringAsFixed(2)}', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w500))),
            Chip(label: Text('Pendente: R\$${pend.toStringAsFixed(2)}'), backgroundColor: Colors.orange[100]),
          ])),
          Expanded(child: ags.isEmpty? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.event_busy, size:64, color: Colors.grey), const SizedBox(height:12), Text('Sem agendamento para ${DateFormat('dd/MM').format(_selectedDate)}'), const SizedBox(height:8), ElevatedButton(onPressed: _showAddDialog, child: const Text('Agendar 07:00'))])) : ListView.builder(itemCount: ags.length, itemBuilder: (ctx,i){ final ag=ags[i]; return AgendamentoCard(agendamento: ag, onWhatsApp: ()=>_openWhatsApp(ag.telefone), onDelete: ()=>provider.deleteAgendamento(ag.id)); })),
        ]);
      }),
      floatingActionButton: FloatingActionButton.extended(onPressed: _showAddDialog, label: const Text('Novo'), icon: const Icon(Icons.add), backgroundColor: Colors.deepPurple, foregroundColor: Colors.white),
    );
  }
}
