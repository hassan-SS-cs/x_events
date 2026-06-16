import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:x_events/models/event_model.dart';
import 'package:x_events/models/ticket_model.dart';
import 'package:x_events/pages/event_details_page.dart';
import 'package:x_events/pages/events_list_page.dart';
import 'package:x_events/pages/records_page.dart';
import 'package:x_events/pages/ticket_create_page.dart';
import 'package:x_events/pages/ticket_details_page.dart';
import 'package:x_events/pages/tickets_list_page.dart';

class AppNavigation extends StatefulWidget {
  final int initialIndex;
  const AppNavigation({super.key, this.initialIndex = 0});

  @override
  State<AppNavigation> createState() => _AppNavigationState();
}

class _AppNavigationState extends State<AppNavigation> {
  late int _selectedIndex;
  EventModel? _selectedEvent;
  bool _showTicketCreate = false;
  TicketModel? _selectedTicket;
  List<TicketModel> _tickets = [];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _loadTickets();
  }

  Future<void> _loadTickets() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('tickets');
    if (data != null) {
      final List decoded = jsonDecode(data);
      setState(() {
        _tickets = decoded.map((e) => TicketModel.fromJson(e)).toList();
      });
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

  @override
  Widget build(BuildContext context) {
    Widget currentPage;

    if (_selectedIndex == 0 && _selectedEvent != null) {
      currentPage = EventDetailsPage(
        event: _selectedEvent!,
        onBack: () => setState(() => _selectedEvent = null),
      );
    } else if (_selectedIndex == 0) {
      currentPage = EventsListPage(
        onEventSelected: (event) {
          setState(() => _selectedEvent = event);
        },
      );
    } else if (_selectedIndex == 1 && _selectedTicket != null) {
      currentPage = TicketDetailsPage(
        ticket: _selectedTicket!,
        onBack: () => setState(() => _selectedTicket = null),
      );
    } else if (_selectedIndex == 1 && _showTicketCreate) {
      currentPage = TicketCreatePage(
        onBack: () => setState(() => _showTicketCreate = false),
        onCreated: (ticket) {
          final updated = [..._tickets, ticket];
          setState(() {
            _tickets = updated;
            _showTicketCreate = false;
          });
          _saveTickets(updated);   
        },
      );
    } else if (_selectedIndex == 1) {
      currentPage = TicketsListPage(
        tickets: _tickets,
        onTicketsChanged: (updated) {
          setState(() => _tickets = updated);
          _saveTickets(updated); 
        },
        onCreateTapped: () => setState(() => _showTicketCreate = true),
        onTicketSelected: (ticket) => setState(() => _selectedTicket = ticket),
      );
    } else {
      currentPage = const RecordsPage();
    }

    return Scaffold(
      body: currentPage,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
            _selectedEvent = null;
            _showTicketCreate = false;
            _selectedTicket = null;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Events'),
          BottomNavigationBarItem(
            icon: Icon(Icons.confirmation_number),
            label: 'Tickets',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.mic), label: 'Records'),
        ],
      ),
    );
  }
}
