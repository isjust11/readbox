import 'package:flutter/material.dart';
import 'package:readbox/ui/screen/screen.dart';

/// Demo screen để test 3 phiên bản PDF Viewer
/// Sử dụng PDF mẫu miễn phí từ internet
class PdfViewerDemoScreen extends StatelessWidget {
  const PdfViewerDemoScreen({Key? key}) : super(key: key);

  // PDF test URLs
  static const String samplePdf1 = 
      'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf';
  static const String samplePdf2 = 
      'https://www.africau.edu/images/default/sample.pdf';
  static const String samplePdf3 = 
      'https://www.adobe.com/support/products/enterprise/knowledgecenter/media/c4611_sample_explain.pdf';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PDF Viewer Demo'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // Header
          Card(
            color: Colors.blue[50],
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
                        'Test PDF Viewers',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[900],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Chọn phiên bản PDF viewer để test các tính năng khác nhau',
                    style: TextStyle(color: Colors.blue[700]),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 24),

          // Version 1: Basic
          _buildVersionCard(
            context,
            title: '1. Basic PDF Viewer',
            subtitle: 'Xem PDF cơ bản (pdfx)',
            icon: Icons.picture_as_pdf,
            color: Colors.blue,
            features: [
              'Xem PDF',
              'Điều hướng trang',
              'Zoom cơ bản',
            ],
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PdfViewerScreen(
                    fileUrl: samplePdf1,
                    title: 'Basic PDF Viewer',
                  ),
                ),
              );
            },
          ),

          SizedBox(height: 16),

          // Version 2: With Selection
          _buildVersionCard(
            context,
            title: '2. PDF Viewer với Text Selection',
            subtitle: 'Chọn & copy text (Syncfusion)',
            icon: Icons.text_fields,
            color: Colors.green,
            features: [
              '✅ Chọn text (long press & drag)',
              '✅ Copy text vào clipboard',
              '✅ Tìm kiếm text',
              '✅ Zoom nâng cao',
            ],
            badge: 'Khuyến nghị',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PdfViewerWithSelectionScreen(
                    fileUrl: samplePdf2,
                    title: 'PDF với Text Selection',
                  ),
                ),
              );
            },
          ),

          SizedBox(height: 16),

          // Version 3: Advanced
          _buildVersionCard(
            context,
            title: '3. PDF Viewer Nâng cao',
            subtitle: 'Full features với annotations (Syncfusion)',
            icon: Icons.auto_awesome,
            color: Colors.orange,
            features: [
              '✅ Tất cả tính năng của version 2',
              '✅ Highlight text (6 màu)',
              '✅ Thêm ghi chú (annotations)',
              '✅ Quản lý ghi chú',
              '✅ Export ghi chú',
            ],
            badge: 'HOT',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PdfViewerAdvancedScreen(
                    fileUrl: samplePdf3,
                    title: 'PDF Viewer Nâng cao',
                  ),
                ),
              );
            },
          ),

          SizedBox(height: 24),

          // Instructions
          Card(
            color: Colors.amber[50],
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb_outline, color: Colors.amber[700]),
                      SizedBox(width: 8),
                      Text(
                        'Hướng dẫn sử dụng',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber[900],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  _buildInstruction('1', 'Chọn phiên bản PDF viewer bên trên'),
                  _buildInstruction('2', 'Long press trên text để chọn (version 2 & 3)'),
                  _buildInstruction('3', 'Kéo để chọn vùng text'),
                  _buildInstruction('4', 'Nhấn nút Copy/Highlight/Ghi chú'),
                  _buildInstruction('5', 'Xem danh sách ghi chú (icon 📝)'),
                ],
              ),
            ),
          ),

          SizedBox(height: 16),

          // Documentation links
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '📚 Tài liệu',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),
                  _buildDocLink(
                    'PDF_FEATURES_README.md',
                    'Tổng quan tính năng',
                  ),
                  _buildDocLink(
                    'PDF_TEXT_SELECTION_GUIDE.md',
                    'Hướng dẫn chi tiết',
                  ),
                  _buildDocLink(
                    'USAGE_EXAMPLE.md',
                    'Ví dụ code cụ thể',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVersionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required List<String> features,
    required VoidCallback onTap,
    String? badge,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: color, size: 28),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (badge != null)
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: color,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  badge,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
              SizedBox(height: 16),
              ...features.map((feature) => Padding(
                    padding: EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        Icon(
                          feature.startsWith('✅')
                              ? Icons.check_circle
                              : Icons.circle_outlined,
                          size: 16,
                          color: feature.startsWith('✅')
                              ? Colors.green
                              : Colors.grey,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            feature.replaceAll('✅ ', ''),
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstruction(String number, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.amber[700],
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocLink(String filename, String description) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(Icons.description, size: 16, color: Colors.blue),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  filename,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


