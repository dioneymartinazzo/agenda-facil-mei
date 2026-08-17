import 'package:flutter/material.dart';
import '../models/agendamento.dart';

class AgendamentoCard extends StatelessWidget {
  final Agendamento agendamento;
  final VoidCallback onWhatsApp;
  final VoidCallback onDelete;
  final VoidCallback onTogglePago;
  const AgendamentoCard({super.key, required this.agendamento, required this.onWhatsApp, required this.onDelete, required this.onTogglePago});

  @override
  Widget build(BuildContext context) {
    final isPago = agendamento.pago;
    return Card(margin: const EdgeInsets.symmetric(horizontal:12, vertical:6), child: ListTile(
      leading: CircleAvatar(backgroundColor: isPago?Colors.green:Colors.deepPurple, child: Text('${agendamento.horario.hour}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
      title: Text('${agendamento.horario.format(context)} - ${agendamento.nomeCliente}', style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text('${agendamento.servico}\n${isPago?'Pago':'Pendente}', style: TextStyle(color: isPago?Colors.green:Colors.orange)),
      isThreeLine: true,
      trailing: PopupMenuButton(itemBuilder: (_)=>[
        PopupMenuItem(child: const Text('WhatsApp'), onTap: onWhatsApp),
        PopupMenuItem(child: Text(isPago?'Marcar Pendente':'Marcar Pago'), onTap: (){ Future.delayed(const Duration(milliseconds:100), onTogglePago); }),
        PopupMenuItem(child: const Text('Deletar'), onTap: (){ Future.delayed(const Duration(milliseconds:100), onDelete); }),
      ], icon: const Icon(Icons.more_vert)),
    ));
  }
}
