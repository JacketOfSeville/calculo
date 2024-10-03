import 'dart:convert';

class Trabalho {
  String tipo;
  String titulo;
  String tituloResumido;
  int peso;
  String periodo;

  Trabalho(
      {required this.tipo,
      required this.titulo,
      required this.tituloResumido,
      required this.peso,
      required this.periodo});

  factory Trabalho.fromJson(Map<String, dynamic> json) {
    return Trabalho(
      tipo: json['tipo'],
      titulo: json['titulo'],
      tituloResumido: json['tituloResumido'] ?? "",
      peso: json['peso'],
      periodo: json['periodo'],
    );
  }
}

class TrabalhoModel {
  List<Trabalho> trabalhos = [];

  TrabalhoModel();

  // Carregar dados do arquivo JSON
  void carregarTrabalhos(String jsonData) {
    List<dynamic> jsonList = jsonDecode(jsonData);
    trabalhos = jsonList.map((json) => Trabalho.fromJson(json)).toList();
  }

  // Retorna os trabalhos para G1
  List<Trabalho> getTrabalhosPorPeriodo(String periodo) {
    return trabalhos
        .where((t) => t.periodo == periodo && t.tipo == 'Tarefas')
        .toList();
  }

  Trabalho getTrabalhoFinal(String periodo) {
    return trabalhos
        .firstWhere((t) => t.periodo == periodo && t.tipo == 'Trabalho Final');
  }
}
