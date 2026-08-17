class Servico {
  final String nome;
  final double valor;
  final int duracaoMin;
  Servico({required this.nome, required this.valor, required this.duracaoMin});
  Map<String,dynamic> toJson()=>{'nome':nome,'valor':valor,'duracaoMin':duracaoMin};
  factory Servico.fromJson(Map<String,dynamic> j)=>Servico(nome:j['nome'],valor:(j['valor']??0).toDouble(),duracaoMin:j['duracaoMin']??30);
}