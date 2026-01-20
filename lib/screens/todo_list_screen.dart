import 'package:flutter/material.dart';
import 'package:todo_list/services/todo_service.dart';
import '../models/todo_model.dart';

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  final dbService = DatabaseService.instance;
  List<TodoItem> todos = [];

  final _formKey = GlobalKey<FormState>();
  final todoTitleController = TextEditingController();
  final todoDescriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  @override
  void dispose() {
    todoTitleController.dispose();
    todoDescriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadTodos() async {
    final items = await dbService.retrieveTodoItems();
    setState(() {
      todos = items;
    });
  }

  Future<void> _addTodo() async {
    await dbService.insertTodoItem(
      TodoItem(
        title: todoTitleController.text,
        description: todoDescriptionController.text,
        isDone: false,
      ),
    );
    _loadTodos();
  }

  Future<void> _updateTodo(TodoItem item) async {
    await dbService.updateTodoItem(
      TodoItem(
        id: item.id,
        title: todoTitleController.text,
        description: todoDescriptionController.text,
        isDone: item.isDone,
      ),
    );
    _loadTodos();
  }

  Future<void> _toggleTodo(TodoItem item) async {
    await dbService.updateTodoItem(
      TodoItem(
        id: item.id,
        title: item.title,
        description: item.description,
        isDone: !item.isDone,
      ),
    );
    _loadTodos();
  }

  void _showAddDialog() {
    todoTitleController.clear();
    todoDescriptionController.clear();

    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Add Todo'),
        content: _buildTodoForm(),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _addTodo();
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(TodoItem item) {
    todoTitleController.text = item.title;
    todoDescriptionController.text = item.description;

    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Edit Todo'),
        content: _buildTodoForm(),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _updateTodo(item);
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildTodoForm() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: todoTitleController,
            decoration: const InputDecoration(hintText: 'Title'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a title';
              }
              return null;
            },
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: todoDescriptionController,
            decoration: const InputDecoration(hintText: 'Description'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a description';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Todos')),
      body: ListView.builder(
        itemCount: todos.length,
        itemBuilder: (context, index) {
          final todo = todos[index];
          return ListTile(
            title: Text(todo.title),
            subtitle: Text(todo.description),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showEditDialog(todo),
                ),
                Checkbox(
                  value: todo.isDone,
                  onChanged: (_) => _toggleTodo(todo),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}