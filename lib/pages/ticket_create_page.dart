import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:x_events/models/ticket_model.dart';

class TicketCreatePage extends StatefulWidget {
  final VoidCallback onBack;
  final Function(TicketModel) onCreated;

  const TicketCreatePage({
    super.key,
    required this.onBack,
    required this.onCreated,
  });

  @override
  State<TicketCreatePage> createState() => _TicketCreatePageState();
}

class _TicketCreatePageState extends State<TicketCreatePage> {
  String _selectedType = 'Opening Ceremony';
  final _nameController = TextEditingController();
  String? _imagePath;
  final List<String> _types = ['Opening Ceremony', 'Closing Ceremony'];

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _imagePath = picked.path);
  }

  String _generateSeat() {
    const chars = ['A', 'B', 'C'];
    final r = DateTime.now().millisecondsSinceEpoch;
    final char = chars[r % 3];
    final row = (r % 10) + 1;
    final col = (r ~/ 10 % 10) + 1;
    return '$char$row Row$row Column$col';
  }

  void _createTicket() {
    if (_nameController.text.trim().isEmpty || _imagePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields and choose a picture'),
        ),
      );
      return;
    }

    final ticket = TicketModel(
      id: const Uuid().v4(),
      name: _nameController.text.trim(),
      type: _selectedType,
      imagePath: _imagePath!,
      createdAt: DateTime.now(),
      seat: _generateSeat(),
    );

    widget.onCreated(ticket);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ticket Create'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: _types
                  .map(
                    (type) => DropdownMenuItem(value: type, child: Text(type)),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _selectedType = value);
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: 'Input your name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text('Choose one picture'),
            ),
            const SizedBox(height: 12),
            Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: _imagePath != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(_imagePath!),
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    )
                  : const Center(
                      child: Text(
                        'Preview picture',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _createTicket,
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }
}
