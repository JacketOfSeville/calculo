// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'viewmodel.dart';
import 'dart:convert'; // Para simular a leitura do JSON

void main() {
  runApp(MyApp());
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
  final TextEditingController _notaProvaController = TextEditingController();
  final List<TextEditingController> _notasTrabalhosControllers = [];

  // JSON
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
    // Criar controllers para as notas
    for (var i = 0; i < 4; i++) {
      _notasTrabalhosControllers.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    _notaProvaController.dispose();
    _notasTrabalhosControllers.forEach((controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cálculo de Notas'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Notas dos Trabalhos',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ..._buildTrabalhosFields(),
            const SizedBox(height: 20),
            TextField(
              controller: _notaProvaController,
              keyboardType: TextInputType.number,
              decoration:
                  const InputDecoration(labelText: 'Nota da Prova (G1)'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _calcularNotas,
              child: const Text('Calcular Nota Final'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
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

  void _calcularNotas() {
    List<double> notasTrabalhos = _notasTrabalhosControllers
        .map((controller) => double.tryParse(controller.text) ?? 0)
        .toList();
    double notaProva = double.tryParse(_notaProvaController.text) ?? 0;

    double mediaTrabalhos =
        _viewModel.calcularMediaTrabalhos('G1', notasTrabalhos);
    double notaFinal =
        _viewModel.calcularNotaFinal(notaProva, mediaTrabalhos, 'G1');

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
}
