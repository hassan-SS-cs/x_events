import 'package:flutter/material.dart';
import 'package:x_events/models/event_model.dart';
import 'package:x_events/pages/event_details_page.dart';
import 'package:x_events/pages/events_list_page.dart';
import 'package:x_events/pages/records_page.dart';
import 'package:x_events/pages/tickets_list_page.dart';

class AppNavigation extends StatefulWidget {
  const AppNavigation({super.key});

  @override
  State<AppNavigation> createState() => _AppNavigationState();
}

class _AppNavigationState extends State<AppNavigation> {
  int _selectedIndex = 0;
  EventModel? _selectedEvent;

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
    } else if (_selectedIndex == 1) {
      currentPage = const TicketsListPage();
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
