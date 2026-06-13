import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:x_events/models/event_model.dart';

class EventsListPage extends StatefulWidget {
  final Function(EventModel) onEventSelected;
  const EventsListPage({super.key, required this.onEventSelected});

  @override
  State<EventsListPage> createState() => _EventsListPageState();
}

class _EventsListPageState extends State<EventsListPage> {
  List<EventModel> _events = [];
  Set<String> _readIds = {};
  String _filter = 'All';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final jsonStr = await rootBundle.loadString('assets/data/events_data.json');
    final List data = json.decode(jsonStr);
    final prefs = await SharedPreferences.getInstance();
    final readList = prefs.getStringList('read_events') ?? [];
    setState(() {
      _events = data.map((e) => EventModel.fromJson(e)).toList();
      _readIds = readList.toSet();
      for (var event in _events) {
        event.isRead = _readIds.contains(event.id);
      }
    });
  }

  Future<void> _markAsRead(EventModel event) async {
    if (event.isRead) return;
    final prefs = await SharedPreferences.getInstance();
    _readIds.add(event.id);
    await prefs.setStringList('read_events', _readIds.toList());
    setState(() => event.isRead = true);
  }

  List<EventModel> get _filteredEvents {
    if (_filter == 'Read') return _events.where((e) => e.isRead).toList();
    if (_filter == 'Unread') return _events.where((e) => !e.isRead).toList();
    return _events;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Events')),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: ['All', 'Unread', 'Read'].map((f) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: ChoiceChip(
                  label: Text(f),
                  selected: _filter == f,
                  showCheckmark: false,
                  onSelected: (_) => setState(() => _filter = f),
                ),
              );
            }).toList(),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredEvents.length,
              itemBuilder: (ctx, i) {
                final event = _filteredEvents[i];
                return ListTile(
                  leading: Image.asset(
                    event.images[0],
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.image, size: 60),
                  ),
                  title: Text(event.title),
                  subtitle: Text(
                    event.introduction,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text(
                    event.isRead ? 'Read' : 'Unread',
                    style: TextStyle(
                      color: event.isRead ? Colors.green : Colors.red,
                    ),
                  ),
                  onTap: () async {
                    await _markAsRead(event);
                    widget.onEventSelected(event);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
