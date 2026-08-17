import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/agenda_provider.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class RelatorioScreen extends StatefulWidget {
  const RelatorioScreen({super.key});
  @override State<RelatorioScreen> createState()=>_RelatorioScreenState();
}

class _RelatorioScreenState extends State<RelatorioScreen> {
  DateTime _mes = DateTime.now();

  double _totalMes(provider){
    double t=0;
    for(var a in provider.agendamentos){
      if(a.data.year==_mes.year && a.data.month==_mes.month){
        final m=RegExp(r'R\$\s*(\d+[\.,]?\d*)').firstMatch(a.servico);
        if(m!=null) t+=double.tryParse(m.group(1)!.replaceAll(',','.'))??0;
      }
    }
    return t;
  }

  Future<void> _exportCatalogo(provider) async {
    final dir=await getApplicationDocumentsDirectory();
    final file=File('${dir.path}/catalogo_servicos_${DateFormat('yyyyMM').format(_mes)}.txt');
    final buf=StringBuffer();
    buf.writeln('CATALOGO DE SERVICOS - Agenda Facil MEI');
    buf.writeln('Gerado em ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}');
    buf.writeln('----------------------------------------');
    for(var s in provider.servicos){
      final tempo=provider.getTempoServico(s);
      final valor=provider.getValorServico(s);
      buf.writeln('$s | Tempo: ${tempo}min | Valor: R\$${valor.toStringAsFixed(2)}');
    }
    buf.writeln('----------------------------------------');
    buf.writeln('Total servicos: ${provider.servicos.length}');
    await file.writeAsString(buf.toString());
    await Share.shareXFiles([XFile(file.path)], text: 'Catalogo de Servicos MEI');
  }

  Future<void> _exportRelatorio(provider) async {
    final dir=await getApplicationDocumentsDirectory();
    final file=File('${dir.path}/relatorio_${DateFormat('yyyyMM').format(_mes)}.txt');
    final buf=StringBuffer();
    buf.writeln('RELATORIO MENSAL - ${DateFormat('MMMM yyyy','pt_BR').format(_mes)}');
    buf.writeln('Gerado em ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}');
    buf.writeln('----------------------------------------');
    double total=0, pend=0;
    final agsMes=provider.agendamentos.where((a)=>a.data.year==_mes.year && a.data.month==_mes.month).toList();
    for(var a in agsMes){
      final m=RegExp(r'R\$\s*(\d+[\.,]?\d*)').firstMatch(a.servico);
      double v=0;
      if(m!=null) v=double.tryParse(m.group(1)!.replaceAll(',','.'))??0;
      total+=v;
      if(!a.pago) pend+=v;
      buf.writeln('${DateFormat('dd/MM').format(a.data)} ${a.horario.format(context)} - ${a.nomeCliente} - ${a.servico} - ${a.pago?'Pago':'Pendente'}');
    }
    buf.writeln('----------------------------------------');
    buf.writeln('Clientes: ${agsMes.length}');
    buf.writeln('Total: R\$${total.toStringAsFixed(2)}');
    buf.writeln('Pendente: R\$${pend.toStringAsFixed(2)}');
    buf.writeln('Recebido: R\$${(total-pend).toStringAsFixed(2)}');
    await file.writeAsString(buf.toString());
    await Share.shareXFiles([XFile(file.path)], text: 'Relatorio ${DateFormat('MMMM yyyy','pt_BR').format(_mes)}');
  }

  @override Widget build(BuildContext context){
    return Consumer<AgendaProvider>(builder: (context, provider, _){
      final total=_totalMes(provider);
      final agsMes=provider.agendamentos.where((a)=>a.data.year==_mes.year && a.data.month==_mes.month).toList();
      return Scaffold(appBar: AppBar(title: const Text('Relatorio Mensal'), backgroundColor: Colors.deepPurple, foregroundColor: Colors.white), body: Column(children: [
        Padding(padding: const EdgeInsets.all(12), child: Row(children: [
          IconButton(icon: const Icon(Icons.chevron_left), onPressed: ()=>setState(()=>_mes=DateTime(_mes.year, _mes.month-1))),
          Expanded(child: Center(child: Text(DateFormat('MMMM yyyy','pt_BR').format(_mes), style: const TextStyle(fontSize:20, fontWeight: FontWeight.bold)))),
          IconButton(icon: const Icon(Icons.chevron_right), onPressed: ()=>setState(()=>_mes=DateTime(_mes.year, _mes.month+1))),
        ])),
        Card(margin: const EdgeInsets.all(12), child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
          Text('R\$${total.toStringAsFixed(2)}', style: const TextStyle(fontSize:32, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
          Text('${agsMes.length} agendamentos no mes'),
        ]))),
        const Divider(),
        ListTile(title: const Text('Catalogo de Servicos'), subtitle: Text('${provider.servicos.length} servicos'), trailing: IconButton(icon: const Icon(Icons.share), onPressed: ()=>_exportCatalogo(provider))),
        ListTile(title: const Text('Relatorio do Mes'), subtitle: const Text('Exporta TXT com todos agendamentos'), trailing: IconButton(icon: const Icon(Icons.download), onPressed: ()=>_exportRelatorio(provider))),
        Expanded(child: ListView.builder(itemCount: agsMes.length, itemBuilder: (_,i){ final a=agsMes[i]; return ListTile(title: Text('${DateFormat('dd/MM').format(a.data)} - ${a.nomeCliente}'), subtitle: Text(a.servico), trailing: Text('R\$${provider.getValorServico(a.servico).toStringAsFixed(2)}')); })),
      ]));
    });
  }
}
