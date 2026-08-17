import 'package:flutter/material.dart';

class Agendamento {
  String id;
  String nomeCliente;
  String telefone;
  String servico;
  DateTime data;
  TimeOfDay horario;
  DateTime createdAt;
  bool pago;

  Agendamento({required this.id, required this.nomeCliente, required this.telefone, required this.servico, required this.data, required this.horario, required this.createdAt, this.pago=false});

  Map<String,dynamic> toJson() => {
    'id': id,
    'nomeCliente': nomeCliente,
    'telefone': telefone,
    'servico': servico,
    'data': data.toIso8601String(),
    'hora': horario.hour,
    'min': horario.minute,
    'createdAt': createdAt.toIso8601String(),
    'pago': pago,
  };

  static Agendamento fromJson(Map<String,dynamic> j) => Agendamento(
    id: j['id'],
    nomeCliente: j['nomeCliente'],
    telefone: j['telefone'],
    servico: j['servico'],
    data: DateTime.parse(j['data']),
    horario: TimeOfDay(hour: j['hora'], minute: j['min']),
    createdAt: DateTime.parse(j['createdAt']),
    pago: j['pago'] ?? false,
  );
}
