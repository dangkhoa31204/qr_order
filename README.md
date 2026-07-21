# 📱 Aroma Bistro - Flutter Mobile & Web Client Application

> **Ứng dụng di động và Web gọi món tại bàn qua mã QR Code & Quản lý Nhà hàng Real-time.**

---

## 📌 1. Giới thiệu

Đây là ứng dụng Frontend được xây dựng bằng **Flutter (Dart)**, hỗ trợ cả 2 nền tảng:
1. **Flutter Web (dành cho Khách hàng)**: Quét mã QR code tại bàn để mở thực đơn điện tử, gọi món, chat với AI Sommelier, thanh toán VietQR và đánh giá dịch vụ mà không cần cài đặt ứng dụng.
2. **Flutter Mobile & Web (dành cho Nhân viên & Admin)**: 
   * **Staff Workspace**: Nhận thông báo đơn hàng real-time qua SignalR WebSockets, cập nhật trạng thái chế biến (Xác nhận ➔ Nấu món ➔ Phục vụ).
   * **Admin Workspace**: Quản lý thực đơn (CRUD + Upload Cloudinary CDN), tạo bàn & xuất mã QR Code, quản lý tài khoản nhân viên, xem biểu đồ doanh thu & AI Recommendations.

---

## 🛠️ 2. Hướng dẫn Chạy Ứng dụng (Run Locally)

### Yêu cầu tiên quyết:
* Cài đặt **Flutter SDK (>=3.0.0)** và **Dart SDK**.
* Hỗ trợ Google Chrome (dành cho Web) hoặc Android Emulator / thiết bị thật (dành cho Mobile).

### Các bước chạy:
1. Chuyển vào thư mục `qr_order`:
   ```bash
   cd qr_order
   ```

2. Tải các thư viện phụ thuộc:
   ```bash
   flutter pub get
   ```

3. Khởi chạy ứng dụng:
   * **Chạy giao diện Web**:
     ```bash
     flutter run -d chrome
     ```
   * **Chạy ứng dụng Android**:
     ```bash
     flutter run
     ```

---

## 🔗 3. Cấu hình Kết nối Backend API

File cấu hình kết nối [api_service.dart](file:///d:/prmproject/qr_order/lib/services/api_service.dart) mặc định trỏ tới API Gateway:
* Local URL: `http://localhost:5000`
* Production URL: `https://prm-gateway.onrender.com`
