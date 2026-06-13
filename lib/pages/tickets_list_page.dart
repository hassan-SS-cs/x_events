import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:x_events/models/ticket_model.dart';

class TicketsListPage extends StatefulWidget {
  final List<TicketModel> tickets;
  final Function(List<TicketModel>) onTicketsChanged;
  final VoidCallback onCreateTapped;
  final Function(TicketModel) onTicketSelected;

  const TicketsListPage({
    super.key,
    required this.tickets,
    required this.onTicketsChanged,
    required this.onCreateTapped,
    required this.onTicketSelected,
  });

  @override
  State<TicketsListPage> createState() => _TicketsListPageState();
}

class _TicketsListPageState extends State<TicketsListPage> {
  List<TicketModel> get _tickets => widget.tickets;

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  Future<void> _loadTickets() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('tickets');
    if (data != null) {
      final List decoded = jsonDecode(data);
      widget.onTicketsChanged(
        decoded.map((e) => TicketModel.fromJson(e)).toList(),
      );
    }
  }

  Future<void> _saveTickets(List<TicketModel> tickets) async {
    final prefs = await SharedPreferences.getInstance();
    final data = tickets
        .map(
          (t) => {
            'id': t.id,
            'name': t.name,
            'type': t.type,
            'imagePath': t.imagePath,
            'createdAt': t.createdAt.toIso8601String(),
            'seat': t.seat,
          },
        )
        .toList();
    await prefs.setString('tickets', jsonEncode(data));
  }

  void _deleteTicket(TicketModel ticket) {
    final updated = List<TicketModel>.from(_tickets)..remove(ticket);
    widget.onTicketsChanged(updated);
    _saveTickets(updated);
  }

  List<TicketModel> _getByType(String type) =>
      _tickets.where((t) => t.type == type).toList();

  void _onReorder(String type, int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex--;
    final typeList = _getByType(type);
    final item = typeList.removeAt(oldIndex);
    typeList.insert(newIndex, item);
    final otherType = type == 'Opening Ceremony'
        ? 'Closing Ceremony'
        : 'Opening Ceremony';
    final updated = [...typeList, ..._getByType(otherType)];
    widget.onTicketsChanged(updated);
    _saveTickets(updated);
  }

  Widget _buildTicketItem(TicketModel ticket) {
    return Dismissible(
      key: Key(ticket.id),
      direction: DismissDirection.horizontal,
      onDismissed: (_) => _deleteTicket(ticket),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      secondaryBackground: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: ListTile(
        title: Text(ticket.name),
        subtitle: Text(ticket.seat),
        onTap: () => widget.onTicketSelected(ticket),
      ),
    );
  }

  Widget _buildSection(String type) {
    final typeList = _getByType(type);
    if (typeList.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            '$type Tickets',
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ),
        ReorderableListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          onReorder: (o, n) => _onReorder(type, o, n),
          children: typeList.map((t) => _buildTicketItem(t)).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tickets List')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: widget.onCreateTapped,
                child: const Text('Create a new ticket'),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildSection('Opening Ceremony'),
                  _buildSection('Closing Ceremony'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
