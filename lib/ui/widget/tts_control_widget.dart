import 'package:flutter/material.dart';
import 'package:readbox/res/enum.dart';
import 'package:readbox/ui/widget/widget.dart';
import 'package:readbox/utils/text_to_speech_service.dart';

/// Widget điều khiển Text-to-Speech cho ebook reading
class TTSControlWidget extends StatefulWidget {
  final String? textToRead;
  final VoidCallback? onStart;
  final VoidCallback? onStop;

  const TTSControlWidget({
    Key? key,
    this.textToRead,
    this.onStart,
    this.onStop,
  }) : super(key: key);

  @override
  State<TTSControlWidget> createState() => _TTSControlWidgetState();
}

class _TTSControlWidgetState extends State<TTSControlWidget> {
  final TextToSpeechService _ttsService = TextToSpeechService();
  bool _isInitialized = false;
  bool _isSpeaking = false;
  double _speechRate = 0.5;
  double _volume = 1.0;
  double _pitch = 1.0;

  @override
  void initState() {
    super.initState();
    _initializeTTS();
    _setupCallbacks();
  }

  Future<void> _initializeTTS() async {
    await _ttsService.initialize();
    setState(() {
      _isInitialized = _ttsService.isInitialized;
      _speechRate = _ttsService.speechRate;
      _volume = _ttsService.volume;
      _pitch = _ttsService.pitch;
    });
  }

  void _setupCallbacks() {
    _ttsService.onSpeechStart = (_) {
      setState(() {
        _isSpeaking = true;
      });
      widget.onStart?.call();
    };

    _ttsService.onSpeechComplete = (_) {
      setState(() {
        _isSpeaking = false;
      });
      widget.onStop?.call();
    };

    _ttsService.onSpeechError = (error) {
      setState(() {
        _isSpeaking = false;
      });
      AppSnackBar.show(
        context,
        message: 'Lỗi đọc: $error',
        snackBarType: SnackBarType.error,
      );
    };
  }

  Future<void> _toggleSpeech() async {
    if (!_isInitialized) {
      await _initializeTTS();
    }

    if (_isSpeaking) {
      await _ttsService.stop();
    } else {
      if (widget.textToRead != null && widget.textToRead!.isNotEmpty) {
        await _ttsService.setLanguageFromText(widget.textToRead!);
        await _ttsService.speak(widget.textToRead!);
      }
    }
  }

  Future<void> _updateSpeechRate(double rate) async {
    await _ttsService.setSpeechRate(rate);
    setState(() {
      _speechRate = rate;
    });
  }

  Future<void> _updateVolume(double vol) async {
    await _ttsService.setVolume(vol);
    setState(() {
      _volume = vol;
    });
  }

  Future<void> _updatePitch(double p) async {
    await _ttsService.setPitch(p);
    setState(() {
      _pitch = p;
    });
  }

  @override
  void dispose() {
    _ttsService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Control buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Play/Pause button
              IconButton(
                icon: Icon(_isSpeaking ? Icons.stop : Icons.play_arrow),
                iconSize: 32,
                color: _isSpeaking ? Colors.red : Colors.green,
                onPressed: _toggleSpeech,
              ),

              // Speed control
              Column(
                children: [
                  const Text('Tốc độ', style: TextStyle(fontSize: 12)),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: _speechRate > 0.0
                            ? () => _updateSpeechRate(_speechRate - 0.1)
                            : null,
                      ),
                      Text(
                        '${(_speechRate * 2).toStringAsFixed(1)}x',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: _speechRate < 1.0
                            ? () => _updateSpeechRate(_speechRate + 0.1)
                            : null,
                      ),
                    ],
                  ),
                ],
              ),

              // Volume control
              Column(
                children: [
                  const Text('Âm lượng', style: TextStyle(fontSize: 12)),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.volume_down),
                        onPressed: _volume > 0.0
                            ? () => _updateVolume(_volume - 0.1)
                            : null,
                      ),
                      Text(
                        '${(_volume * 100).toInt()}%',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.volume_up),
                        onPressed: _volume < 1.0
                            ? () => _updateVolume(_volume + 0.1)
                            : null,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          // Sliders for fine control
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.speed, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Slider(
                        value: _speechRate,
                        min: 0.0,
                        max: 1.0,
                        divisions: 10,
                        label: 'Tốc độ: ${(_speechRate * 2).toStringAsFixed(1)}x',
                        onChanged: _updateSpeechRate,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.volume_up, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Slider(
                        value: _volume,
                        min: 0.0,
                        max: 1.0,
                        divisions: 10,
                        label: 'Âm lượng: ${(_volume * 100).toInt()}%',
                        onChanged: _updateVolume,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Floating TTS button - compact version
class FloatingTTSButton extends StatefulWidget {
  final String? textToRead;

  const FloatingTTSButton({
    Key? key,
    this.textToRead,
  }) : super(key: key);

  @override
  State<FloatingTTSButton> createState() => _FloatingTTSButtonState();
}

class _FloatingTTSButtonState extends State<FloatingTTSButton> {
  final TextToSpeechService _ttsService = TextToSpeechService();
  bool _isSpeaking = false;
  bool _showControls = false;

  @override
  void initState() {
    super.initState();
    _initializeTTS();
  }

  Future<void> _initializeTTS() async {
    await _ttsService.initialize();
    _ttsService.onSpeechStart = (_) {
      setState(() => _isSpeaking = true);
    };
    _ttsService.onSpeechComplete = (_) {
      setState(() => _isSpeaking = false);
    };
  }

  Future<void> _toggleSpeech() async {
    if (_isSpeaking) {
      await _ttsService.stop();
    } else {
      if (widget.textToRead != null && widget.textToRead!.isNotEmpty) {
        await _ttsService.setLanguageFromText(widget.textToRead!);
        await _ttsService.speak(widget.textToRead!);
      }
    }
  }

  @override
  void dispose() {
    _ttsService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: _toggleSpeech,
      backgroundColor: _isSpeaking ? Colors.red : Colors.blue,
      child: Icon(
        _isSpeaking ? Icons.stop : Icons.volume_up,
        color: Colors.white,
      ),
      tooltip: _isSpeaking ? 'Dừng đọc' : 'Đọc text',
    );
  }
}

