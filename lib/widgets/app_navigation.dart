import 'package:flutter/material.dart';
import 'package:x_events/models/event_model.dart';
import 'package:x_events/models/ticket_model.dart';
import 'package:x_events/pages/event_details_page.dart';
import 'package:x_events/pages/events_list_page.dart';
import 'package:x_events/pages/records_page.dart';
import 'package:x_events/pages/ticket_create_page.dart';
import 'package:x_events/pages/ticket_details_page.dart';
import 'package:x_events/pages/tickets_list_page.dart';

class AppNavigation extends StatefulWidget {
  const AppNavigation({super.key});

  @override
  State<AppNavigation> createState() => _AppNavigationState();
}

class _AppNavigationState extends State<AppNavigation> {
  int _selectedIndex = 0;
  EventModel? _selectedEvent;
  bool _showTicketCreate = false;
  TicketModel? _selectedTicket;
  List<TicketModel> _tickets = [];

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
          setState(() {
            _tickets.add(ticket);
            _showTicketCreate = false;
          });
        },
      );
    } else if (_selectedIndex == 1) {
      currentPage = TicketsListPage(
        tickets: _tickets,
        onTicketsChanged: (updated) => setState(() => _tickets = updated),
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
