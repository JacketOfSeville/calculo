import 'model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TrabalhoViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TrabalhoModel _model = TrabalhoModel();

  // Getter para acessar as tarefas carregadas
  List<Trabalho> get trabalhos => _model.trabalhos;

  // Carregar tarefas do Firestore
  Future<void> carregarDados() async {
    try {
      final querySnapshot = await _firestore.collection('tarefas').get();
      _model.trabalhos = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return Trabalho.fromJson(data)..id = doc.id;
      }).toList();
      notifyListeners(); // Notifica a UI
    } catch (e) {
      print('Erro ao carregar dados: $e');
    }
  }

  // Adicionar uma nova tarefa
  Future<void> adicionarTarefa(Trabalho novaTarefa) async {
    try {
      final docRef = await _firestore.collection('tarefas').add(novaTarefa.toJson());
      novaTarefa.id = docRef.id; // Atualiza o ID localmente
      _model.trabalhos.add(novaTarefa); 
      notifyListeners(); 
    } catch (e) {
      print('Erro ao adicionar tarefa: $e');
    }
  }

  // Atualizar uma tarefa existente
  Future<void> atualizarTarefa(int index, Trabalho tarefaAtualizada) async {
    try {
      final tarefa = _model.trabalhos[index];
      await _firestore.collection('tarefas').doc(tarefa.id).update(tarefaAtualizada.toJson());
      _model.trabalhos[index] = tarefaAtualizada; 
      notifyListeners();
    } catch (e) {
      print('Erro ao atualizar tarefa: $e');
    }
  }

  // Remover uma tarefa
  Future<void> removerTarefa(int index) async {
    try {
      final tarefa = _model.trabalhos[index];
      await _firestore.collection('tarefas').doc(tarefa.id).delete();
      _model.trabalhos.removeAt(index); 
      notifyListeners();
    } catch (e) {
      print('Erro ao remover tarefa: $e');
    }
  }
}
