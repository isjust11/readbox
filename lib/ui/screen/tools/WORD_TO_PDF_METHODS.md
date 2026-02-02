# Các phương pháp chuyển đổi Word sang PDF

## 📊 So sánh các phương pháp

| Phương pháp | Độ chính xác | Độ phức tạp | Chi phí | Tốc độ | Recommend |
|-------------|--------------|-------------|---------|--------|-----------|
| **Backend API (LibreOffice)** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | Free | ⭐⭐⭐⭐ | ✅ Best |
| **CloudConvert** | ⭐⭐⭐⭐⭐ | ⭐ | $$ | ⭐⭐⭐⭐⭐ | ✅ Easy |
| **Aspose.Words Cloud** | ⭐⭐⭐⭐⭐ | ⭐⭐ | $$$ | ⭐⭐⭐⭐ | ✅ Pro |
| **Platform Channel** | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | Free | ⭐⭐⭐ | ⚠️ Complex |
| **Basic (Current)** | ⭐ | ⭐ | Free | ⭐⭐⭐⭐⭐ | ❌ Demo only |

## 1️⃣ Backend API với LibreOffice (RECOMMENDED)

### Ưu điểm
✅ **Free & Open source**
✅ **Chính xác cao** - LibreOffice xử lý tốt hầu hết Word formats
✅ **Full control** - Tự quản lý server
✅ **No API limits** - Không giới hạn số lần convert
✅ **Privacy** - Data không qua third-party

### Nhược điểm
❌ Cần setup backend server
❌ Cần maintain server
❌ Tốn tài nguyên server

### Backend Implementation (Node.js)

```javascript
// server.js
const express = require('express');
const multer = require('multer');
const { exec } = require('child_process');
const path = require('path');
const fs = require('fs');

const app = express();
const upload = multer({ dest: 'uploads/' });

// API endpoint for conversion
app.post('/api/convert/word-to-pdf', upload.single('file'), async (req, res) => {
  try {
    const inputPath = req.file.path;
    const outputPath = `${inputPath}.pdf`;
    
    // Use LibreOffice to convert
    const command = `libreoffice --headless --convert-to pdf --outdir ${path.dirname(outputPath)} ${inputPath}`;
    
    exec(command, (error, stdout, stderr) => {
      if (error) {
        console.error('Conversion error:', error);
        return res.status(500).json({ error: 'Conversion failed' });
      }
      
      // Send PDF file
      res.download(outputPath, 'converted.pdf', (err) => {
        // Cleanup
        fs.unlinkSync(inputPath);
        fs.unlinkSync(outputPath);
      });
    });
    
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.listen(3000, () => {
  console.log('Server running on port 3000');
});
```

### Backend Implementation (Python/Flask)

```python
# app.py
from flask import Flask, request, send_file
from werkzeug.utils import secure_filename
import subprocess
import os

app = Flask(__name__)

@app.route('/api/convert/word-to-pdf', methods=['POST'])
def convert_word_to_pdf():
    try:
        # Get uploaded file
        file = request.files['file']
        filename = secure_filename(file.filename)
        input_path = os.path.join('uploads', filename)
        file.save(input_path)
        
        # Convert using LibreOffice
        output_dir = 'outputs'
        subprocess.run([
            'libreoffice',
            '--headless',
            '--convert-to', 'pdf',
            '--outdir', output_dir,
            input_path
        ], check=True)
        
        # Get output file
        output_filename = filename.rsplit('.', 1)[0] + '.pdf'
        output_path = os.path.join(output_dir, output_filename)
        
        # Send file
        return send_file(output_path, as_attachment=True)
        
    except Exception as e:
        return {'error': str(e)}, 500
    finally:
        # Cleanup
        if os.path.exists(input_path):
            os.remove(input_path)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=3000)
```

### Docker Setup

```dockerfile
# Dockerfile
FROM python:3.9

# Install LibreOffice
RUN apt-get update && apt-get install -y \
    libreoffice \
    libreoffice-writer \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install Python dependencies
COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .

EXPOSE 3000

CMD ["python", "app.py"]
```

```yaml
# docker-compose.yml
version: '3.8'

services:
  word-to-pdf-api:
    build: .
    ports:
      - "3000:3000"
    volumes:
      - ./uploads:/app/uploads
      - ./outputs:/app/outputs
    environment:
      - API_KEY=your-secret-key
```

### Flutter Integration

```dart
Future<void> convertWithOwnServer() async {
  final dio = Dio();
  
  final formData = FormData.fromMap({
    'file': await MultipartFile.fromFile(
      _selectedFile!.path,
      filename: _selectedFile!.path.split('/').last,
    ),
  });
  
  final response = await dio.post(
    'https://your-server.com/api/convert/word-to-pdf',
    data: formData,
    options: Options(
      responseType: ResponseType.bytes,
      headers: {
        'Authorization': 'Bearer YOUR_API_KEY',
      },
    ),
  );
  
  // Save PDF
  final outputFile = File(outputPath);
  await outputFile.writeAsBytes(response.data);
}
```

## 2️⃣ CloudConvert API (EASIEST)

### Ưu điểm
✅ **Rất dễ dùng** - Simple API
✅ **Chính xác cao** - Professional conversion
✅ **No maintenance** - Fully managed
✅ **Multiple formats** - Support nhiều format
✅ **Free tier** - 25 conversions/day free

### Nhược điểm
❌ Paid service (sau free tier)
❌ API limits
❌ Data qua third-party

### Pricing
- **Free**: 25 conversions/day
- **Subscription**: $9/month cho 500 minutes
- **Pay as you go**: $0.008/minute

### Setup

```bash
# Get API key at https://cloudconvert.com/
```

### Implementation

```dart
import 'package:dio/dio.dart';

class CloudConvertService {
  final Dio _dio = Dio();
  final String _apiKey = 'YOUR_API_KEY';
  
  Future<File> convertWordToPdf(File wordFile) async {
    try {
      // 1. Create job
      final jobResponse = await _dio.post(
        'https://api.cloudconvert.com/v2/jobs',
        data: {
          'tasks': {
            'upload-my-file': {
              'operation': 'import/upload',
            },
            'convert-my-file': {
              'operation': 'convert',
              'input': 'upload-my-file',
              'output_format': 'pdf',
              'engine': 'office',  // Use Microsoft Office engine
              'pdf_a': false,
              'optimize_print': false,
            },
            'export-my-file': {
              'operation': 'export/url',
              'input': 'convert-my-file',
            },
          },
        },
        options: Options(
          headers: {'Authorization': 'Bearer $_apiKey'},
        ),
      );
      
      // 2. Upload file
      final uploadTask = jobResponse.data['data']['tasks']
          .firstWhere((t) => t['name'] == 'upload-my-file');
      
      final uploadUrl = uploadTask['result']['form']['url'];
      final uploadData = uploadTask['result']['form']['parameters'];
      
      final formData = FormData.fromMap({
        ...uploadData,
        'file': await MultipartFile.fromFile(wordFile.path),
      });
      
      await _dio.post(uploadUrl, data: formData);
      
      // 3. Wait for completion
      final jobId = jobResponse.data['data']['id'];
      String status = 'waiting';
      
      while (status != 'finished' && status != 'error') {
        await Future.delayed(const Duration(seconds: 2));
        
        final statusResponse = await _dio.get(
          'https://api.cloudconvert.com/v2/jobs/$jobId',
          options: Options(
            headers: {'Authorization': 'Bearer $_apiKey'},
          ),
        );
        
        status = statusResponse.data['data']['status'];
        
        if (status == 'error') {
          throw Exception('Conversion failed');
        }
      }
      
      // 4. Download PDF
      final exportTask = jobResponse.data['data']['tasks']
          .firstWhere((t) => t['name'] == 'export-my-file');
      
      final downloadUrl = exportTask['result']['files'][0]['url'];
      
      final pdfResponse = await _dio.get(
        'https:$downloadUrl',
        options: Options(responseType: ResponseType.bytes),
      );
      
      // Save to file
      final directory = await getApplicationDocumentsDirectory();
      final pdfFile = File('${directory.path}/converted_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await pdfFile.writeAsBytes(pdfResponse.data);
      
      return pdfFile;
      
    } catch (e) {
      throw Exception('CloudConvert error: $e');
    }
  }
}
```

## 3️⃣ Aspose.Words Cloud (PROFESSIONAL)

### Ưu điểm
✅ **Chính xác cao nhất** - Best formatting preservation
✅ **Feature-rich** - Nhiều tùy chọn conversion
✅ **Professional support**
✅ **No server needed**

### Nhược điểm
❌ Expensive
❌ Complex API

### Pricing
- **Free**: 150 API calls/month
- **Metered**: $0.003/call
- **Subscription**: Starting from $99/month

### Setup

1. Register at https://dashboard.aspose.cloud/
2. Get Client ID and Client Secret

### Implementation

```dart
class AsposeWordsService {
  final Dio _dio = Dio();
  final String _clientId = 'YOUR_CLIENT_ID';
  final String _clientSecret = 'YOUR_CLIENT_SECRET';
  String? _accessToken;
  
  Future<String> _getAccessToken() async {
    if (_accessToken != null) return _accessToken!;
    
    final response = await _dio.post(
      'https://api.aspose.cloud/connect/token',
      data: {
        'grant_type': 'client_credentials',
        'client_id': _clientId,
        'client_secret': _clientSecret,
      },
      options: Options(
        contentType: 'application/x-www-form-urlencoded',
      ),
    );
    
    _accessToken = response.data['access_token'];
    return _accessToken!;
  }
  
  Future<File> convertWordToPdf(File wordFile) async {
    try {
      final token = await _getAccessToken();
      final fileName = wordFile.path.split('/').last;
      
      // 1. Upload file to Aspose cloud storage
      final uploadData = FormData.fromMap({
        'file': await MultipartFile.fromFile(wordFile.path),
      });
      
      await _dio.put(
        'https://api.aspose.cloud/v4.0/words/storage/file/$fileName',
        data: uploadData,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      
      // 2. Convert to PDF
      final convertResponse = await _dio.get(
        'https://api.aspose.cloud/v4.0/words/$fileName?format=pdf',
        options: Options(
          responseType: ResponseType.bytes,
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      
      // 3. Save PDF
      final directory = await getApplicationDocumentsDirectory();
      final pdfFile = File('${directory.path}/converted_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await pdfFile.writeAsBytes(convertResponse.data);
      
      // 4. Cleanup cloud storage
      await _dio.delete(
        'https://api.aspose.cloud/v4.0/words/storage/file/$fileName',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      
      return pdfFile;
      
    } catch (e) {
      throw Exception('Aspose conversion error: $e');
    }
  }
}
```

## 4️⃣ Platform Channel (Advanced)

### Ưu điểm
✅ Free
✅ Offline conversion
✅ No external dependencies

### Nhược điểm
❌ Rất phức tạp
❌ Cần native code cho iOS & Android
❌ Khó maintain
❌ Platform-specific bugs

### Android Implementation (Kotlin)

```kotlin
// MainActivity.kt
import org.apache.poi.xwpf.usermodel.XWPFDocument
import org.apache.poi.xwpf.converter.pdf.PdfConverter
import org.apache.poi.xwpf.converter.pdf.PdfOptions
import java.io.*

class MainActivity: FlutterActivity() {
  private val CHANNEL = "com.yourapp/word_converter"
  
  override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    
    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
      .setMethodCallHandler { call, result ->
        if (call.method == "convertWordToPdf") {
          val wordPath = call.argument<String>("wordPath")
          val pdfPath = call.argument<String>("pdfPath")
          
          try {
            convertWordToPdf(wordPath!!, pdfPath!!)
            result.success(pdfPath)
          } catch (e: Exception) {
            result.error("CONVERSION_ERROR", e.message, null)
          }
        }
      }
  }
  
  private fun convertWordToPdf(wordPath: String, pdfPath: String) {
    val document = XWPFDocument(FileInputStream(wordPath))
    val out = FileOutputStream(pdfPath)
    val options = PdfOptions.create()
    
    PdfConverter.getInstance().convert(document, out, options)
    
    document.close()
    out.close()
  }
}
```

```gradle
// build.gradle
dependencies {
  implementation 'org.apache.poi:poi:5.2.3'
  implementation 'org.apache.poi:poi-ooxml:5.2.3'
  implementation 'fr.opensagres.xdocreport:fr.opensagres.poi.xwpf.converter.pdf:2.0.4'
}
```

### iOS Implementation (Swift)

```swift
// AppDelegate.swift
import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    let controller = window?.rootViewController as! FlutterViewController
    let channel = FlutterMethodChannel(
      name: "com.yourapp/word_converter",
      binaryMessenger: controller.binaryMessenger
    )
    
    channel.setMethodCallHandler { [weak self] (call, result) in
      if call.method == "convertWordToPdf" {
        guard let args = call.arguments as? [String: Any],
              let wordPath = args["wordPath"] as? String,
              let pdfPath = args["pdfPath"] as? String
        else {
          result(FlutterError(code: "INVALID_ARGS", message: nil, details: nil))
          return
        }
        
        self?.convertWordToPdf(wordPath: wordPath, pdfPath: pdfPath, result: result)
      }
    }
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  private func convertWordToPdf(wordPath: String, pdfPath: String, result: @escaping FlutterResult) {
    // iOS doesn't have built-in Word to PDF conversion
    // You would need to use a third-party library or WebView
    result(FlutterError(code: "NOT_IMPLEMENTED", message: "iOS conversion not implemented", details: nil))
  }
}
```

### Flutter Side

```dart
class PlatformWordConverter {
  static const platform = MethodChannel('com.yourapp/word_converter');
  
  Future<String> convertWordToPdf(String wordPath) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final pdfPath = '${directory.path}/converted_${DateTime.now().millisecondsSinceEpoch}.pdf';
      
      final result = await platform.invokeMethod('convertWordToPdf', {
        'wordPath': wordPath,
        'pdfPath': pdfPath,
      });
      
      return result as String;
    } catch (e) {
      throw Exception('Platform conversion failed: $e');
    }
  }
}
```

## 🎯 Recommendation cho Readbox

### Cho Development/Testing
Dùng **CloudConvert** (free tier) - dễ nhất, không cần setup

### Cho Production
Dùng **Backend API với LibreOffice**:
- Free và unlimited
- Full control
- Privacy-friendly
- Setup 1 lần, dùng mãi mãi

### Implementation Steps

1. **Setup Backend** (1-2 hours)
   ```bash
   # Using Docker
   docker-compose up -d
   ```

2. **Update Flutter app** (30 minutes)
   - Thay thế method `_convertToPdf()` trong `word_to_pdf_converter_screen.dart`
   - Add dio dependency nếu chưa có
   - Add API endpoint config

3. **Deploy Backend**
   - Deploy to Heroku, DigitalOcean, AWS, etc.
   - Setup HTTPS
   - Add authentication

4. **Test**
   - Test với các file Word khác nhau
   - Test formatting preservation
   - Test error handling

## 📚 References

- [LibreOffice Headless](https://www.libreoffice.org/discover/headless-mode/)
- [CloudConvert API](https://cloudconvert.com/api/v2)
- [Aspose.Words Cloud](https://docs.aspose.cloud/words/)
- [Apache POI](https://poi.apache.org/)

## 🔧 Troubleshooting

### LibreOffice conversion issues
```bash
# Check if LibreOffice is installed
libreoffice --version

# Test conversion manually
libreoffice --headless --convert-to pdf test.docx
```

### Memory issues
- For large files, increase server memory
- Consider chunked upload/download
- Add conversion timeout

### Format issues
- Not all Word features convert perfectly
- Complex layouts may need adjustment
- Embedded fonts might be lost
