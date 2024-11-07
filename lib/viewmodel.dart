// ignore_for_file: avoid_print

import 'model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';  // Para usar ChangeNotifier

class TrabalhoViewModel extends ChangeNotifier {
  final String apiUrl = 'https://back-tarefas-bfhjb9chgee4g4at.canadacentral-01.azurewebsites.net/tarefas';
  final TrabalhoModel _model = TrabalhoModel();

  // Getter para acessar as tarefas carregadas
  List<Trabalho> get trabalhos => _model.trabalhos;

  // Carregar as tarefas da API
  Future<void> carregarDados() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        _model.trabalhos = jsonList.map((json) => Trabalho.fromJson(json)).toList();
        notifyListeners(); // Notifica a UI sobre a mudança
      } else {
        throw Exception('Falha ao carregar tarefas');
      }
    } catch (e) {
      print('Erro: $e');
    }
  }

  // Adicionar uma nova tarefa
  Future<void> adicionarTarefa(Trabalho novaTarefa) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(novaTarefa.toJson()),
      );
      if (response.statusCode == 201) {
        _model.trabalhos.add(novaTarefa);  // Adiciona a tarefa localmente
        notifyListeners();  // Notifica a UI sobre a mudança
      } else {
        throw Exception('Erro ao adicionar tarefa');
      }
    } catch (e) {
      print('Erro: $e');
    }
  }

  // Atualizar uma tarefa existente
  Future<void> atualizarTarefa(int index, Trabalho tarefaAtualizada) async {
    try {
      final response = await http.put(
        Uri.parse('$apiUrl/$index'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(tarefaAtualizada.toJson()),
      );
      if (response.statusCode == 200) {
        _model.trabalhos[index] = tarefaAtualizada;  // Atualiza a tarefa localmente
        notifyListeners();  // Notifica a UI sobre a mudança
      } else {
        throw Exception('Erro ao atualizar tarefa');
      }
    } catch (e) {
      print('Erro: $e');
    }
  }

  // Remover uma tarefa
  Future<void> removerTarefa(int index) async {
    try {
      final response = await http.delete(Uri.parse('$apiUrl/$index'));
      if (response.statusCode == 200) {
        _model.trabalhos.removeAt(index);  // Remove a tarefa localmente
        notifyListeners();  // Notifica a UI sobre a mudança
      } else {
        throw Exception('Erro ao remover tarefa');
      }
    } catch (e) {
      print('Erro: $e');
    }
  }
}
