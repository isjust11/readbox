---
description: "Plan kỹ thuật HocVui — Nền tảng tạo đề tự động bằng OCR (Tesseract), thi online ổn định, lưu kết quả offline-first và chống gian lận. Áp dụng cho backend codebase-admin (nhánh develop-hocvui) và app Flutter readbox."
---

# HocVui — Plan kỹ thuật nền tảng thi/đề OCR

> Tài liệu này là plan tham chiếu khi phát triển tính năng HocVui. Mọi PR liên quan phải bám theo các quyết định kiến trúc và thứ tự triển khai ở đây. Quy trình code/build/test tuân thủ `.agents/workflows/flutter-workflow.md`.

## 0. Bối cảnh & phạm vi

- **Ý tưởng**: dùng **OCR** số hoá tài liệu có sẵn (bộ đề lái xe, đề ngôn ngữ, sách) → ngân hàng câu hỏi có cấu trúc → tạo đề → thi online cho giáo viên / học sinh / người làm bài.
- **Repo & nhánh**:
  - Backend (NestJS): `codebase-admin` @ `develop-hocvui`.
  - App (Flutter): `readbox` @ `develop` (tạo nhánh feature tương ứng khi làm).
  - OCR engine: **Tesseract self-host** (ưu tiên tiết kiệm chi phí, không dùng LLM multimodal).
- **Nền tảng đã có (tái dùng)**:
  - NestJS: `src/gateways/notifications.gateway.ts` (Socket.IO, join/leave room + role) — đang lưu state in-memory, `handleConnection/Disconnect` đang comment → cần nâng cấp.
  - Flutter: `connectivity_plus`, Isar (local DB), secure storage.
  - Flutter **chưa** có `socket_io_client` → cần thêm.

### Nguyên tắc xuyên suốt
1. **Realtime chỉ để giám sát/đồng bộ, KHÔNG phải điều kiện làm bài.** Mất socket vẫn làm bài bình thường.
2. **Server là nguồn chân lý** cho thời gian, deadline, chấm điểm, đáp án đúng.
3. **Offline-first**: mọi thao tác ghi cục bộ trước (Isar), sync server sau → mất mạng/crash không mất bài.
4. **Human-in-the-loop bắt buộc** cho nội dung OCR (Tesseract không có LLM bù lỗi).

---

## 1. OCR bằng Tesseract (self-host)

### 1.1 Kiến trúc
```
NestJS API (upload) ──enqueue──> BullMQ (Redis)
                                     │
                          [OCR Worker - microservice Python]
                          OpenCV preprocess → Tesseract → TSV/hOCR
                                     │
                          Rule-based parser → JSON câu hỏi
                                     │
                          PostgreSQL (extracted_question) + crop ảnh → S3/MinIO
```
- Tách **microservice Python** (`pytesseract` + `opencv-python` + `pdf2image`), đóng gói Docker: `tesseract-ocr` + `tesseract-ocr-vie` + `tessdata_best`.
- NestJS giao việc qua queue, nhận kết quả qua DB/callback.

### 1.2 Tiền xử lý ảnh (OpenCV) — quyết định ~70% độ chính xác
1. Grayscale
2. Khử nghiêng (deskew) bằng projection profile / Hough
3. Sửa phối cảnh (perspective) nếu chụp điện thoại
4. Nhị phân hoá (Otsu / adaptive threshold)
5. Khử nhiễu, bỏ viền, chuẩn hoá ~300 DPI
6. PDF → tách trang ảnh

### 1.3 Chạy Tesseract
- Tesseract 5 (LSTM), `lang=vie+eng`, `tessdata_best`.
- Lấy **TSV output** (level/block/par/line/word + `conf` + bbox) để dựng lại bố cục và gắn cờ vùng đáng ngờ.
- PSM theo loại tài liệu: `--psm 6` (1 cột) / `--psm 4`/`3` (phức tạp).

### 1.4 Parser cấu trúc (rule-based, không LLM)
- State machine theo dòng TSV:
  - Bắt đầu câu: `^(Câu\s*\d+:?|\d+[.)])`
  - Đáp án: `^[A-D][.)]\s+`
  - Đáp án đúng: ưu tiên **map từ bảng đáp án riêng** (số câu ↔ A/B/C/D), không dựa vào in đậm.
  - State: `SEEK_QUESTION → IN_STEM → IN_OPTIONS → (gặp câu kế) → emit`.
- Mỗi miền 1 bộ rule riêng: `drivingParser`, `languageParser` (dễ mở rộng domain).

### 1.5 Hình trong câu (biển báo / sa hình)
- OpenCV tìm vùng phi văn bản (contour/connected-component lớn không chứa text theo bbox TSV) → crop từ ảnh gốc → upload → gắn `media_id` vào câu gần nhất.
- Giai đoạn đầu: cho phép **crop thủ công trong UI review** để đảm bảo đúng.

### 1.6 Độ tin cậy & review
- `confidence` câu = trung bình `conf` các word; `< ngưỡng` → `needs_review=true`.
- UI review **side-by-side**: ảnh gốc trái / text trích xuất phải, highlight word conf thấp; sửa stem/đáp án/đáp án đúng; gán ảnh; bulk approve; gộp câu trùng (hash nội dung chuẩn hoá bỏ dấu/space).

### 1.7 Hiệu năng & chi phí
- Worker pool + giới hạn concurrency, BullMQ, retry idempotent.
- Cache theo **hash ảnh trang** (không OCR lại). Scale ngang nhiều container worker.

### 1.8 Data model ingestion (mới, không đụng schema cũ)
```sql
ocr_job(id, source_type, file_url, page_count, lang, status, created_by, created_at)
ocr_page(id, job_id, page_no, image_url, tsv jsonb, mean_conf)
extracted_question(id, job_id, page_id, number, stem, options jsonb,
                   correct_answer, media_refs jsonb, confidence,
                   status, needs_review, question_id)
-- status: pending → ocr_done → parsed → in_review → approved → imported
```

---

## 2. Join lớp học — kết nối ổn định

### 2.1 Nâng cấp Socket.IO (dựa trên `notifications.gateway.ts`)
1. **Redis adapter** (`@socket.io/redis-adapter` + `ioredis`) để nhiều instance NestJS share room (hiện in-memory Map sẽ vỡ khi scale).
2. **Auth khi connect**: middleware kiểm JWT trong `handshake.auth.token`, gắn `userId`/`role`; từ chối nếu sai.
3. **Bật lại presence** (`handleConnection/Disconnect`), lưu online/offline/reconnecting theo `userId` qua Redis.
4. Tạo **`ExamGateway`** riêng (tách khỏi gateway nhà hàng): room = `exam:{sessionId}`.

### 2.2 Kết nối ổn định
- `socket_io_client` (Flutter) reconnection: backoff luỹ thừa + jitter, không giới hạn lần thử khi đang thi.
- Heartbeat ping/pong phát hiện kết nối chết.
- **Idempotent join**: cùng `userId` vào lại phiên → khôi phục trạng thái, **không reset timer**.
- **Resync sau reconnect**: client gửi `lastEventSeq` → server replay event thiếu hoặc gửi snapshot.
- **Đồng hồ chuẩn từ server**: join trả `serverNow + deadline`; client tính `clockOffset` → suy thời gian còn lại (chống chỉnh giờ máy).
- Hiển thị trạng thái `connecting/connected/reconnecting/offline` (banner) — **không khoá thao tác trả lời**.

### 2.3 Luồng vào phiên
```
GET /exam-sessions/:id  → tải toàn bộ đề + media về Isar
Socket connect (JWT) → emit join {sessionId}
Teacher dashboard: presence + tiến độ realtime
Server emit "exam:start"; nếu lỡ, client lấy snapshot qua REST
```

---

## 3. Lưu kết quả chống mất mạng / sự cố (offline-first)

### 3.1 Hai lớp bền vững
- **Lớp 1 — Isar (luôn ghi)**: mỗi lần đổi đáp án ghi ngay xuống Isar, không giữ chỉ trong RAM.
- **Lớp 2 — Server sync (khi online)**: worker nền đẩy đáp án chưa sync theo batch.
→ Mất mạng chỉ ảnh hưởng *thời điểm sync*, không mất dữ liệu.

### 3.2 Tải đề về trước
Khi bắt đầu thi: tải **toàn bộ câu hỏi + media** về Isar/disk → rớt mạng vẫn làm đủ bài.

### 3.3 Schema cục bộ (Isar) + autosave
```
Attempt { id, sessionId, startedAtServer, deadlineServer, clockOffset, status }
LocalAnswer { attemptId, questionId, response, answeredAtClient, seq, synced }
```
- `seq` tăng đơn điệu theo attempt; mỗi tương tác ghi `LocalAnswer(synced=false)` ngay.
- **Khôi phục sau crash**: mở app → đọc Isar → phục hồi câu đang làm + thời gian còn lại (`deadlineServer + clockOffset`) + đáp án đã chọn.

### 3.4 Sync nền (idempotent)
- Online (`connectivity_plus`) → gửi batch `LocalAnswer` chưa sync.
- `POST /attempts/:id/answers` (batch) → **upsert idempotent theo `(attemptId, questionId)`**, giữ bản mới nhất theo `seq`/`answeredAt`; trả ack → client set `synced=true`.
- **Autosave định kỳ lên server khi online** (10–15s) → thiết bị hỏng vẫn còn trạng thái gần nhất trên server.

### 3.5 Server-side + audit log
```sql
attempt(id, session_id, taker_id, started_at, deadline, status)
answer(id, attempt_id, question_id, response, seq, answered_at, updated_at)       -- latest
answer_event(id, attempt_id, question_id, response, seq, client_ts, server_ts)    -- append-only
```
- `answer` = bản mới nhất; `answer_event` = log append-only (khôi phục + đối soát + chống gian lận).
- Server enforce `deadline`: `answered_at > deadline + grace` → reject/flag.

### 3.6 Nộp bài chống lỗi mạng
- Ghi Isar trước (`status=submitting`) rồi gửi; mất mạng → retry liên tục, đánh dấu "đã nộp – chờ sync".
- Server chấp nhận sync muộn trong **cửa sổ ân hạn** theo `submittedAt`, có đối soát deadline.

### 3.7 Đồng hồ & thời gian
- `deadline` do server cấp; client resync `clockOffset` định kỳ khi online; offline dùng offset lần cuối, reconnect server kiểm lại.

---

## 4. Chống gian lận

> Mâu thuẫn: offline-first chống mất mạng nhưng là kẽ hở gian lận → giải bằng **chính sách theo loại đề** + nhiều lớp phòng vệ.

### 4.1 Server-authoritative
- Không gửi đáp án đúng trước khi nộp; chấm điểm ở server.
- Đảo thứ tự câu/đáp án theo seed `attemptId`.
- Server quản deadline & thời gian.

### 4.2 Phát hiện rời màn hình (Flutter)
- `WidgetsBindingObserver` bắt `paused/inactive` → log số lần + thời lượng rời app; cảnh báo/auto-nộp theo cấu hình.
- Web (nếu có): `visibilitychange` + blur/focus.

### 4.3 Chặn chụp/quay màn hình
- Android `FLAG_SECURE`; iOS phát hiện screenshot/screen recording → log/cảnh báo.

### 4.4 Phiên duy nhất
- 1 attempt/học sinh/đề; khoá 1 thiết bị; phát hiện đăng nhập đồng thời → đá phiên cũ qua socket.

### 4.5 Chính sách online theo độ quan trọng

| Loại đề | Offline | Khi mất mạng |
|---|---|---|
| Luyện tập | Cho phép | Làm bình thường, sync sau |
| Thi high-stakes | Hạn chế | Log thời lượng offline; quá ngưỡng → tạm khoá/flag; bắt buộc online lại |

### 4.6 Phát hiện bất thường (từ `answer_event`)
- Trả lời quá nhanh, mẫu giống hệt giữa nhiều HS, offline lâu rồi trả lời đúng hàng loạt → flag cho giáo viên.
- Dashboard giám sát connect/disconnect/background/đổi đáp án theo timestamp.

### 4.7 Proctoring (tuỳ chọn, high-stakes)
- Xác thực danh tính đầu giờ, chụp webcam định kỳ, giám sát qua room socket.

---

## 5. Dependencies cần thêm

**NestJS (`codebase-admin`)**
- `@socket.io/redis-adapter`, `ioredis` — scale socket + presence
- `bullmq` (nếu chưa có) — queue OCR/sync
- OCR: microservice Python (`pytesseract`, `opencv-python`, `pdf2image`) trong Docker

**Flutter (`readbox`)**
- `socket_io_client` (mới)
- Tái dùng: `connectivity_plus`, Isar, secure storage
- (tuỳ chọn) `workmanager` — sync nền khi app bị kill

---

## 6. Thứ tự triển khai trên `develop-hocvui`

| Bước | Nội dung | Repo |
|---|---|---|
| 1 | OCR microservice (Tesseract + OpenCV) + queue + `ocr_job/page/extracted_question` + UI review | codebase-admin (+ admin FE/Flutter) |
| 2 | `ExamGateway` (Redis adapter, JWT auth, presence, resync) + `socket_io_client` | codebase-admin + readbox |
| 3 | Offline-first: schema Isar `Attempt/LocalAnswer` + autosave + sync idempotent + khôi phục crash | readbox |
| 4 | Server `attempt/answer/answer_event` + deadline + nộp bài chống lỗi mạng | codebase-admin |
| 5 | Chống gian lận: lifecycle, FLAG_SECURE, phiên duy nhất, chính sách offline, anomaly flag | readbox + codebase-admin |

> **Gợi ý ưu tiên**: làm song song Phần 3 (offline-first) + Phần 2 (ExamGateway) trước vì ảnh hưởng trực tiếp trải nghiệm thi; Phần 1 (OCR) chạy độc lập ở microservice.

---

## 7. Rủi ro & lưu ý
- Tesseract dấu tiếng Việt dễ sai → tiền xử lý kỹ + review bắt buộc; câu **điểm liệt** lái xe phải đối chiếu thủ công.
- Pháp lý đề chính thức: OCR chỉ để số hoá nhanh, không thay kiểm duyệt nội dung.
- Audio (kỹ năng Nghe) nằm ngoài OCR → luồng ingest riêng.
- Mọi nội dung OCR/Ai-suggest đều qua duyệt người trước khi vào ngân hàng chính thức.
