// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'viewmodel.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: NotaScreen(),
    );
  }
}

class NotaScreen extends StatefulWidget {
  const NotaScreen({super.key});

  @override
  _NotaScreenState createState() => _NotaScreenState();
}

class _NotaScreenState extends State<NotaScreen> {
  final TrabalhoViewModel _viewModel = TrabalhoViewModel();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _notaProvaController = TextEditingController();
  final List<TextEditingController> _notasTrabalhosControllers = [];
  final TextEditingController _searchController = TextEditingController();

  Map<String, dynamic>? _resultadoBusca;

  // JSON de exemplo
  String jsonData = '''
  [
    {"tipo": "Tarefas", "titulo": "Tarefa - Mapa Mental", "tituloResumido": "Mapa Mental", "peso": 1, "periodo": "G1"},
    {"tipo": "Tarefas", "titulo": "Praticando Git", "tituloResumido": "Praticando Git", "peso": 2, "periodo": "G1"},
    {"tipo": "Tarefas", "titulo": "Cadastro de Potenciais Clientes", "tituloResumido": "Cadastro de Potenciais Clientes", "peso": 3, "periodo": "G1"},
    {"tipo": "Tarefas", "titulo": "Aplicativo para calcular a nota", "tituloResumido": "Aplicativo para calcular a nota", "peso": 4, "periodo": "G1"},
    {"tipo": "Trabalho Final", "titulo": "Sprint 4 - Review - Avaliação G1", "peso": 7, "periodo": "G1"}
  ]
  ''';

  @override
  void initState() {
    super.initState();
    _viewModel.carregarDados(jsonData);
    for (var i = 0; i < 4; i++) {
      _notasTrabalhosControllers.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _notaProvaController.dispose();
    _notasTrabalhosControllers.forEach((controller) => controller.dispose());
    _searchController.dispose();
    super.dispose();
  }

  // Salva os registros de um aluno (nome, notaFinal e timestamp)
  Future<void> _salvarInformacoes(String nome, double notaFinal) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String timestamp = DateTime.now().toString();

    // Obtém todos os registros salvos anteriormente
    String? registrosJson = prefs.getString('registros');
    Map<String, dynamic> registros = registrosJson != null
        ? jsonDecode(registrosJson)
        : {};

    // Adiciona ou atualiza o registro do aluno
    registros[nome] = {
      'nota_final': notaFinal.toString(),
      'timestamp': timestamp
    };

    // Salva todos os registros de volta no SharedPreferences
    await prefs.setString('registros', jsonEncode(registros));
  }

  // Função para buscar um registro pelo nome
  Future<void> _buscarPorNome(String nome) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? registrosJson = prefs.getString('registros');

    if (registrosJson != null) {
      Map<String, dynamic> registros = jsonDecode(registrosJson);

      // Busca o nome fornecido nos registros
      if (registros.containsKey(nome)) {
        setState(() {
          _resultadoBusca = registros[nome];
        });
      } else {
        setState(() {
          _resultadoBusca = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cálculo de Notas'),
      ),
      body: SingleChildScrollView(  // Permite a rolagem sem transbordar
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text('Informe o Nome', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextField(
                controller: _nomeController,
                decoration: const InputDecoration(labelText: 'Nome'),
              ),
              const SizedBox(height: 20),
              const Text('Notas dos Trabalhos',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ..._buildTrabalhosFields(),
              const SizedBox(height: 20),
              TextField(
                controller: _notaProvaController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Nota da Prova (G1)'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _calcularNotas,
                child: const Text('Calcular Nota Final'),
              ),
              const SizedBox(height: 20),
              const Text('Buscar Registro pelo Nome'),
              TextField(
                controller: _searchController,
                decoration: const InputDecoration(labelText: 'Buscar pelo nome'),
              ),
              ElevatedButton(
                onPressed: () => _buscarPorNome(_searchController.text),
                child: const Text('Buscar'),
              ),
              const SizedBox(height: 20),
              _buildResultadoBusca(),
            ],
          ),
        ),
      ),
      resizeToAvoidBottomInset: true,  // Adicionado para evitar problemas ao abrir o teclado
    );
  }

  List<Widget> _buildTrabalhosFields() {
    return List.generate(_notasTrabalhosControllers.length, (index) {
      return TextField(
        controller: _notasTrabalhosControllers[index],
        keyboardType: TextInputType.number,
        decoration: InputDecoration(labelText: 'Nota do Trabalho ${index + 1}'),
      );
    });
  }

  Widget _buildResultadoBusca() {
    if (_resultadoBusca == null) {
      return const Text('Nenhum registro encontrado.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Nota Final: ${_resultadoBusca!['nota_final']}'),
        Text('Timestamp: ${_resultadoBusca!['timestamp']}'),
      ],
    );
  }

  void _calcularNotas() {
    String nome = _nomeController.text;
    if (nome.isEmpty) {
      _mostrarAlerta('Por favor, informe o nome');
      return;
    }

    List<double> notasTrabalhos = _notasTrabalhosControllers
        .map((controller) => double.tryParse(controller.text) ?? 0)
        .toList();
    double notaProva = double.tryParse(_notaProvaController.text) ?? 0;

    double mediaTrabalhos =
        _viewModel.calcularMediaTrabalhos('G1', notasTrabalhos);
    double notaFinal =
        _viewModel.calcularNotaFinal(notaProva, mediaTrabalhos, 'G1');

    _salvarInformacoes(nome, notaFinal);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nota Final'),
          content: Text('Sua nota final é: ${notaFinal.toStringAsFixed(2)}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _mostrarAlerta(String mensagem) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Atenção'),
          content: Text(mensagem),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
