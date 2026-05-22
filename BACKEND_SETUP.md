# Hướng Dẫn Thiết Lập C# Backend API & Cơ Sở Dữ Liệu

Tài liệu này hướng dẫn chi tiết cách thiết lập một dự án **C# ASP.NET Core Web API** sử dụng **Entity Framework Core** để kết nối và lưu trữ cơ sở dữ liệu (SQLite, SQL Server...) đồng bộ 100% với ứng dụng gọi món Flutter.

---

## 1. Khởi Tạo Dự Án C# Web API

Truy cập Command Prompt / Terminal trên máy tính của bạn và chạy chuỗi lệnh sau:

```bash
# Tạo thư mục của backend
mkdir AromaBistro.Backend
cd AromaBistro.Backend

# Khởi tạo dự án Web API .NET 8.0/9.0
dotnet new webapi

# Cài đặt các thư viện cần thiết cho Cấu hình Cơ sở dữ liệu và EF Core
dotnet add package Microsoft.EntityFrameworkCore.Sqlite
dotnet add package Microsoft.EntityFrameworkCore.Design
```

---

## 2. Các Model Khớp Định Dạng (Entity Models)

Tạo thư mục `Models/` và viết các file sau để khớp với cấu trúc thực đơn, giỏ hàng và sơ đồ bàn của Flutter:

### `Models/MenuItem.cs` (Món ăn)
```csharp
using System.ComponentModel.DataAnnotations;

namespace AromaBistro.Backend.Models
{
    public class MenuItem
    {
        [Key]
        public string Id { get; set; } = string.Empty;
        public string Name { get; set; } = string.Empty;
        public string VietnameseName { get; set; } = string.Empty;
        public double Price { get; set; }
        public string Description { get; set; } = string.Empty;
        public string Emoji { get; set; } = "☕";
        public string Category { get; set; } = "Coffees";
        public bool IsAvailable { get; set; } = true;
    }
}
```

### `Models/TableModel.cs` (Sơ đồ phòng bàn)
```csharp
using System.ComponentModel.DataAnnotations;

namespace AromaBistro.Backend.Models
{
    public class TableModel
    {
        [Key]
        public string Id { get; set; } = string.Empty;
        public string Label { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public string Status { get; set; } = "Empty"; // Empty, Active, Paid
    }
}
```

### `Models/CartItem.cs` (Chi tiết lượt chọn món)
```csharp
namespace AromaBistro.Backend.Models
{
    public class CartItem
    {
        public string Id { get; set; } = Guid.NewGuid().ToString();
        public string OrderId { get; set; } = string.Empty;
        public MenuItem MenuItem { get; set; } = null!;
        public int Quantity { get; set; } = 1;
        public string Note { get; set; } = string.Empty;
    }
}
```

### `Models/OrderModel.cs` (Đơn hàng lưu kho)
```csharp
using System.ComponentModel.DataAnnotations;

namespace AromaBistro.Backend.Models
{
    public class OrderModel
    {
        [Key]
        public string Id { get; set; } = string.Empty;
        public string TableId { get; set; } = string.Empty;
        public string TableLabel { get; set; } = string.Empty;
        public List<CartItem> Items { get; set; } = new();
        public string Status { get; set; } = "pending"; // pending, preparing, ready, paid
        public int TimeMinutes { get; set; } = 0;
        public string Timestamp { get; set; } = DateTime.Now.ToString("HH:mm");
        public string Note { get; set; } = string.Empty;
    }
}
```

---

## 3. Lớp Cấu Hình CSDL `DbContext`

Tạo file `Data/AppDbContext.cs` để khởi chạy các bảng cơ sở dữ liệu Sqlite/SQL:

```csharp
using Microsoft.EntityFrameworkCore;
using AromaBistro.Backend.Models;

namespace AromaBistro.Backend.Data
{
    public class AppDbContext : DbContext
    {
        public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

        public DbSet<MenuItem> MenuItems => Set<MenuItem>();
        public DbSet<TableModel> Tables => Set<TableModel>();
        public DbSet<OrderModel> Orders => Set<OrderModel>();
        public DbSet<CartItem> CartItems => Set<CartItem>();

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);
            
            // Seed dữ liệu mẫu (Khởi tạo sẵn như Flutter)
            modelBuilder.Entity<MenuItem>().HasData(
                new MenuItem { Id = "m1", Name = "Butter Croissant", VietnameseName = "Bánh Sừng Bò Pháp", Price = 4.50, Description = "Bánh sừng bò ngập hương bơ Pháp, giòn rụm thơm ngon nướng vàng ươm mỗi sáng.", Emoji = "🥐", Category = "Pastries", IsAvailable = true },
                new MenuItem { Id = "m2", Name = "Avocado Toast", VietnameseName = "Bánh Mì Trái Bơ", Price = 12.00, Description = "Bánh mì lát nướng giòn rải bơ tươi nhuyễn, cà chua bi và hạt chia hữu cơ.", Emoji = "🥑", Category = "Brunch", IsAvailable = true },
                new MenuItem { Id = "m3", Name = "Matcha Latte", VietnameseName = "Trà Xanh Nhật Matcha", Price = 5.75, Description = "Trà xanh matcha Nhật Bản thượng hạng đánh mịn cùng sữa hạt organic thơm béo.", Emoji = "🍵", Category = "Teas", IsAvailable = true },
                new MenuItem { Id = "m5", Name = "Espresso Doppio", VietnameseName = "Cà Phê Espresso Đôi", Price = 3.50, Description = "Cà phê pha máy Espresso Doppio đậm đà nguyên bản từ hạt Arabica Cầu Đất tinh tế.", Emoji = "☕", Category = "Coffees", IsAvailable = true }
            );

            modelBuilder.Entity<TableModel>().HasData(
                new TableModel { Id = "03", Label = "Bàn #03", Description = "Khu vực ấm cúng trong nhà", Status = "Empty" },
                new TableModel { Id = "08", Label = "Bàn #08", Description = "Cạnh cửa sổ ngắm phố xá", Status = "Active" },
                new TableModel { Id = "12", Label = "Bàn #12", Description = "Ban công gió mát lộng lẫy", Status = "Empty" }
            );
        }
    }
}
```

---

## 4. Các API Controllers Thực Chế

Tạo thư mục `Controllers/` và viết các API sau:

### Thực Đơn API: `Controllers/MenuController.cs`
```csharp
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using AromaBistro.Backend.Data;
using AromaBistro.Backend.Models;

namespace AromaBistro.Backend.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class MenuController : ControllerBase
    {
        private readonly AppDbContext _context;
        public MenuController(AppDbContext context) => _context = context;

        [HttpGet]
        public async Task<ActionResult<IEnumerable<MenuItem>>> GetMenu()
        {
            return await _context.MenuItems.ToListAsync();
        }

        [HttpPost]
        public async Task<ActionResult<MenuItem>> AddItem(MenuItem item)
        {
            _context.MenuItems.Add(item);
            await _context.SaveChangesAsync();
            return Ok(item);
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateItem(string id, MenuItem updated)
        {
            if (id != updated.Id) return BadRequest();
            _context.Entry(updated).State = EntityState.Modified;
            await _context.SaveChangesAsync();
            return NoContent();
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteItem(string id)
        {
            var item = await _context.MenuItems.FindAsync(id);
            if (item == null) return NotFound();
            _context.MenuItems.Remove(item);
            await _context.SaveChangesAsync();
            return NoContent();
        }

        [HttpPatch("{id}/toggle-availability")]
        public async Task<IActionResult> ToggleAvailability(string id)
        {
            var item = await _context.MenuItems.FindAsync(id);
            if (item == null) return NotFound();
            item.IsAvailable = !item.IsAvailable;
            await _context.SaveChangesAsync();
            return Ok(item);
        }
    }
}
```

### Đơn Hàng API: `Controllers/OrdersController.cs`
```csharp
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using AromaBistro.Backend.Data;
using AromaBistro.Backend.Models;

namespace AromaBistro.Backend.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class OrdersController : ControllerBase
    {
        private readonly AppDbContext _context;
        public OrdersController(AppDbContext context) => _context = context;

        [HttpGet]
        public async Task<ActionResult<IEnumerable<OrderModel>>> GetOrders()
        {
            return await _context.Orders
                .Include(o => o.Items)
                .ThenInclude(i => i.MenuItem)
                .ToListAsync();
        }

        [HttpPost]
        public async Task<ActionResult<OrderModel>> CreateOrder(OrderModel order)
        {
            // Tránh EF tạo lại đè ghi đè MenuItem có sẵn
            foreach (var item in order.Items)
            {
                _context.Entry(item.MenuItem).State = EntityState.Unchanged;
            }

            _context.Orders.Add(order);
            await _context.SaveChangesAsync();
            return Ok(order);
        }

        [HttpPut("{id}/status")]
        public async Task<IActionResult> UpdateStatus(string id, [FromBody] StatusUpdateDto dto)
        {
            var order = await _context.Orders.FindAsync(id);
            if (order == null) return NotFound();
            order.Status = dto.Status;
            await _context.SaveChangesAsync();
            return NoContent();
        }
    }

    public class StatusUpdateDto
    {
        public string Status { get; set; } = "pending";
    }
}
```

### Phòng Bàn API: `Controllers/TablesController.cs`
```csharp
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using AromaBistro.Backend.Data;
using AromaBistro.Backend.Models;

namespace AromaBistro.Backend.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class TablesController : ControllerBase
    {
        private readonly AppDbContext _context;
        public TablesController(AppDbContext context) => _context = context;

        [HttpGet]
        public async Task<ActionResult<IEnumerable<TableModel>>> GetTables()
        {
            return await _context.Tables.ToListAsync();
        }
    }
}
```

---

## 5. Khai Báo CORS và Khởi Chạy Server (`Program.cs`)

Cực kỳ quan trọng để cho phép ứng dụng Flutter truy cập API từ các cổng cục bộ/giả lập mà không bị chặn bảo mật (CORS):

```csharp
using Microsoft.EntityFrameworkCore;
using AromaBistro.Backend.Data;

var builder = WebApplication.CreateBuilder(args);

// 1. Cấu hình EF Core SQLite (hoặc SQL Server)
builder.Services.AddDbContext<AppDbContext>(opt =>
    opt.UseSqlite("Data Source=aromabistro.db"));

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();

// 2. Chấp thuận cổng kết nối cho Flutter Web và Android Emulator/iOS (CORS)
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyHeader()
              .AllowAnyMethod();
    });
});

var app = builder.Build();

// Khởi tạo DB tự động khi Server chạy
using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
    db.Database.EnsureCreated();
}

app.UseCors("AllowAll");
app.UseAuthorization();
app.MapControllers();

// Khởi chạy server trên cổng 5000 hoặc HTTPS 5001
app.Run("http://0.0.0.0:5000");
```

---

## 6. Chạy Thử Nghiệm

Chạy lệnh sau tại thư mục dự án C# để khởi chạy cơ sở dữ liệu:

```bash
dotnet run
```

Sau khi server chạy, ứng dụng Flutter của bạn đã sẵn sàng kết nối trực tiếp đến http://10.0.2.2:5000 (cho Android Emulator) hoặc IP mạng LAN của bạn thông qua nút cấu hình **KẾT NỐI SERVER C# API** ngoài màn hình chính của ứng dụng.
