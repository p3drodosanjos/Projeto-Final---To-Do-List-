import 'package:flutter/material.dart';

import '../models/task_model.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../widgets/task_title.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Task> _tasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() => _isLoading = true);
    try {
      final userId = AuthService.instance.currentUserId;
      if (userId == null) {
        throw StateError('Faça login para acessar suas tarefas.');
      }
      final tasks = await DatabaseService.instance.getTasksByUser(userId);
      if (mounted) setState(() => _tasks = tasks);
    } catch (error) {
      if (mounted) _showError(error);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _openTaskForm({Task? task}) async {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController(text: task?.title ?? '');
    final descriptionController =
        TextEditingController(text: task?.description ?? '');

    try {
      final shouldSave = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(task == null ? 'Nova tarefa' : 'Editar tarefa'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titleController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Título',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Informe o título da tarefa.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Descrição (opcional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(dialogContext, true);
                }
              },
              child: const Text('Salvar'),
            ),
          ],
        ),
      );

      if (shouldSave != true || !mounted) return;
      final userId = AuthService.instance.currentUserId;
      if (userId == null) {
        throw StateError('Faça login para salvar tarefas.');
      }

      final updatedTask = Task(
        id: task?.id,
        userId: userId,
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        isCompleted: task?.isCompleted ?? false,
      );
      if (task == null) {
        await DatabaseService.instance.createTask(updatedTask);
      } else {
        await DatabaseService.instance.updateTask(updatedTask);
      }
      await _loadTasks();
    } catch (error) {
      if (mounted) _showError(error);
    } finally {
      titleController.dispose();
      descriptionController.dispose();
    }
  }

  Future<void> _toggleTask(Task task, bool? isCompleted) async {
    if (isCompleted == null) return;
    try {
      await DatabaseService.instance.updateTask(
        task.copyWith(isCompleted: isCompleted),
      );
      await _loadTasks();
    } catch (error) {
      if (mounted) _showError(error);
    }
  }

  Future<void> _deleteTask(Task task) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Excluir tarefa?'),
        content: Text('Deseja excluir "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (shouldDelete != true) return;

    try {
      final id = task.id;
      if (id == null) {
        throw StateError('Não foi possível identificar a tarefa.');
      }
      await DatabaseService.instance.deleteTask(id);
      await _loadTasks();
    } catch (error) {
      if (mounted) _showError(error);
    }
  }

  Future<void> _logout() async {
    await AuthService.instance.logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
  }

  void _showError(Object error) {
    final message = error.toString().replaceFirst('Exception: ', '');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas tarefas'),
        actions: [
          IconButton(
            tooltip: 'Sair',
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _tasks.isEmpty
              ? const Center(child: Text('Nenhuma tarefa encontrada.'))
              : ListView.builder(
                  itemCount: _tasks.length,
                  itemBuilder: (context, index) {
                    final task = _tasks[index];
                    return TaskTile(
                      task: task,
                      onToggle: (value) => _toggleTask(task, value),
                      onEdit: () => _openTaskForm(task: task),
                      onDelete: () => _deleteTask(task),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openTaskForm(),
        icon: const Icon(Icons.add),
        label: const Text('Nova tarefa'),
      ),
    );
  }
}
