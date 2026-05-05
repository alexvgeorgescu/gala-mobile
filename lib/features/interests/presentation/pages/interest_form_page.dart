import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gala_mobile/core/network/dio_error_message.dart';
import 'package:gala_mobile/features/interests/data/models/interest.dart';
import 'package:gala_mobile/features/interests/presentation/cubit/interests_cubit.dart';

const _typeOptions = <InterestType>[
  InterestType(key: 'object', name: 'Object'),
  InterestType(key: 'experience', name: 'Experience'),
];

class InterestFormPage extends StatefulWidget {
  const InterestFormPage({super.key});

  @override
  State<InterestFormPage> createState() => _InterestFormPageState();
}

class _InterestFormPageState extends State<InterestFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _typeKey = _typeOptions.first.key;
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  InterestType _selectedType() {
    return _typeOptions.firstWhere((t) => t.key == _typeKey);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      await context.read<InterestsCubit>().create(
            name: _nameController.text.trim(),
            description: _descriptionController.text.trim(),
            type: _selectedType(),
          );
      if (!mounted) return;
      context.pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(friendlyDioError(e))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Interest')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.newline,
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _typeKey,
                  decoration: const InputDecoration(
                    labelText: 'Type',
                    border: OutlineInputBorder(),
                  ),
                  items: _typeOptions
                      .map((t) => DropdownMenuItem(
                            value: t.key,
                            child: Text(t.name),
                          ))
                      .toList(),
                  onChanged: _saving
                      ? null
                      : (value) {
                          if (value != null) {
                            setState(() => _typeKey = value);
                          }
                        },
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
