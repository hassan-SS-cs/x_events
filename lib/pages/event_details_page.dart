import 'package:flutter/material.dart';
import 'package:x_events/models/event_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EventDetailsPage extends StatefulWidget {
  final EventModel event;
  final VoidCallback onBack;
  const EventDetailsPage({
    super.key,
    required this.event,
    required this.onBack,
  });
  @override
  State<EventDetailsPage> createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage> {
  int _viewCount = 0;

  @override
  void initState() {
    super.initState();
    _loadViewCount();
  }

  Future<void> _loadViewCount() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt('viewCount_${widget.event.id}') ?? 0;
    final newCount = current + 1;
    await prefs.setInt('viewCount_${widget.event.id}', newCount);
    setState(() => _viewCount = newCount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 70),
            Center(
              child: Text(
                '${widget.event.title}',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
              ),
            ),
            Center(child: Text('views:$_viewCount')),
            SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: widget.event.images.asMap().entries.map((entry) {
                final index = entry.key;
                final imgPath = entry.value;
                return GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => Dialog(
                        child: SizedBox(
                          height: 300,
                          child: PageView.builder(
                            controller: PageController(initialPage: index),
                            itemCount: widget.event.images.length,
                            itemBuilder: (ctx, i) => Image.asset(
                              widget.event.images[i],
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  child: Image.asset(
                    imgPath,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(widget.event.introduction),
            ),
          ],
        ),
      ),
    );
  }
}
