// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';  // Import para usar o Provider
import 'viewmodel.dart';  // Import do TrabalhoViewModel
import 'model.dart';  // Import dos modelos de dados

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => TrabalhoViewModel(), // Criando a instância do TrabalhoViewModel
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lista de Tarefas',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const NotaScreen(), // Tela inicial
    );
  }
}

class NotaScreen extends StatefulWidget {
  const NotaScreen({super.key});

  @override
  _NotaScreenState createState() => _NotaScreenState();
}

class _NotaScreenState extends State<NotaScreen> {
  @override
  void initState() {
    super.initState();
    // Carregar os dados ao inicializar a tela
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Provider.of<TrabalhoViewModel>(context, listen: false).carregarDados();
    });
  }

  // Função para editar a tarefa
  void _editarTarefa(int index) async {
    final tarefa = Provider.of<TrabalhoViewModel>(context, listen: false).trabalhos[index];
    await _exibirDialogoEdicao(
      tipo: tarefa.tipo,
      titulo: tarefa.titulo,
      tituloResumido: tarefa.tituloResumido,
      peso: tarefa.peso.toString(),
      periodo: tarefa.periodo,
      onSave: (novaTarefa) async {
        await Provider.of<TrabalhoViewModel>(context, listen: false)
            .atualizarTarefa(index, novaTarefa); // Atualiza a tarefa no viewModel
      },
    );
  }

  // Função para adicionar uma nova tarefa
  Future<void> _adicionarTarefa() async {
    await _exibirDialogoEdicao(
      tipo: '',
      titulo: '',
      tituloResumido: '',
      peso: '1',
      periodo: '',
      onSave: (novaTarefa) async {
        await Provider.of<TrabalhoViewModel>(context, listen: false)
            .adicionarTarefa(novaTarefa); // Adiciona a nova tarefa no viewModel
      },
    );
  }

  // Função comum para exibir o dialog de edição
  Future<void> _exibirDialogoEdicao({
    required String tipo,
    required String titulo,
    required String tituloResumido,
    required String peso,
    required String periodo,
    required Function(Trabalho) onSave,
  }) async {
    final tipoController = TextEditingController(text: tipo);
    final tituloController = TextEditingController(text: titulo);
    final tituloResumidoController = TextEditingController(text: tituloResumido);
    final pesoController = TextEditingController(text: peso);
    final periodoController = TextEditingController(text: periodo);

    final novaTarefa = await showDialog<Trabalho>(context: context, builder: (context) {
      return AlertDialog(
        title: const Text('Editar Tarefa'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: tipoController, decoration: const InputDecoration(labelText: 'Tipo')),
            TextField(controller: tituloController, decoration: const InputDecoration(labelText: 'Título')),
            TextField(controller: tituloResumidoController, decoration: const InputDecoration(labelText: 'Título Resumido')),
            TextField(controller: pesoController, decoration: const InputDecoration(labelText: 'Peso')),
            TextField(controller: periodoController, decoration: const InputDecoration(labelText: 'Período')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              final tarefaEditada = Trabalho(
                tipo: tipoController.text,
                titulo: tituloController.text,
                tituloResumido: tituloResumidoController.text,
                peso: int.tryParse(pesoController.text) ?? 1,
                periodo: periodoController.text,
              );
              Navigator.pop(context, tarefaEditada);
            },
            child: const Text('Salvar'),
          ),
        ],
      );
    });

    if (novaTarefa != null) {
      await onSave(novaTarefa);  // Salva as alterações
    }
  }

  // Função para deletar a tarefa
  void _deletarTarefa(int index) async {
    await Provider.of<TrabalhoViewModel>(context, listen: false).removerTarefa(index); // Remove a tarefa do viewModel
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Tarefas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _adicionarTarefa, // Botão para adicionar nova tarefa
          ),
        ],
      ),
      body: Consumer<TrabalhoViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.trabalhos.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView.builder(
            itemCount: viewModel.trabalhos.length,
            itemBuilder: (context, index) {
              final tarefa = viewModel.trabalhos[index];
              return ListTile(
                title: Text(tarefa.titulo),
                subtitle: Text('Peso: ${tarefa.peso}, Período: ${tarefa.periodo}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _editarTarefa(index),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _deletarTarefa(index),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
