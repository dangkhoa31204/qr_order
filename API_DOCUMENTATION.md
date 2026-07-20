# 📖 PRM Backend — API Documentation

> **Base URL (Production):** `https://qr-order-api.onrender.com`  
> **Swagger UI:** `https://qr-order-api.onrender.com/swagger`  
> **Framework:** ASP.NET Core 8 · **DB:** SQL Server (Azure)  
> **Realtime:** SignalR

---

## 📁 Cấu trúc thư mục

```
PRM_beckend/
├── Controllers/
│   ├── AuthController.cs       # Đăng nhập, đăng ký, quản lý tài khoản
│   ├── MenuController.cs       # Quản lý thực đơn
│   ├── OrdersController.cs     # Quản lý đơn hàng
│   └── TablesController.cs     # Quản lý bàn ăn + QR Code
├── Models/
│   ├── Account.cs              # Model tài khoản
│   ├── MenuItem.cs             # Model món ăn
│   ├── Order.cs                # Model đơn hàng
│   ├── OrderItem.cs            # Model chi tiết đơn hàng
│   ├── Table.cs                # Model bàn ăn
│   └── Enums/
│       └── MenuCategory.cs     # Enum danh mục món ăn
├── Hubs/
│   └── StaffNotificationHub.cs # SignalR Hub thông báo realtime cho Staff
├── Data/
│   └── AppDbContext.cs         # Entity Framework DbContext
└── Program.cs                  # Cấu hình app, JWT, CORS, Swagger
```

---

## 🔐 Xác thực (Authentication)

Hệ thống dùng **JWT Bearer Token**.

- Sau khi login thành công, lưu lại `accessToken`.
- Các API cần quyền phải gửi header:
  ```
  Authorization: Bearer <accessToken>
  ```
- **Token hết hạn sau 4 giờ.**

### Phân quyền (Role)

| Role | Giá trị | Mô tả |
|------|---------|-------|
| Customer | `0` | Khách hàng (tự đăng ký) |
| Admin | `1` | Quản trị viên |
| Staff | `2` | Nhân viên phục vụ |

---

## 🔑 Auth API — `/api/auth`

### `POST /api/auth/login`
Đăng nhập, nhận JWT token.

**Auth:** ❌ Không cần  
**Request Body:**
```json
{
  "usernameOrEmail": "admin",
  "password": "123456"
}
```
**Response `200 OK`:**
```json
{
  "accessToken": "eyJhbGci...",
  "expiresAt": "2025-01-01T10:00:00Z",
  "username": "admin",
  "role": 1
}
```
**Lỗi:**
- `400` — Thiếu username/password
- `401` — Sai thông tin đăng nhập

---

### `POST /api/auth/register`
Đăng ký tài khoản khách hàng mới. Role mặc định = `0` (Customer).

**Auth:** ❌ Không cần  
**Request Body:**
```json
{
  "username": "khach01",
  "email": "khach01@gmail.com",
  "password": "matkhau123",
  "fullName": "Nguyen Van A",
  "phoneNumber": "0901234567"  // optional
}
```
**Response `201 Created`:**
```json
{
  "accountId": 5,
  "username": "khach01",
  "email": "khach01@gmail.com",
  "fullName": "Nguyen Van A",
  "phoneNumber": "0901234567",
  "role": 0,
  "isActive": true,
  "createdAt": "2025-01-01T06:00:00Z"
}
```
**Lỗi:**
- `400` — Thiếu trường bắt buộc
- `409` — Username hoặc Email đã tồn tại

---

### `GET /api/auth/staff`
Lấy danh sách tài khoản Staff (role = 2).

**Auth:** 🔒 Admin (role 1)  
**Response `200 OK`:** Mảng `AccountResponse[]`
```json
[
  {
    "accountId": 2,
    "username": "staff01",
    "email": "staff01@restaurant.com",
    "fullName": "Le Thi B",
    "phoneNumber": null,
    "role": 2,
    "isActive": true,
    "createdAt": "2025-01-01T00:00:00Z",
    "lastLoginAt": "2025-01-02T07:00:00Z"
  }
]
```

---

### `POST /api/auth/admin-create`
Admin tạo tài khoản Staff mới. Role mặc định = `2` (Staff).

**Auth:** 🔒 Admin (role 1)  
**Request Body:**
```json
{
  "username": "staff02",
  "email": "staff02@restaurant.com",
  "password": "matkhau456",
  "fullName": "Tran Van C",
  "phoneNumber": "0987654321"  // optional
}
```
**Response `201 Created`:** `AccountResponse`  
**Lỗi:**
- `400` — Thiếu trường bắt buộc
- `409` — Username hoặc Email đã tồn tại

---

### `PUT /api/auth/accounts/{id}`
Cập nhật thông tin tài khoản.

**Auth:** 🔒 Admin (role 1) hoặc Staff (role 2) — Staff chỉ được sửa tài khoản của mình  
**Path Params:** `id` — AccountId  
**Request Body:**
```json
{
  "username": "staff02_updated",
  "email": "new@restaurant.com",
  "fullName": "Tran Van C Updated",
  "phoneNumber": null,
  "isActive": true  // Chỉ Admin mới được thay đổi trường này
}
```
**Response `200 OK`:** `AccountResponse`  
**Lỗi:**
- `400` — Thiếu trường bắt buộc
- `403` — Staff cố sửa tài khoản người khác
- `404` — Không tìm thấy tài khoản
- `409` — Username hoặc Email đã tồn tại

---

### `DELETE /api/auth/accounts/{id}`
Admin xóa mềm tài khoản (chuyển `isActive = false`).

**Auth:** 🔒 Admin (role 1)  
**Path Params:** `id` — AccountId  
**Response `204 No Content`**  
**Lỗi:**
- `400` — Admin không được tự xóa mình
- `404` — Không tìm thấy tài khoản

---

### `GET /api/auth/admin-only`
Kiểm tra token có quyền Admin không.

**Auth:** 🔒 Admin (role 1)  
**Response `200 OK`:** `"Admin access granted"`

---

## 🍽️ Menu API — `/api/menu`

### Enum `MenuCategory`

| Giá trị | Tên |
|---------|-----|
| `1` | Food |
| `2` | Drink |
| `3` | Dessert |
| `4` | Combo |
| `5` | Other |

### Schema `MenuItemResponse`
```json
{
  "menuItemId": 1,
  "name": "Phở Bò",
  "description": "Phở bò truyền thống",
  "price": 65000.00,
  "category": 1,
  "imageUrl": "https://example.com/pho.jpg",
  "isAvailable": true,
  "createdAt": "2025-01-01T00:00:00Z",
  "updatedAt": null
}
```

---

### `GET /api/menu`
Lấy danh sách **món đang hiển thị** (`isAvailable = true`). Dùng cho trang menu khách.

**Auth:** ❌ Không cần  
**Response `200 OK`:** `MenuItemResponse[]` — Sắp xếp theo Category → Name

---

### `GET /api/menu/all`
Lấy **tất cả món**, bao gồm món đã ẩn. Dùng cho trang quản lý Admin.

**Auth:** 🔒 Admin (role 1)  
**Response `200 OK`:** `MenuItemResponse[]`

---

### `GET /api/menu/{id}`
Lấy chi tiết một món.

**Auth:** ❌ Không cần  
**Path Params:** `id` — MenuItemId  
**Response `200 OK`:** `MenuItemResponse`  
**Lỗi:** `404` — Không tìm thấy

---

### `POST /api/menu`
Tạo món mới.

**Auth:** 🔒 Admin (role 1)  
**Request Body:**
```json
{
  "name": "Bún Bò Huế",
  "description": "Bún bò cay đặc trưng xứ Huế",
  "price": 75000,
  "category": 1,
  "imageUrl": "https://example.com/bun-bo.jpg"  // optional
}
```
**Response `201 Created`:** `MenuItemResponse`  
**Lỗi:**
- `400` — Thiếu Name hoặc Price ≤ 0

---

### `PUT /api/menu/{id}`
Cập nhật toàn bộ thông tin món.

**Auth:** 🔒 Admin (role 1)  
**Path Params:** `id`  
**Request Body:**
```json
{
  "name": "Bún Bò Huế Special",
  "description": "Phiên bản đặc biệt",
  "price": 85000,
  "category": 1,
  "imageUrl": "https://example.com/new.jpg",
  "isAvailable": true
}
```
**Response `200 OK`:** `MenuItemResponse`  
**Lỗi:** `400`, `404`

---

### `DELETE /api/menu/{id}`
Xóa món khỏi menu (chỉ được xóa nếu món chưa từng có trong order nào).

**Auth:** 🔒 Admin (role 1)  
**Path Params:** `id`  
**Response `204 No Content`**  
**Lỗi:**
- `404` — Không tìm thấy
- `409` — Món đã tồn tại trong order, dùng `toggle-availability` để ẩn thay thế

---

### `PATCH /api/menu/{id}/toggle-availability`
Bật/tắt trạng thái hiển thị của món (ẩn hoặc hiện).

**Auth:** 🔒 Admin (role 1) hoặc Staff (role 2)  
**Path Params:** `id`  
**Request Body:** _(Không cần body)_  
**Response `200 OK`:** `MenuItemResponse` với `isAvailable` đã được đảo ngược

---

## 🪑 Tables API — `/api/tables`

### Enum `TableStatus`

| Giá trị | Tên |
|---------|-----|
| `1` | Available |
| `2` | Occupied |
| `3` | Reserved |

### Schema `TableResponse`
```json
{
  "tableId": 3,
  "capacity": 4,
  "status": 1,
  "statusLabel": "Available",
  "createdAt": "2025-01-01T00:00:00Z"
}
```

---

### `GET /api/tables`
Lấy danh sách tất cả bàn.

**Auth:** 🔒 Admin (role 1)  
**Response `200 OK`:** `TableResponse[]`

---

### `GET /api/tables/{id}`
Lấy chi tiết một bàn.

**Auth:** 🔒 Admin (role 1)  
**Response `200 OK`:** `TableResponse`  
**Lỗi:** `404`

---

### `POST /api/tables`
Tạo bàn mới. Trạng thái ban đầu = `1` (Available).

**Auth:** 🔒 Admin (role 1)  
**Request Body:**
```json
{
  "capacity": 4
}
```
**Response `201 Created`:** `TableResponse`  
**Lỗi:** `400` — Capacity ≤ 0

---

### `PUT /api/tables/{id}`
Cập nhật sức chứa và trạng thái bàn.

**Auth:** 🔒 Admin (role 1)  
**Request Body:**
```json
{
  "capacity": 6,
  "status": 3
}
```
**Response `200 OK`:** `TableResponse`  
**Lỗi:** `400`, `404`

---

### `DELETE /api/tables/{id}`
Xóa bàn (chỉ khi không có order đang active).

**Auth:** 🔒 Admin (role 1)  
**Response `204 No Content`**  
**Lỗi:**
- `404` — Không tìm thấy
- `409` — Bàn đang có order active

---

### `GET /api/tables/{id}/qrcode`
Tải QR code PNG của bàn. QR encode URL dạng:  
`{AppBaseUrl}/order?tableId={id}`

**Auth:** 🔒 Admin (role 1)  
**Response:** File `image/png` — `table_{id}_qrcode.png`

---

## 📋 Orders API — `/api/orders`

### Enum `OrderStatus`

| Giá trị | Tên | Mô tả |
|---------|-----|-------|
| `1` | Pending | Khách vừa đặt, chờ xác nhận |
| `2` | Confirmed | Staff đã xác nhận |
| `3` | Serving | Đang phục vụ |
| `4` | Completed | Hoàn thành, thanh toán xong |
| `5` | Cancelled | Đã hủy |

### Schema `OrderResponse`
```json
{
  "orderId": 10,
  "tableId": 3,
  "status": 1,
  "statusLabel": "Pending",
  "totalAmount": 150000.00,
  "note": "Ít đường",
  "createdAt": "2025-01-01T06:30:00Z",
  "updatedAt": null,
  "items": [
    {
      "orderItemId": 21,
      "menuItemId": 1,
      "menuItemName": "Phở Bò",
      "quantity": 2,
      "unitPrice": 65000.00,
      "note": "Không hành"
    }
  ]
}
```

---

### `POST /api/orders`
Tạo order mới cho bàn. Dùng khi **khách quét QR và đặt món**.

**Auth:** ❌ Không cần  
**Ghi chú:**
- Giá được lấy từ DB (server-side), không tin giá gửi từ client.
- Bàn tự động chuyển sang trạng thái `Occupied (2)`.
- Sau khi tạo, event **`OrderCreated`** được phát qua SignalR đến tất cả Staff.

**Request Body:**
```json
{
  "tableId": 3,
  "note": "Bàn sinh nhật",
  "items": [
    {
      "menuItemId": 1,
      "quantity": 2,
      "note": "Không hành"
    },
    {
      "menuItemId": 5,
      "quantity": 1,
      "note": null
    }
  ]
}
```
**Response `201 Created`:** `OrderResponse`  
**Lỗi:**
- `400` — Không có items, hoặc món không tồn tại/không available, hoặc số lượng ≤ 0
- `404` — Không tìm thấy bàn

---

### `POST /api/orders/{id}/items`
Thêm món vào **order đang mở**. Dùng khi **khách gọi thêm món**.

**Auth:** ❌ Không cần  
**Path Params:** `id` — OrderId  
**Ghi chú:**
- Không thể thêm vào order đã Completed hoặc Cancelled (status ≥ 4).
- `TotalAmount` được cộng thêm tự động.
- Event **`OrderUpdated`** phát qua SignalR.

**Request Body:**
```json
{
  "items": [
    {
      "menuItemId": 3,
      "quantity": 1,
      "note": "Thêm đá"
    }
  ]
}
```
**Response `200 OK`:** `OrderResponse` (cập nhật)  
**Lỗi:** `400`, `404`, `409`

---

### `GET /api/orders`
Lấy danh sách tất cả order, có thể lọc theo status.

**Auth:** 🔒 Admin (role 1) hoặc Staff (role 2)  
**Query Params:**
- `status` _(optional)_ — Lọc theo OrderStatus (1–5)

**Ví dụ:** `GET /api/orders?status=1` — Lấy tất cả order đang Pending

**Response `200 OK`:** `OrderResponse[]` — Sắp xếp mới nhất trước

---

### `GET /api/orders/{id}`
Lấy chi tiết một order.

**Auth:** 🔒 Admin (role 1) hoặc Staff (role 2)  
**Response `200 OK`:** `OrderResponse`  
**Lỗi:** `404`

---

### `GET /api/orders/table/{tableId}`
Lấy các order **đang active** (status < 4) của một bàn.  
Dùng để khách xem lại đơn hiện tại của bàn mình.

**Auth:** ❌ Không cần  
**Path Params:** `tableId`  
**Response `200 OK`:** `OrderResponse[]`

---

### `PATCH /api/orders/{id}/status`
Cập nhật trạng thái order.

**Auth:** 🔒 Admin (role 1) hoặc Staff (role 2)  
**Path Params:** `id` — OrderId  
**Ghi chú:**
- Khi order chuyển sang `Completed (4)` hoặc `Cancelled (5)`, nếu bàn không còn order active nào → bàn tự động chuyển về `Available (1)`.
- AccountId của Staff/Admin xử lý được lưu vào `handledBy`.
- Event **`OrderStatusUpdated`** phát qua SignalR.

**Request Body:**
```json
{
  "status": 2
}
```
**Response `200 OK`:** `OrderResponse`  
**Lỗi:**
- `400` — Status ngoài khoảng 1–5
- `404` — Không tìm thấy order

---

## 📡 SignalR — Realtime Notifications

**Hub URL:** `/hubs/staff`  
**Auth:** 🔒 Yêu cầu JWT token (Admin hoặc Staff)

### Cách kết nối (JavaScript/Flutter)

```javascript
// JavaScript (SignalR client)
const connection = new signalR.HubConnectionBuilder()
  .withUrl("https://qr-order-api.onrender.com/hubs/staff", {
    accessTokenFactory: () => "YOUR_JWT_TOKEN_HERE"
  })
  .withAutomaticReconnect()
  .build();

connection.on("OrderCreated", (order) => {
  console.log("Đơn mới:", order);
});

connection.on("OrderUpdated", (order) => {
  console.log("Đơn cập nhật:", order);
});

connection.on("OrderStatusUpdated", (order) => {
  console.log("Trạng thái đơn:", order);
});

await connection.start();
```

> **Lưu ý:** JWT token cho SignalR có thể gửi qua query string `?access_token=<token>` thay vì header (đã được cấu hình phía server).

### Các sự kiện (Events)

| Event | Trigger | Data |
|-------|---------|------|
| `OrderCreated` | Khách đặt order mới | `OrderResponse` |
| `OrderUpdated` | Khách gọi thêm món | `OrderResponse` |
| `OrderStatusUpdated` | Staff đổi trạng thái | `OrderResponse` |

---

## 📌 Tổng hợp quyền truy cập

| API | Public | Customer (0) | Staff (2) | Admin (1) |
|-----|--------|-------------|-----------|-----------|
| `POST /auth/login` | ✅ | ✅ | ✅ | ✅ |
| `POST /auth/register` | ✅ | ✅ | ✅ | ✅ |
| `GET /auth/staff` | ❌ | ❌ | ❌ | ✅ |
| `POST /auth/admin-create` | ❌ | ❌ | ❌ | ✅ |
| `PUT /auth/accounts/{id}` | ❌ | ❌ | ✅ (own) | ✅ |
| `DELETE /auth/accounts/{id}` | ❌ | ❌ | ❌ | ✅ |
| `GET /menu` | ✅ | ✅ | ✅ | ✅ |
| `GET /menu/all` | ❌ | ❌ | ❌ | ✅ |
| `GET /menu/{id}` | ✅ | ✅ | ✅ | ✅ |
| `POST /menu` | ❌ | ❌ | ❌ | ✅ |
| `PUT /menu/{id}` | ❌ | ❌ | ❌ | ✅ |
| `DELETE /menu/{id}` | ❌ | ❌ | ❌ | ✅ |
| `PATCH /menu/{id}/toggle-availability` | ❌ | ❌ | ✅ | ✅ |
| `GET /tables` | ❌ | ❌ | ❌ | ✅ |
| `POST /tables` | ❌ | ❌ | ❌ | ✅ |
| `PUT /tables/{id}` | ❌ | ❌ | ❌ | ✅ |
| `DELETE /tables/{id}` | ❌ | ❌ | ❌ | ✅ |
| `GET /tables/{id}/qrcode` | ❌ | ❌ | ❌ | ✅ |
| `POST /orders` | ✅ | ✅ | ✅ | ✅ |
| `POST /orders/{id}/items` | ✅ | ✅ | ✅ | ✅ |
| `GET /orders` | ❌ | ❌ | ✅ | ✅ |
| `GET /orders/{id}` | ❌ | ❌ | ✅ | ✅ |
| `GET /orders/table/{tableId}` | ✅ | ✅ | ✅ | ✅ |
| `PATCH /orders/{id}/status` | ❌ | ❌ | ✅ | ✅ |
| SignalR `/hubs/staff` | ❌ | ❌ | ✅ | ✅ |

---

## 🔄 Luồng hoạt động điển hình

### Khách quét QR đặt món
```
1. Khách quét QR bàn → App đọc được tableId từ URL
2. GET /api/menu                     → Hiển thị menu (chỉ món available)
3. POST /api/orders                  → Đặt món (kèm tableId + items)
4. ← Server phát SignalR "OrderCreated" → Staff nhận thông báo
5. GET /api/orders/table/{tableId}   → Khách xem lại đơn của mình
6. POST /api/orders/{id}/items       → Khách gọi thêm món
7. ← Server phát SignalR "OrderUpdated" → Staff nhận thông báo
```

### Staff xử lý đơn
```
1. Staff đăng nhập → POST /api/auth/login → nhận JWT token
2. Kết nối SignalR /hubs/staff với token
3. Nhận event "OrderCreated" khi có đơn mới
4. GET /api/orders?status=1          → Xem danh sách đơn Pending
5. PATCH /api/orders/{id}/status     → Chuyển trạng thái (Confirmed → Serving → Completed)
6. ← Server phát SignalR "OrderStatusUpdated" → Staff khác cũng nhận
7. Khi order Completed → bàn tự động về Available
```

### Admin quản lý hệ thống
```
1. Admin đăng nhập → POST /api/auth/login
2. GET /api/menu/all                 → Xem toàn bộ menu
3. POST /api/menu                    → Thêm món mới
4. PATCH /api/menu/{id}/toggle-availability → Ẩn/hiện món
5. GET /api/tables                   → Xem danh sách bàn
6. GET /api/tables/{id}/qrcode       → Tải QR code bàn
7. POST /api/auth/admin-create       → Tạo tài khoản Staff
```

---

*Tài liệu được tạo tự động từ source code — cập nhật lần cuối: 2026-06-15*
