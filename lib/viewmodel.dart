import 'model.dart';

class TrabalhoViewModel {
  TrabalhoModel _model = TrabalhoModel();

  void carregarDados(String jsonData) {
    _model.carregarTrabalhos(jsonData);
  }

  // Calcula a média ponderada dos trabalhos
  double calcularMediaTrabalhos(String periodo, List<double> notas) {
    List<Trabalho> trabalhos = _model.getTrabalhosPorPeriodo(periodo);
    double somaPesos =
        trabalhos.fold(0, (sum, trabalho) => sum + trabalho.peso);
    double somaNotas = 0;

    for (int i = 0; i < trabalhos.length; i++) {
      somaNotas += (notas[i] / 10) * 3 * trabalhos[i].peso;
    }

    return somaNotas / somaPesos;
  }

  // Calcula a nota final
  double calcularNotaFinal(
      double notaProva, double mediaTrabalhos, String periodo) {
    Trabalho trabalhoFinal = _model.getTrabalhoFinal(periodo);
    return mediaTrabalhos + ((notaProva / 10) * trabalhoFinal.peso);
  }
}
