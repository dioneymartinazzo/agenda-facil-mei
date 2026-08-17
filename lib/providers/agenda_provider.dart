import 'package:flutter/material.dart';
import '../models/agendamento.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AgendaProvider extends ChangeNotifier {
  List<Agendamento> _agendamentos = [];
  List<String> _servicos = [
    'Corte - 30min (editavel) - R\$50.00 - Pago',
    'Barba - 20min (editavel) - R\$30.00',
    'Corte + Barba - 80min (editavel) - R\$120.00'
  ];

  List<Agendamento> get agendamentos => _agendamentos;
  List<String> get servicos => _servicos;

  AgendaProvider() { _load(); }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final agStr = prefs.getString('agendamentos_final');
    if (agStr != null) {
      final List decoded = jsonDecode(agStr);
      _agendamentos = decoded.map((e)=>Agendamento.fromJson(e)).toList();
    }
    final serv = prefs.getStringList('servicos_final');
    if (serv != null && serv.isNotEmpty) _servicos = serv;
    notifyListeners();
  }

  Future<void> _saveAg() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('agendamentos_final', jsonEncode(_agendamentos.map((e)=>e.toJson()).toList()));
  }

  Future<void> _saveServ() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('servicos_final', _servicos);
  }

  void addAgendamento(Agendamento a) {
    _agendamentos.add(a);
    _saveAg();
    notifyListeners();
  }

  void togglePago(String id) {
    final idx = _agendamentos.indexWhere((e)=>e.id==id);
    if (idx!=-1) {
      _agendamentos[idx].pago = !_agendamentos[idx].pago;
      _saveAg();
      notifyListeners();
    }
  }

  void deleteAgendamento(String id) {
    _agendamentos.removeWhere((e)=>e.id==id);
    _saveAg();
    notifyListeners();
  }

  Future<void> addServico(String s) async {
    final t = s.trim();
    if (t.isEmpty) return;
    if (!_servicos.contains(t)) {
      _servicos.add(t);
      await _saveServ();
      notifyListeners();
    }
  }

  List<Agendamento> getAgendamentosPorData(DateTime date) {
    return _agendamentos.where((a)=> a.data.year==date.year && a.data.month==date.month && a.data.day==date.day).toList();
  }

  double getTotalDoDia(DateTime date) {
    double total = 0;
    for (var a in getAgendamentosPorData(date)) {
      final m = RegExp(r'R\$\s*(\d+[\.,]?\d*)').firstMatch(a.servico);
      if (m!=null) {
        var v = m.group(1)!.replaceAll(',', '.');
        total += double.tryParse(v) ?? 0;
      }
    }
    return total;
  }

  double getPendenteDoDia(DateTime date) {
    double total = 0;
    for (var a in getAgendamentosPorData(date).where((e)=>!e.pago)) {
      final m = RegExp(r'R\$\s*(\d+[\.,]?\d*)').firstMatch(a.servico);
      if (m!=null) {
        var v = m.group(1)!.replaceAll(',', '.');
        total += double.tryParse(v) ?? 0;
      }
    }
    return total;
  }
}
