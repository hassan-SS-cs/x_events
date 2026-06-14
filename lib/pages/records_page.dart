import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class RecordsPage extends StatefulWidget {
  const RecordsPage({super.key});

  @override
  State<RecordsPage> createState() => _RecordsPageState();
}

class _RecordsPageState extends State<RecordsPage> {
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();

  bool _isRecording = false;
  bool _hasRecording = false;
  String? _currentRecordPath;
  final List<String> _audioList = [];
  int _audioCount = 0;

  Future<void> _startRecording() async {
    final status = await Permission.microphone.request();
    if (!status.isGranted) return;

    final dir = await getApplicationDocumentsDirectory();
    _audioCount++;
    final path = '${dir.path}/audio_$_audioCount.m4a';

    await _recorder.start(const RecordConfig(), path: path);
    setState(() {
      _isRecording = true;
      _hasRecording = false;
      _currentRecordPath = path;
    });
  }

  Future<void> _stopRecording() async {
    await _recorder.stop();
    setState(() {
      _isRecording = false;
      _hasRecording = true;
    });
  }

  Future<void> _playRecording() async {
    if (_currentRecordPath == null) return;
    await _player.play(DeviceFileSource(_currentRecordPath!));
  }

  Future<void> _submitRecording() async {
    if (_currentRecordPath == null) return;

    setState(() {
      _audioList.add(_currentRecordPath!);
      _hasRecording = false;
      _currentRecordPath = null;
    });

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        content: const Text('Submit Successfully'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _playAudio(String path) async {
    await _player.stop();
    await _player.play(DeviceFileSource(path));
  }

  @override
  void dispose() {
    _recorder.dispose();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Records')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: _isRecording ? _stopRecording : _startRecording,
              child: Text(_isRecording ? 'Stop Recording' : 'Voice Record'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _hasRecording ? _playRecording : null,
              child: const Text('Voice Play'),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: _hasRecording ? _submitRecording : null,
                child: const Text('Submit'),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Audios List',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: _audioList.length,
                itemBuilder: (ctx, i) {
                  final name = 'audio ${i + 1}';
                  return ListTile(
                    title: Text(name),
                    trailing: IconButton(
                      icon: const Icon(Icons.play_arrow),
                      onPressed: () => _playAudio(_audioList[i]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}