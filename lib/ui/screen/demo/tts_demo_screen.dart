import 'package:flutter/material.dart';
import 'package:readbox/ui/widget/tts_control_widget.dart';
import 'package:readbox/utils/text_to_speech_service.dart';

/// Demo screen để kiểm tra tính năng Text-to-Speech
class TTSDemoScreen extends StatefulWidget {
  const TTSDemoScreen({Key? key}) : super(key: key);

  @override
  State<TTSDemoScreen> createState() => _TTSDemoScreenState();
}

class _TTSDemoScreenState extends State<TTSDemoScreen> {
  final TextToSpeechService _ttsService = TextToSpeechService();
  bool _isTTSActive = false;
  bool _showTTSControls = false;
  int _selectedTextIndex = 0;

  // Text mẫu để test
  final List<Map<String, String>> _sampleTexts = [
    {
      'title': 'Giới thiệu về Flutter',
      'content': 'Flutter là một framework mã nguồn mở của Google để phát triển ứng dụng di động đa nền tảng. '
          'Với Flutter, bạn có thể tạo ra các ứng dụng đẹp mắt, nhanh chóng và dễ dàng chạy trên cả iOS và Android. '
          'Flutter sử dụng ngôn ngữ Dart và cung cấp một bộ widget phong phú để xây dựng giao diện người dùng.',
    },
    {
      'title': 'Truyện ngắn',
      'content': 'Ngày xưa, có một cô bé áo đỏ sống cùng mẹ trong một ngôi nhà nhỏ ở ven rừng. '
          'Một ngày nọ, mẹ nhờ cô mang bánh và hoa quả đến thăm bà ngoại đang ốm. '
          'Trên đường đi, cô gặp một con sói đói. Sói hỏi cô đi đâu và cô ngây thơ kể hết. '
          'Sói chạy trước đến nhà bà, giả dạng và đợi cô bé.',
    },
    {
      'title': 'Kiến thức khoa học',
      'content': 'Trái Đất là hành tinh thứ ba tính từ Mặt Trời và là hành tinh duy nhất có sự sống. '
          'Trái Đất có đường kính khoảng mười hai ngàn bảy trăm ki-lô-mét và quay quanh Mặt Trời với vận tốc ba mươi ki-lô-mét mỗi giây. '
          'Bề mặt Trái Đất bao gồm bảy mươi phần trăm là đại dương và ba mươi phần trăm là đất liền.',
    },
    {
      'title': 'Thơ Xuân Diệu',
      'content': 'Thuyền và tôi đã không còn xa lạ, '
          'Tôi đưa tay bắt lấy sợi dây buồm, '
          'Rồi thuyền đưa tôi xuôi mây xuôi gió, '
          'Thuyền đưa tôi đến một chân trời. '
          'Tôi cùng thuyền lênh đênh sóng nước, '
          'Trăng nước non, nước non mênh mông.',
    },
    {
      'title': 'Đoạn văn ngắn',
      'content': 'Xin chào! Đây là ứng dụng đọc sách điện tử ReadBox. '
          'Chúng tôi cung cấp tính năng đọc tệp PDF và EPUB với nhiều tính năng tiện ích. '
          'Bạn có thể đánh dấu trang, ghi chú, tìm kiếm và giờ đây còn có thể nghe đọc bằng giọng nói. '
          'Hãy trải nghiệm và cho chúng tôi biết ý kiến của bạn!',
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeTTS();
  }

  Future<void> _initializeTTS() async {
    await _ttsService.initialize();
    _setupTTSCallbacks();
  }

  void _setupTTSCallbacks() {
    _ttsService.onSpeechStart = (_) {
      setState(() {
        _isTTSActive = true;
      });
    };

    _ttsService.onSpeechComplete = (_) {
      setState(() {
        _isTTSActive = false;
      });
    };

    _ttsService.onSpeechError = (error) {
      setState(() {
        _isTTSActive = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi đọc: $error'),
          backgroundColor: Colors.red,
        ),
      );
    };
  }

  @override
  void dispose() {
    _ttsService.stop();
    super.dispose();
  }

  Future<void> _toggleTTS() async {
    if (_isTTSActive) {
      await _ttsService.stop();
      setState(() {
        _isTTSActive = false;
        _showTTSControls = false;
      });
    } else {
      await _ttsService.speak(_sampleTexts[_selectedTextIndex]['content']!);
      setState(() {
        _showTTSControls = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Demo Text-to-Speech',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tiêu đề
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.blue.shade50,
                          Colors.purple.shade50,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.blue.shade200,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.volume_up_rounded,
                            color: Colors.blue,
                            size: 32,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Kiểm tra TTS',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade900,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Chọn đoạn văn và nhấn play để nghe',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 24),
                  
                  // Chọn text mẫu
                  Text(
                    'Chọn đoạn văn:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 12),
                  
                  // Dropdown chọn text
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: _selectedTextIndex,
                        isExpanded: true,
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        borderRadius: BorderRadius.circular(12),
                        items: _sampleTexts.asMap().entries.map((entry) {
                          return DropdownMenuItem<int>(
                            value: entry.key,
                            child: Text(
                              entry.value['title']!,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedTextIndex = value;
                              // Dừng đọc nếu đang đọc
                              if (_isTTSActive) {
                                _ttsService.stop();
                                _isTTSActive = false;
                                _showTTSControls = false;
                              }
                            });
                          }
                        },
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 24),
                  
                  // Hiển thị nội dung
                  Text(
                    'Nội dung:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 12),
                  
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Text(
                      _sampleTexts[_selectedTextIndex]['content']!,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.8,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 24),
                  
                  // Nút điều khiển
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Nút Play/Stop
                      ElevatedButton.icon(
                        onPressed: _toggleTTS,
                        icon: Icon(
                          _isTTSActive ? Icons.stop : Icons.play_arrow,
                          size: 28,
                        ),
                        label: Text(
                          _isTTSActive ? 'Dừng đọc' : 'Bắt đầu đọc',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isTTSActive ? Colors.red : Colors.green,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                        ),
                      ),
                      
                      SizedBox(width: 16),
                      
                      // Nút Settings
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _showTTSControls = !_showTTSControls;
                          });
                        },
                        icon: Icon(Icons.settings),
                        iconSize: 32,
                        color: Colors.blue,
                        tooltip: 'Cài đặt giọng đọc',
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 16),
                  
                  // Status indicator
                  Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: _isTTSActive 
                            ? Colors.red.shade50 
                            : Colors.green.shade50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _isTTSActive 
                              ? Colors.red.shade200 
                              : Colors.green.shade200,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_isTTSActive)
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.red,
                              ),
                            )
                          else
                            Icon(
                              Icons.check_circle,
                              size: 16,
                              color: Colors.green,
                            ),
                          SizedBox(width: 8),
                          Text(
                            _isTTSActive ? 'Đang đọc...' : 'Sẵn sàng',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _isTTSActive 
                                  ? Colors.red.shade700 
                                  : Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 24),
                  
                  // Hướng dẫn
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.amber.shade700),
                            SizedBox(width: 8),
                            Text(
                              'Hướng dẫn sử dụng',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber.shade900,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        _buildInstruction('1. Chọn đoạn văn muốn nghe từ dropdown'),
                        _buildInstruction('2. Nhấn nút "Bắt đầu đọc" để nghe'),
                        _buildInstruction('3. Nhấn biểu tượng ⚙️ để điều chỉnh tốc độ, âm lượng'),
                        _buildInstruction('4. Nhấn "Dừng đọc" để dừng lại'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // TTS Controls (ở dưới cùng)
          if (_showTTSControls)
            TTSControlWidget(
              textToRead: _sampleTexts[_selectedTextIndex]['content'],
              onStart: () {
                setState(() {
                  _isTTSActive = true;
                });
              },
              onStop: () {
                setState(() {
                  _isTTSActive = false;
                  _showTTSControls = false;
                });
              },
            ),
        ],
      ),
    );
  }

  Widget _buildInstruction(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: TextStyle(
              fontSize: 14,
              color: Colors.amber.shade900,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.amber.shade900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

