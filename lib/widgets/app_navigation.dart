import 'package:flutter/material.dart';
import 'package:x_events/pages/events_list_page.dart';
import 'package:x_events/pages/records_page.dart';
import 'package:x_events/pages/tickets_list_page.dart';


class AppNavigation  extends StatefulWidget {
  const AppNavigation ({super.key});


  @override
  State<AppNavigation > createState() => _MainPageState();
}


class _MainPageState extends State<AppNavigation > {
  int _selectedIndex = 0;


  final List<Widget> _screens = const [
    EventsListPage(),
    TicketsListPage(),
    RecordsPage(),
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.confirmation_number),
            label: 'Tickets',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.mic),
            label: 'Records',
          ),
        ],
      ),
    );
  }
}