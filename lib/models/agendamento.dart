import 'package:flutter/material.dart';

class Agendamento {
  final String id;
  final String nomeCliente;
  final String telefone;
  final DateTime data;
  final TimeOfDay horario;
  final String servico;
  final double valor;
  final bool pago;

  Agendamento({required this.id, required this.nomeCliente, required this.telefone, required this.data, required this.horario, required this.servico, required this.valor, required this.pago});

  Agendamento copyWith({bool? pago, double? valor}) {
    return Agendamento(id:id,nomeCliente:nomeCliente,telefone:telefone,data:data,horario:horario,servico:servico,valor:valor??this.valor,pago:pago??this.pago);
  }

  Map<String,dynamic> toJson()=>{'id':id,'nomeCliente':nomeCliente,'telefone':telefone,'data':data.toIso8601String(),'hora':horario.hour,'min':horario.minute,'servico':servico,'valor':valor,'pago':pago};

  factory Agendamento.fromJson(Map<String,dynamic> j){
    return Agendamento(id:j['id'],nomeCliente:j['nomeCliente'],telefone:j['telefone']??'',data:DateTime.parse(j['data']),horario:TimeOfDay(hour:j['hora']??9,minute:j['min']??0),servico:j['servico']??'',valor:(j['valor']??0).toDouble(),pago:j['pago']??false);
  }
}