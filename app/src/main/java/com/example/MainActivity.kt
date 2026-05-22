package com.example

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.animation.*
import androidx.compose.animation.core.*
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.ui.draw.scale
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material.icons.outlined.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.rotate
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.window.Dialog
import com.example.ui.theme.*
import java.text.NumberFormat
import java.util.Locale
import kotlin.math.absoluteValue

// ==========================================
// DATA MODELS
// ==========================================

enum class AppTab {
    Customer, Staff, SystemDoc
}

enum class UserRole {
    UNDECIDED, CUSTOMER, STAFF
}

@Composable
fun UserRoleSelectionScreen(onRoleSelected: (UserRole) -> Unit) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(CoffeeBackground)
            .padding(24.dp),
        verticalArrangement = Arrangement.Center,
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        // Beautiful Logo Header
        Box(
            modifier = Modifier
                .size(96.dp)
                .clip(RoundedCornerShape(24.dp))
                .background(CoffeePrimary),
            contentAlignment = Alignment.Center
        ) {
            Text("☕", fontSize = 48.sp)
        }
        
        Spacer(modifier = Modifier.height(16.dp))
        
        Text(
            text = "AROMA BISTRO",
            fontSize = 28.sp,
            fontWeight = FontWeight.ExtraBold,
            color = CoffeePrimary,
            fontFamily = FontFamily.Serif
        )
        
        Text(
            text = "Hệ thống Gọi món QR Code & Quản lý Realtime",
            fontSize = 14.sp,
            color = CoffeeTextSub,
            textAlign = TextAlign.Center,
            fontWeight = FontWeight.Medium,
            modifier = Modifier.padding(horizontal = 8.dp)
        )
        
        Spacer(modifier = Modifier.height(40.dp))
        
        Text(
            text = "VUI LÒNG CHỌN VAI TRÒ TRUY CẬP",
            fontSize = 12.sp,
            fontWeight = FontWeight.Bold,
            color = CoffeeGold,
            letterSpacing = 1.5.sp
        )
        
        Spacer(modifier = Modifier.height(16.dp))
        
        // 1. Customer Option Card
        Card(
            modifier = Modifier
                .fillMaxWidth()
                .clickable { onRoleSelected(UserRole.CUSTOMER) },
            shape = RoundedCornerShape(20.dp),
            colors = CardDefaults.cardColors(
                containerColor = Color.White
            ),
            elevation = CardDefaults.cardElevation(defaultElevation = 2.dp),
            border = BorderStroke(1.dp, CoffeePrimary.copy(alpha = 0.15f))
        ) {
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(20.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Box(
                    modifier = Modifier
                        .size(56.dp)
                        .clip(RoundedCornerShape(16.dp))
                        .background(CoffeeSecondary),
                    contentAlignment = Alignment.Center
                ) {
                    Text("🍽️", fontSize = 28.sp)
                }
                
                Spacer(modifier = Modifier.width(16.dp))
                
                Column(modifier = Modifier.weight(1f)) {
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        Text(
                            text = "Khách Hàng",
                            fontSize = 18.sp,
                            fontWeight = FontWeight.Bold,
                            color = CoffeeTextDark
                        )
                        Box(
                            modifier = Modifier
                                .clip(RoundedCornerShape(6.dp))
                                .background(CoffeePrimary.copy(alpha = 0.15f))
                                .padding(horizontal = 6.dp, vertical = 2.dp)
                        ) {
                            Text(
                                "QUÉT QR",
                                fontSize = 9.sp,
                                fontWeight = FontWeight.Bold,
                                color = CoffeePrimary
                            )
                        }
                    }
                    Spacer(modifier = Modifier.height(4.dp))
                    Text(
                        text = "Quét mã QR tại bàn để xem menu thực đơn & thực hiện gọi món trực tiếp mà không cần cài đặt phức tạp.",
                        fontSize = 12.sp,
                        color = CoffeeTextSub,
                        lineHeight = 16.sp
                    )
                }
            }
        }
        
        Spacer(modifier = Modifier.height(16.dp))
        
        // 2. Staff Option Card
        Card(
            modifier = Modifier
                .fillMaxWidth()
                .clickable { onRoleSelected(UserRole.STAFF) },
            shape = RoundedCornerShape(20.dp),
            colors = CardDefaults.cardColors(
                containerColor = CoffeeDarkAccent
            ),
            elevation = CardDefaults.cardElevation(defaultElevation = 4.dp)
        ) {
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(20.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Box(
                    modifier = Modifier
                        .size(56.dp)
                        .clip(RoundedCornerShape(16.dp))
                        .background(Color.White.copy(alpha = 0.12f)),
                    contentAlignment = Alignment.Center
                ) {
                    Text("💼", fontSize = 28.sp)
                }
                
                Spacer(modifier = Modifier.width(16.dp))
                
                Column(modifier = Modifier.weight(1f)) {
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        Text(
                            text = "Bếp / Nhân Viên",
                            fontSize = 18.sp,
                            fontWeight = FontWeight.Bold,
                            color = Color.White
                        )
                        Box(
                            modifier = Modifier
                                .clip(RoundedCornerShape(6.dp))
                                .background(CoffeeGold)
                                .padding(horizontal = 6.dp, vertical = 2.dp)
                        ) {
                            Text(
                                "QUẢN LÝ",
                                fontSize = 9.sp,
                                fontWeight = FontWeight.Bold,
                                color = CoffeeDarkAccent
                            )
                        }
                    }
                    Spacer(modifier = Modifier.height(4.dp))
                    Text(
                        text = "Nhận order tức thời, chế biến món ăn, cập nhật sơ đồ phòng bàn & kết xuất báo cáo bán hàng.",
                        fontSize = 12.sp,
                        color = Color.White.copy(alpha = 0.7f),
                        lineHeight = 16.sp
                    )
                }
            }
        }
        
        Spacer(modifier = Modifier.height(40.dp))
        
        // Tech stack footer
        Card(
            colors = CardDefaults.cardColors(containerColor = CoffeeSecondary.copy(alpha = 0.4f)),
            shape = RoundedCornerShape(12.dp),
            modifier = Modifier.fillMaxWidth()
        ) {
            Column(
                modifier = Modifier.padding(14.dp),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                Text(
                    text = "💻 KIẾN TRÚC HỆ THỐNG PHÁT TRIỂN",
                    fontSize = 11.sp,
                    fontWeight = FontWeight.Bold,
                    color = CoffeePrimary,
                    letterSpacing = 0.5.sp
                )
                Spacer(modifier = Modifier.height(4.dp))
                Text(
                    text = "ASP.NET Core Web API • Entity Framework • SQLite\nHệ thống đồng bộ SignalR truyền tải trạng thái chế biến",
                    fontSize = 11.sp,
                    color = CoffeeTextSub,
                    textAlign = TextAlign.Center,
                    lineHeight = 15.sp
                )
            }
        }
    }
}

enum class OrderStatus(val label: String, val vietnamese: String, val color: Color, val step: Int) {
    PENDING("Pending", "Chờ xác nhận", Color(0xFFEF8C2E), 1),
    PREPARING("Preparing", "Đang chế biến", Color(0xFF1E88E5), 2),
    DONE("Ready", "Hoàn thành món", Color(0xFF4CAF50), 3),
    PAID("Paid", "Đã thanh toán", Color(0xFF7E5700), 4)
}

data class MenuItem(
    val id: String,
    val name: String,
    val vietnameseName: String,
    val price: Double, // in USD
    val description: String,
    val emoji: String,
    val category: String,
    val isAvailable: Boolean = true
)

data class Table(
    val id: String,
    val label: String,
    val description: String,
    val status: String // "Empty", "Active", "Paid"
)

data class CartItem(
    val menuItem: MenuItem,
    var quantity: Int,
    val note: String = ""
)

data class Order(
    val id: String,
    val tableId: String,
    val items: List<CartItem>,
    val status: OrderStatus,
    val timeMinutes: Int = 0,
    val timestamp: String = "12:34",
    val note: String = "",
    val tableLabel: String = "Bàn 08"
)

// ==========================================
// CORE SEED DATA
// ==========================================

val InitialMenuItems = listOf(
    MenuItem("m1", "Butter Croissant", "Bánh Sừng Bò Pháp", 4.50, "Bánh sừng bò ngập hương bơ Pháp, giòn rụm thơm ngon nướng vàng ươm mỗi sáng.", "🥐", "Pastries"),
    MenuItem("m2", "Avocado Toast", "Bánh Mì Trái Bơ", 12.00, "Bánh mì lát nướng giòn rải bơ tươi nhuyễn, cà chua bi và hạt chia hữu cơ.", "🥑", "Brunch"),
    MenuItem("m3", "Matcha Latte", "Trà Xanh Nhật Matcha", 5.75, "Trà xanh matcha Nhật Bản thượng hạng đánh mịn cùng sữa hạt organic thơm béo.", "🍵", "Teas"),
    MenuItem("m4", "Quinoa Salmon Bowl", "Cơm Salmond Quinoa", 14.50, "Cá hồi áp chảo thơm lừng cùng quinoa đỏ, khoai lang nướng và cải xoăn hữu cơ.", "🥗", "Brunch"),
    MenuItem("m5", "Espresso Doppio", "Cà Phê Espresso Đôi", 3.50, "Cà phê pha máy Espresso Doppio đậm đà nguyên bản từ hạt Arabica Cầu Đất tinh tế.", "☕", "Coffees"),
    MenuItem("m6", "Fluffy Blueberry Pancake", "Bánh Kẹp Việt Quất", 9.75, "Bánh pancake xếp lớp xốp mềm tràn ngập quả việt quất tươi và si rô phong nguyên chất.", "🥞", "Pastries"),
    MenuItem("m7", "Egg Benedict", "Trứng Benedict Kiểu Anh", 13.00, "Trứng chần sánh dẻo, giăm bông hun khói và sốt bơ béo Hollandaise trên English muffin.", "🍳", "Brunch"),
    MenuItem("m8", "Peach Hibiscus Tea", "Trà Hibiscus Đào Hồng", 6.00, "Vị chua thanh mát lành từ hoa hồng đài hòa quyện trà đào ngào mật ong ngọt nhẹ.", "🍑", "Teas"),
    MenuItem("m9", "Cold Brew Tonic", "Cà Phê Lạnh Sủi Bọt", 6.50, "Cà phê ủ lạnh 18 tiếng rót cùng nước tonic cao cấp sảng khoái và lát chanh vàng tươi.", "🍹", "Coffees")
)

val SystemTables = listOf(
    Table("03", "Bàn #03", "Khu vực ấm cúng trong nhà", "Empty"),
    Table("08", "Bàn #08", "Cạnh cửa sổ ngắm phố xá", "Active"),
    Table("12", "Bàn #12", "Ban công gió mát lộng lẫy", "Empty"),
    Table("15", "Bàn #15", "Phòng VIP riêng tư sang trọng", "Empty")
)

// ==========================================
// MAIN ACTIVITY
// ==========================================

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            MyApplicationTheme(dynamicColor = false) {
                MainContainerScreen()
            }
        }
    }
}

@OptIn(ExperimentalAnimationApi::class)
@Composable
fun MainContainerScreen() {
    // App Dynamic States
    var userRole by remember { mutableStateOf(UserRole.UNDECIDED) }
    var selectedTableId by remember { mutableStateOf("08") } // Active table id
    var selectedTableLabel by remember { mutableStateOf("Bàn #08") }
    var qrScannedCode by remember { mutableStateOf<String?>("https://aromabistro.com/order?tableId=08") }
    var isQrScannerOpen by remember { mutableStateOf(false) }
    var searchQuery by remember { mutableStateOf("") }
    var activeCategory by remember { mutableStateOf("All") }

    // Dynamic Menu Items (Staff can toggle and check unavailability)
    var mutableMenuItems by remember { mutableStateOf(InitialMenuItems) }
    
    // Cart Data: MenuItem ID -> CartItem
    val cartState = remember { mutableStateMapOf<String, CartItem>() }
    
    // Track submitted orders
    val orderQueue = remember { mutableStateListOf<Order>() }
    var activeCustomerOrder by remember { mutableStateOf<Order?>(null) }
    var showCartSheet by remember { mutableStateOf(false) }
    var showOrderTrackerDialog by remember { mutableStateOf(false) }
    var customOrderNote by remember { mutableStateOf("") }

    // Seed initial active order for Table 08 to make it look active immediately
    LaunchedEffect(Unit) {
        if (orderQueue.isEmpty()) {
            val initialCart = listOf(
                CartItem(InitialMenuItems[1], 1, "Less spice"), // Avocado toast
                CartItem(InitialMenuItems[2], 1, "Extra ice")  // Matcha Latte
            )
            val demoOrder = Order(
                id = "OD-1024",
                tableId = "08",
                items = initialCart,
                status = OrderStatus.PREPARING,
                timeMinutes = 4,
                timestamp = "12:15",
                note = "Không đá, ít ngọt",
                tableLabel = "Bàn #08"
            )
            orderQueue.add(demoOrder)
            activeCustomerOrder = demoOrder
        }
    }

    // Auto update customer active order state if modified in the staff order queue (Simulates real-time SignalR hubs)
    LaunchedEffect(orderQueue.toList()) {
        val updatedSub = orderQueue.find { it.id == activeCustomerOrder?.id }
        if (updatedSub != null) {
            activeCustomerOrder = updatedSub
        }
    }

    // Role Gateway
    if (userRole == UserRole.UNDECIDED) {
        UserRoleSelectionScreen(onRoleSelected = { userRole = it })
        return
    }

    // Helper calculate totals
    val subtotal = cartState.values.sumOf { it.menuItem.price * it.quantity }
    val taxAndService = subtotal * 0.10 // 10% VAT & Service
    val totalAmount = subtotal + taxAndService

    Scaffold(
        modifier = Modifier.fillMaxSize(),
        containerColor = CoffeeBackground,
        bottomBar = {
            if (userRole == UserRole.CUSTOMER) {
                Column {
                    // Interactive Persistent Bottom Order Active Status Bar (From Design Mockup) Apply Aroma Bistro Style
                    activeCustomerOrder?.let { order ->
                        if (order.status != OrderStatus.PAID) {
                            AnimatedVisibility(
                                visible = true,
                                enter = slideInVertically(initialOffsetY = { it }) + fadeIn(),
                                exit = slideOutVertically(targetOffsetY = { it }) + fadeOut()
                            ) {
                                ActiveOrderBottomBar(
                                    order = order,
                                    totalBill = order.items.sumOf { it.menuItem.price * it.quantity } * 1.10,
                                    onClick = { showOrderTrackerDialog = true }
                                )
                            }
                        }
                    }
                }
            }
        }
    ) { innerPadding ->
        Box(
            modifier = Modifier
                .fillMaxSize()
                .padding(innerPadding)
        ) {
            if (userRole == UserRole.CUSTOMER) {
                CustomerMainScreen(
                    selectedTableId = selectedTableId,
                    selectedTableLabel = selectedTableLabel,
                    searchQuery = searchQuery,
                    onSearchChange = { searchQuery = it },
                    activeCategory = activeCategory,
                    onCategorySelect = { activeCategory = it },
                    menuItems = mutableMenuItems,
                    cartState = cartState,
                    onAddCart = { item ->
                        val current = cartState[item.id]
                        if (current != null) {
                            cartState[item.id] = current.copy(quantity = current.quantity + 1)
                        } else {
                            cartState[item.id] = CartItem(item, 1)
                        }
                    },
                    onRemoveCart = { item ->
                        val current = cartState[item.id]
                        if (current != null) {
                            if (current.quantity > 1) {
                                cartState[item.id] = current.copy(quantity = current.quantity - 1)
                            } else {
                                cartState.remove(item.id)
                            }
                        }
                    },
                    onOpenQrScanner = { isQrScannerOpen = true },
                    onCartClick = { showCartSheet = true },
                    subtotal = subtotal,
                    totalItemsCount = cartState.values.sumOf { it.quantity },
                    onBackToGateway = { userRole = UserRole.UNDECIDED }
                )
            } else {
                StaffDashboard(
                    orderQueue = orderQueue,
                    menuItems = mutableMenuItems,
                    onToggleAvailability = { id ->
                        mutableMenuItems = mutableMenuItems.map {
                            if (it.id == id) it.copy(isAvailable = !it.isAvailable) else it
                        }
                    },
                    onUpdateOrderStatus = { orderId, newStatus ->
                        val index = orderQueue.indexOfFirst { it.id == orderId }
                        if (index != -1) {
                            val original = orderQueue[index]
                            orderQueue[index] = original.copy(status = newStatus)
                        }
                    },
                    onCreateMenuItem = { newItem ->
                        mutableMenuItems = mutableMenuItems + newItem
                    },
                    onUpdateMenuItem = { updatedItem ->
                        mutableMenuItems = mutableMenuItems.map {
                            if (it.id == updatedItem.id) updatedItem else it
                        }
                        // Sync with local cart item if present
                        val inCart = cartState[updatedItem.id]
                        if (inCart != null) {
                            cartState[updatedItem.id] = inCart.copy(menuItem = updatedItem)
                        }
                    },
                    onDeleteMenuItem = { itemId ->
                        mutableMenuItems = mutableMenuItems.filter { it.id != itemId }
                        // Clear from active cart if deleted
                        cartState.remove(itemId)
                    },
                    onBackToGateway = { userRole = UserRole.UNDECIDED }
                )
            }

            // ==========================================
            // MOCK INTEGRATED POPUPS / FLOWS
            // ==========================================

            // 1. QR Code Simulation Screen
            if (isQrScannerOpen) {
                MockQrScannerDialog(
                    onClose = { isQrScannerOpen = false },
                    onScanned = { tableId, tableLabel ->
                        selectedTableId = tableId
                        selectedTableLabel = tableLabel
                        qrScannedCode = "https://aromabistro.com/order?tableId=$tableId"
                        isQrScannerOpen = false
                    }
                )
            }

            // 2. Shopping Cart Bottom Sheet (Dialog layout for safe-area & robustness)
            if (showCartSheet) {
                ShoppingCartDialog(
                    cartItems = cartState.values.toList(),
                    onClose = { showCartSheet = false },
                    onIncreaseQuantity = { item ->
                        cartState[item.id]?.let { current ->
                            cartState[item.id] = current.copy(quantity = current.quantity + 1)
                        }
                    },
                    onDecreaseQuantity = { item ->
                        cartState[item.id]?.let { current ->
                            if (current.quantity > 1) {
                                cartState[item.id] = current.copy(quantity = current.quantity - 1)
                            } else {
                                cartState.remove(item.id)
                            }
                        }
                    },
                    subtotal = subtotal,
                    taxAndService = taxAndService,
                    total = totalAmount,
                    selectedTableLabel = selectedTableLabel,
                    note = customOrderNote,
                    onNoteChange = { customOrderNote = it },
                    onCheckout = {
                        if (cartState.isNotEmpty()) {
                            val orderId = "B${selectedTableId}-" + (1000..9999).random()
                            val newOrder = Order(
                                id = orderId,
                                tableId = selectedTableId,
                                items = cartState.values.toList(),
                                status = OrderStatus.PENDING,
                                timeMinutes = 0,
                                timestamp = "Vừa xong",
                                note = customOrderNote,
                                tableLabel = selectedTableLabel
                            )
                            orderQueue.add(newOrder)
                            activeCustomerOrder = newOrder
                            cartState.clear()
                            customOrderNote = ""
                            showCartSheet = false
                            showOrderTrackerDialog = true
                        }
                    }
                )
            }

            // 3. Real-time Order Tracker Step Status Visualizer
            if (showOrderTrackerDialog) {
                activeCustomerOrder?.let { order ->
                    OrderTrackerDialog(
                        order = order,
                        onClose = { showOrderTrackerDialog = false },
                        onCancelOrder = {
                            orderQueue.removeIf { it.id == order.id }
                            activeCustomerOrder = null
                            showOrderTrackerDialog = false
                        }
                    )
                }
            }
        }
    }
}

// ==========================================
// CUSTOMER VIEW COMPONENTS
// ==========================================

@Composable
fun CustomerMainScreen(
    selectedTableId: String,
    selectedTableLabel: String,
    searchQuery: String,
    onSearchChange: (String) -> Unit,
    activeCategory: String,
    onCategorySelect: (String) -> Unit,
    menuItems: List<MenuItem>,
    cartState: Map<String, CartItem>,
    onAddCart: (MenuItem) -> Unit,
    onRemoveCart: (MenuItem) -> Unit,
    onOpenQrScanner: () -> Unit,
    onCartClick: () -> Unit,
    subtotal: Double,
    totalItemsCount: Int,
    onBackToGateway: () -> Unit
) {
    val categories = listOf("All", "Coffees", "Teas", "Pastries", "Brunch")

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(CoffeeBackground)
    ) {
        // High-fidelity Beautiful Header (Coffee Aroma style)
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 24.dp, vertical = 16.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.SpaceBetween
        ) {
            Row(
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(12.dp),
                modifier = Modifier.weight(1f)
            ) {
                Box(
                    modifier = Modifier
                        .size(44.dp)
                        .clip(RoundedCornerShape(14.dp))
                        .background(CoffeePrimary),
                    contentAlignment = Alignment.Center
                ) {
                    Text("☕", fontSize = 22.sp)
                }
                Column {
                    Text(
                        text = "Aroma Bistro",
                        fontSize = 18.sp,
                        fontWeight = FontWeight.Bold,
                        color = CoffeeTextDark,
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis
                    )
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(4.dp)
                    ) {
                        Box(
                            modifier = Modifier
                                .size(8.dp)
                                .clip(CircleShape)
                                .background(Color(0xFF4CAF50))
                        )
                        Text(
                            text = "Bàn: $selectedTableId",
                            fontSize = 11.sp,
                            color = CoffeeTextSub,
                            fontWeight = FontWeight.Medium
                        )
                    }
                }
            }

            // Row of Actions (QR Simulator + Back to Gateway Selection)
            Row(
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                IconButton(
                    onClick = onOpenQrScanner,
                    modifier = Modifier
                        .size(42.dp)
                        .clip(CircleShape)
                        .background(CoffeeSecondary)
                ) {
                    Icon(
                        imageVector = Icons.Default.QrCodeScanner,
                        contentDescription = "Quét lại bàn",
                        tint = CoffeePrimary,
                        modifier = Modifier.size(18.dp)
                    )
                }

                // Beautiful Switch Back to Gateway Role Selector Button
                Button(
                    onClick = onBackToGateway,
                    colors = ButtonDefaults.buttonColors(
                        containerColor = CoffeePrimary,
                        contentColor = Color.White
                    ),
                    shape = RoundedCornerShape(12.dp),
                    contentPadding = PaddingValues(horizontal = 10.dp, vertical = 2.dp),
                    modifier = Modifier.height(42.dp)
                ) {
                    Icon(
                        imageVector = Icons.Default.SwapHoriz,
                        contentDescription = "Chuyển vai",
                        tint = Color.White,
                        modifier = Modifier.size(16.dp)
                    )
                    Spacer(modifier = Modifier.width(4.dp))
                    Text("Đổi Vai", fontSize = 11.sp, fontWeight = FontWeight.Bold)
                }
            }
        }

        // Horizontal Category Filter Bar
        LazyRow(
            contentPadding = PaddingValues(horizontal = 24.dp, vertical = 6.dp),
            horizontalArrangement = Arrangement.spacedBy(8.dp),
            modifier = Modifier.fillMaxWidth()
        ) {
            items(categories) { category ->
                val isSelected = category == activeCategory
                Box(
                    modifier = Modifier
                        .clip(RoundedCornerShape(50.dp))
                        .background(if (isSelected) CoffeePrimary else CoffeeSecondary)
                        .clickable { onCategorySelect(category) }
                        .padding(horizontal = 20.dp, vertical = 10.dp)
                ) {
                    Text(
                        text = when(category) {
                            "All" -> "Tất cả menu"
                            "Coffees" -> "Cà phê ☕"
                            "Teas" -> "Trà hoa quả 🍵"
                            "Pastries" -> "Bánh ngọt 🥐"
                            "Brunch" -> "Điểm tâm 🥑"
                            else -> category
                        },
                        color = if (isSelected) Color.White else CoffeeTextSub,
                        fontSize = 13.sp,
                        fontWeight = FontWeight.Bold
                    )
                }
            }
        }

        // Styled Search bar
        OutlinedTextField(
            value = searchQuery,
            onValueChange = onSearchChange,
            placeholder = { Text("Tìm món ăn, đồ uống thơm phức...", color = Color.Gray, fontSize = 13.sp) },
            leadingIcon = { Icon(Icons.Default.Search, contentDescription = null, tint = CoffeePrimary) },
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 24.dp, vertical = 8.dp),
            shape = RoundedCornerShape(28.dp),
            singleLine = true,
            colors = OutlinedTextFieldDefaults.colors(
                focusedContainerColor = Color.White,
                unfocusedContainerColor = Color.White,
                focusedBorderColor = CoffeePrimary,
                unfocusedBorderColor = CoffeeCardBorder
            )
        )

        // Menu items listing - Responsive grid/column with premium visual styling
        val filteredItems = menuItems.filter {
            (activeCategory == "All" || it.category == activeCategory) &&
                    (it.name.contains(searchQuery, ignoreCase = true) || it.vietnameseName.contains(searchQuery, ignoreCase = true))
        }

        if (filteredItems.isEmpty()) {
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .weight(1f),
                contentAlignment = Alignment.Center
            ) {
                Column(
                    horizontalAlignment = Alignment.CenterHorizontally,
                    verticalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    Text("☕", fontSize = 48.sp)
                    Text("Món ăn không có sẵn!", color = CoffeeTextSub, fontSize = 14.sp)
                }
            }
        } else {
            LazyColumn(
                modifier = Modifier
                    .fillMaxWidth()
                    .weight(1f),
                contentPadding = PaddingValues(horizontal = 24.dp, vertical = 12.dp),
                verticalArrangement = Arrangement.spacedBy(16.dp)
            ) {
                items(filteredItems) { item ->
                    MenuListItem(
                        menuItem = item,
                        cartCount = cartState[item.id]?.quantity ?: 0,
                        onAdd = { onAddCart(item) },
                        onRemove = { onRemoveCart(item) }
                    )
                }
            }
        }

        // Cart Floating Bar inside Customer Tab (Sticky at the bottom if item added)
        if (totalItemsCount > 0) {
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 24.dp, vertical = 12.dp)
            ) {
                Button(
                    onClick = onCartClick,
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(56.dp)
                        .clip(RoundedCornerShape(16.dp)),
                    colors = ButtonDefaults.buttonColors(
                        containerColor = CoffeePrimary
                    ),
                    contentPadding = PaddingValues(horizontal = 20.dp)
                ) {
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.SpaceBetween
                    ) {
                        Row(
                            verticalAlignment = Alignment.CenterVertically,
                            horizontalArrangement = Arrangement.spacedBy(10.dp)
                        ) {
                            Box(
                                modifier = Modifier
                                    .size(28.dp)
                                    .clip(CircleShape)
                                    .background(CoffeeGold),
                                contentAlignment = Alignment.Center
                            ) {
                                Text(
                                    text = "$totalItemsCount",
                                    fontSize = 12.sp,
                                    fontWeight = FontWeight.Bold,
                                    color = CoffeePrimary
                                )
                            }
                            Text("Xem giỏ hàng của bạn", color = Color.White, fontWeight = FontWeight.Bold, fontSize = 15.sp)
                        }
                        Text(
                            text = String.format("$%.2f", subtotal),
                            color = CoffeeGold,
                            fontWeight = FontWeight.Bold,
                            fontSize = 16.sp
                        )
                    }
                }
            }
        }
    }
}

@Composable
fun MenuListItem(
    menuItem: MenuItem,
    cartCount: Int,
    onAdd: () -> Unit,
    onRemove: () -> Unit
) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .border(BorderStroke(1.dp, CoffeeCardBorder), RoundedCornerShape(24.dp)),
        colors = CardDefaults.cardColors(containerColor = Color.White),
        shape = RoundedCornerShape(24.dp),
        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp)
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(14.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(14.dp)
        ) {
            // Circle item Emoji Icon container
            Box(
                modifier = Modifier
                    .size(80.dp)
                    .clip(RoundedCornerShape(18.dp))
                    .background(CoffeeCardLightBg),
                contentAlignment = Alignment.Center
            ) {
                Text(menuItem.emoji, fontSize = 38.sp)
                if (!menuItem.isAvailable) {
                    Box(
                        modifier = Modifier
                            .fillMaxSize()
                            .background(Color.Black.copy(alpha = 0.6f)),
                        contentAlignment = Alignment.Center
                    ) {
                        Text(
                            text = "HẾT HÀNG",
                            color = Color.White,
                            fontSize = 10.sp,
                            fontWeight = FontWeight.Bold,
                            textAlign = TextAlign.Center
                        )
                    }
                }
            }

            // Description column
            Column(
                modifier = Modifier.weight(1f)
            ) {
                Text(
                    text = menuItem.name,
                    fontSize = 15.sp,
                    fontWeight = FontWeight.Bold,
                    color = CoffeeTextDark
                )
                Text(
                    text = menuItem.vietnameseName,
                    fontSize = 12.sp,
                    color = CoffeeTextSub,
                    fontWeight = FontWeight.Medium
                )
                Text(
                    text = menuItem.description,
                    fontSize = 11.sp,
                    color = Color.Gray,
                    maxLines = 2,
                    overflow = TextOverflow.Ellipsis,
                    lineHeight = 14.sp,
                    modifier = Modifier.padding(top = 4.dp, bottom = 4.dp)
                )
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    Text(
                        text = String.format("$%.2f", menuItem.price),
                        color = CoffeePrimary,
                        fontWeight = FontWeight.Bold,
                        fontSize = 15.sp
                    )
                    Text(
                        text = String.format("(~%,.0fđ)", menuItem.price * 25000),
                        color = Color.Gray,
                        fontSize = 11.sp
                    )
                }
            }

            // Interactive dynamic adding button
            if (!menuItem.isAvailable) {
                Button(
                    onClick = {},
                    enabled = false,
                    shape = RoundedCornerShape(12.dp),
                    colors = ButtonDefaults.buttonColors(
                        disabledContainerColor = CoffeeSecondary,
                        disabledContentColor = Color.LightGray
                    ),
                    modifier = Modifier.height(38.dp)
                ) {
                    Text("Hết", fontSize = 12.sp)
                }
            } else if (cartCount == 0) {
                Button(
                    onClick = onAdd,
                    shape = RoundedCornerShape(14.dp),
                    colors = ButtonDefaults.buttonColors(
                        containerColor = CoffeeCardLightBg,
                        contentColor = CoffeePrimary
                    ),
                    modifier = Modifier
                        .height(36.dp)
                        .padding(horizontal = 4.dp)
                ) {
                    Text("+ THÊM", fontSize = 11.sp, fontWeight = FontWeight.Bold)
                }
            } else {
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(8.dp),
                    modifier = Modifier
                        .clip(RoundedCornerShape(14.dp))
                        .background(CoffeePrimary)
                        .padding(horizontal = 4.dp, vertical = 2.dp)
                ) {
                    IconButton(
                        onClick = onRemove,
                        modifier = Modifier.size(28.dp)
                    ) {
                        Icon(Icons.Default.Remove, contentDescription = "Trừ", tint = Color.White, modifier = Modifier.size(16.dp))
                    }
                    Text(
                        text = "$cartCount",
                        color = Color.White,
                        fontWeight = FontWeight.Bold,
                        fontSize = 13.sp
                    )
                    IconButton(
                        onClick = onAdd,
                        modifier = Modifier.size(28.dp)
                    ) {
                        Icon(Icons.Default.Add, contentDescription = "Cộng", tint = Color.White, modifier = Modifier.size(16.dp))
                    }
                }
            }
        }
    }
}

// Persistent bottom active tracker badge from visual mockup design theme
@Composable
fun ActiveOrderBottomBar(
    order: Order,
    totalBill: Double,
    onClick: () -> Unit
) {
    var rotationAngle by remember { mutableStateOf(0f) }
    val infiniteTransition = rememberInfiniteTransition()
    val angle by infiniteTransition.animateFloat(
        initialValue = 0f,
        targetValue = 360f,
        animationSpec = infiniteRepeatable(
            animation = tween(2000, easing = LinearEasing),
            repeatMode = RepeatMode.Restart
        )
    )

    Card(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 16.dp, vertical = 8.dp)
            .clickable { onClick() },
        colors = CardDefaults.cardColors(containerColor = CoffeeDarkAccent),
        shape = RoundedCornerShape(24.dp),
        elevation = CardDefaults.cardElevation(defaultElevation = 8.dp)
    ) {
        Column(
            modifier = Modifier.padding(14.dp)
        ) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(12.dp),
                    modifier = Modifier.weight(1f)
                ) {
                    Box(
                        modifier = Modifier
                            .size(36.dp)
                            .clip(CircleShape)
                            .background(CoffeeGold),
                        contentAlignment = Alignment.Center
                    ) {
                        Icon(
                            imageVector = Icons.Default.Autorenew,
                            contentDescription = "Xoay",
                            tint = CoffeePrimary,
                            modifier = Modifier
                                .size(20.dp)
                                .rotate(angle)
                        )
                    }
                    Column {
                        Row(
                            verticalAlignment = Alignment.CenterVertically,
                            horizontalArrangement = Arrangement.spacedBy(6.dp)
                        ) {
                            Text(
                                text = "Đơn ${order.id}",
                                fontSize = 11.sp,
                                fontWeight = FontWeight.Black,
                                color = CoffeeGold
                            )
                            Box(
                                modifier = Modifier
                                    .clip(RoundedCornerShape(4.dp))
                                    .background(order.status.color.copy(alpha = 0.2f))
                                    .padding(horizontal = 4.dp, vertical = 1.dp)
                            ) {
                                Text(
                                    text = order.status.vietnamese,
                                    fontSize = 9.sp,
                                    color = order.status.color,
                                    fontWeight = FontWeight.Bold
                                )
                            }
                        }
                        Text(
                            text = when(order.status) {
                                OrderStatus.PENDING -> "Chờ quán tiếp nhận..."
                                OrderStatus.PREPARING -> "Đang chế biến tươi ngon..."
                                OrderStatus.DONE -> "Món đã sẵn sàng! Chờ giao bàn."
                                OrderStatus.PAID -> "Đã thanh toán thành công!"
                            },
                            fontSize = 12.sp,
                            color = Color.White.copy(alpha = 0.9f)
                        )
                    }
                }
                
                // Active timing or table indicators
                Text(
                    text = order.tableLabel,
                    fontSize = 11.sp,
                    color = CoffeeGold,
                    fontWeight = FontWeight.Bold,
                    modifier = Modifier
                        .border(BorderStroke(1.dp, CoffeePrimary), RoundedCornerShape(12.dp))
                        .padding(horizontal = 10.dp, vertical = 4.dp)
                )
            }
            Spacer(modifier = Modifier.height(10.dp))
            Divider(color = Color.White.copy(alpha = 0.15f))
            Spacer(modifier = Modifier.height(10.dp))
            Row(
                modifier = Modifier.fillMaxWidth(),
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                Text(
                    text = "Bấm để chi tiết đơn hàng",
                    color = Color.White.copy(alpha = 0.5f),
                    fontSize = 11.sp,
                    fontWeight = FontWeight.Medium
                )
                Text(
                    text = String.format("$%.2f", totalBill),
                    color = Color.White,
                    fontSize = 15.sp,
                    fontWeight = FontWeight.Bold
                )
            }
        }
    }
}

// ==========================================
// DIALOGS & OVERLAYS
// ==========================================

@Composable
fun MockQrScannerDialog(
    onClose: () -> Unit,
    onScanned: (String, String) -> Unit
) {
    Dialog(onDismissRequest = onClose) {
        Card(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp),
            colors = CardDefaults.cardColors(containerColor = CoffeeBackground),
            shape = RoundedCornerShape(28.dp),
            border = BorderStroke(1.dp, CoffeeCardBorder)
        ) {
            Column(
                modifier = Modifier.padding(24.dp),
                horizontalAlignment = Alignment.CenterHorizontally,
                verticalArrangement = Arrangement.spacedBy(16.dp)
            ) {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text("Quét mã QR gọi món", fontSize = 16.sp, fontWeight = FontWeight.Bold, color = CoffeeTextDark)
                    IconButton(onClick = onClose) {
                        Icon(Icons.Default.Close, contentDescription = "Đóng")
                    }
                }

                // Decorative Camera/Scanner simulator window
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(180.dp)
                        .clip(RoundedCornerShape(20.dp))
                        .background(Color.Black),
                    contentAlignment = Alignment.Center
                ) {
                    // Scanning light animation mockup
                    val infiniteTransition = rememberInfiniteTransition()
                    val greenScannerY by infiniteTransition.animateFloat(
                        initialValue = -80f,
                        targetValue = 80f,
                        animationSpec = infiniteRepeatable(
                            animation = tween(1500, easing = LinearEasing),
                            repeatMode = RepeatMode.Reverse
                        )
                    )

                    Column(
                        horizontalAlignment = Alignment.CenterHorizontally,
                        verticalArrangement = Arrangement.Center
                    ) {
                        Icon(
                            imageVector = Icons.Default.QrCode,
                            contentDescription = null,
                            modifier = Modifier.size(72.dp),
                            tint = CoffeeGold
                        )
                        Spacer(modifier = Modifier.height(12.dp))
                        Text(
                            "MÔ PHỎNG CAMERA...",
                            fontSize = 11.sp,
                            fontWeight = FontWeight.Bold,
                            color = Color.White.copy(alpha = 0.6f)
                        )
                    }

                    // Green Scanner Line
                    Box(
                        modifier = Modifier
                            .fillMaxWidth()
                            .height(2.dp)
                            .offset(y = greenScannerY.dp)
                            .background(Brush.horizontalGradient(listOf(Color.Transparent, Color.Green, Color.Transparent)))
                    )
                }

                Text(
                    text = "Hãy chọn một Bàn để mô phỏng quét mã QR thành công:",
                    modifier = Modifier.fillMaxWidth(),
                    textAlign = TextAlign.Center,
                    fontSize = 12.sp,
                    color = CoffeeTextSub
                )

                // Render dynamic Tables simulation trigger action buttons
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    Button(
                        onClick = { onScanned("03", "Bàn #03") },
                        modifier = Modifier.weight(1f),
                        colors = ButtonDefaults.buttonColors(containerColor = CoffeePrimary),
                        shape = RoundedCornerShape(12.dp)
                    ) {
                        Text("Bàn #03", fontSize = 11.sp)
                    }
                    Button(
                        onClick = { onScanned("08", "Bàn #08") },
                        modifier = Modifier.weight(1f),
                        colors = ButtonDefaults.buttonColors(containerColor = CoffeePrimary),
                        shape = RoundedCornerShape(12.dp)
                    ) {
                        Text("Bàn #08", fontSize = 11.sp)
                    }
                }
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    Button(
                        onClick = { onScanned("12", "Bàn #12") },
                        modifier = Modifier.weight(1f),
                        colors = ButtonDefaults.buttonColors(containerColor = CoffeePrimary),
                        shape = RoundedCornerShape(12.dp)
                    ) {
                        Text("Bàn #12", fontSize = 11.sp)
                    }
                    Button(
                        onClick = { onScanned("15", "Bàn #15") },
                        modifier = Modifier.weight(1f),
                        colors = ButtonDefaults.buttonColors(containerColor = CoffeePrimary),
                        shape = RoundedCornerShape(12.dp)
                    ) {
                        Text("Bàn #15", fontSize = 11.sp)
                    }
                }
            }
        }
    }
}

@Composable
fun ShoppingCartDialog(
    cartItems: List<CartItem>,
    onClose: () -> Unit,
    onIncreaseQuantity: (MenuItem) -> Unit,
    onDecreaseQuantity: (MenuItem) -> Unit,
    subtotal: Double,
    taxAndService: Double,
    total: Double,
    selectedTableLabel: String,
    note: String,
    onNoteChange: (String) -> Unit,
    onCheckout: () -> Unit
) {
    Dialog(onDismissRequest = onClose) {
        Card(
            modifier = Modifier
                .fillMaxWidth()
                .fillMaxHeight(0.85f),
            shape = RoundedCornerShape(28.dp),
            colors = CardDefaults.cardColors(containerColor = CoffeeBackground),
            border = BorderStroke(1.dp, CoffeeCardBorder)
        ) {
            Column(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(20.dp)
            ) {
                // Header of Cart dialogue
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        Icon(Icons.Default.ShoppingCart, contentDescription = null, tint = CoffeePrimary)
                        Text(
                            text = "Giỏ Hàng [$selectedTableLabel]",
                            fontSize = 16.sp,
                            fontWeight = FontWeight.Bold,
                            color = CoffeeTextDark
                        )
                    }
                    IconButton(onClick = onClose) {
                        Icon(Icons.Default.Close, contentDescription = "Đóng")
                    }
                }

                Divider(color = CoffeeCardBorder, modifier = Modifier.padding(vertical = 12.dp))

                // Scrollable Item list
                if (cartItems.isEmpty()) {
                    Box(modifier = Modifier.weight(1f), contentAlignment = Alignment.Center) {
                        Text("Giỏ hàng của bạn đang trống trơn!", color = CoffeeTextSub, fontSize = 13.sp)
                    }
                } else {
                    LazyColumn(
                        modifier = Modifier.weight(1f),
                        verticalArrangement = Arrangement.spacedBy(12.dp)
                    ) {
                        items(cartItems) { item ->
                            Row(
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .clip(RoundedCornerShape(16.dp))
                                    .background(Color.White)
                                    .padding(12.dp),
                                verticalAlignment = Alignment.CenterVertically,
                                horizontalArrangement = Arrangement.spacedBy(10.dp)
                            ) {
                                Box(
                                    modifier = Modifier
                                        .size(44.dp)
                                        .clip(RoundedCornerShape(10.dp))
                                        .background(CoffeeCardLightBg),
                                    contentAlignment = Alignment.Center
                                ) {
                                    Text(item.menuItem.emoji, fontSize = 24.sp)
                                }
                                Column(modifier = Modifier.weight(1f)) {
                                    Text(item.menuItem.name, fontSize = 13.sp, fontWeight = FontWeight.Bold, color = CoffeeTextDark)
                                    Text(String.format("$%.2f", item.menuItem.price), fontSize = 11.sp, color = CoffeePrimary, fontWeight = FontWeight.Medium)
                                }

                                // Adder
                                Row(
                                    verticalAlignment = Alignment.CenterVertically,
                                    horizontalArrangement = Arrangement.spacedBy(6.dp),
                                    modifier = Modifier
                                        .clip(RoundedCornerShape(10.dp))
                                        .background(CoffeeSecondary)
                                        .padding(horizontal = 4.dp, vertical = 2.dp)
                                ) {
                                    IconButton(onClick = { onDecreaseQuantity(item.menuItem) }, modifier = Modifier.size(24.dp)) {
                                        Icon(Icons.Default.Remove, contentDescription = null, modifier = Modifier.size(14.dp))
                                    }
                                    Text("${item.quantity}", fontWeight = FontWeight.Bold, fontSize = 12.sp)
                                    IconButton(onClick = { onIncreaseQuantity(item.menuItem) }, modifier = Modifier.size(24.dp)) {
                                        Icon(Icons.Default.Add, contentDescription = null, modifier = Modifier.size(14.dp))
                                    }
                                }
                            }
                        }
                    }
                }

                // Custom requirements/Special instruction notes input
                Spacer(modifier = Modifier.height(10.dp))
                OutlinedTextField(
                    value = note,
                    onValueChange = onNoteChange,
                    placeholder = { Text("Ghi chú cho bếp (Ví dụ: ít ngọt, nhiều đá, chia 2 ly...)", fontSize = 12.sp) },
                    modifier = Modifier.fillMaxWidth(),
                    shape = RoundedCornerShape(12.dp),
                    colors = OutlinedTextFieldDefaults.colors(
                        focusedContainerColor = Color.White,
                        unfocusedContainerColor = Color.White,
                        focusedBorderColor = CoffeePrimary,
                        unfocusedBorderColor = CoffeeCardBorder
                    ),
                    maxLines = 2
                )

                Spacer(modifier = Modifier.height(12.dp))

                // Checkouts detailed calculations panel
                Column(
                    modifier = Modifier
                        .fillMaxWidth()
                        .clip(RoundedCornerShape(16.dp))
                        .background(CoffeeSecondary)
                        .padding(14.dp),
                    verticalArrangement = Arrangement.spacedBy(6.dp)
                ) {
                    Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                        Text("Tiền nước/món:", fontSize = 12.sp, color = CoffeeTextSub)
                        Text(String.format("$%.2f", subtotal), fontSize = 12.sp, color = CoffeeTextDark, fontWeight = FontWeight.Bold)
                    }
                    Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                        Text("Thuế VAT & Phí dịch vụ (10%):", fontSize = 12.sp, color = CoffeeTextSub)
                        Text(String.format("$%.2f", taxAndService), fontSize = 12.sp, color = CoffeeTextDark, fontWeight = FontWeight.Bold)
                    }
                    Divider(color = CoffeeCardBorder, modifier = Modifier.padding(vertical = 4.dp))
                    Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                        Text("Tổng thanh toán:", fontSize = 14.sp, fontWeight = FontWeight.Bold, color = CoffeeTextDark)
                        Text(String.format("$%.2f", total), fontSize = 15.sp, fontWeight = FontWeight.Black, color = CoffeePrimary)
                    }
                }

                Spacer(modifier = Modifier.height(16.dp))

                // Primary Submit Ordering Button
                Button(
                    onClick = onCheckout,
                    enabled = cartItems.isNotEmpty(),
                    colors = ButtonDefaults.buttonColors(containerColor = CoffeePrimary),
                    shape = RoundedCornerShape(16.dp),
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(52.dp)
                ) {
                    Text("GỬI ORDER ĐẾN BẾP REAL-TIME ✈️", fontSize = 13.sp, fontWeight = FontWeight.Bold, color = Color.White)
                }
            }
        }
    }
}

@Composable
fun OrderTrackerDialog(
    order: Order,
    onClose: () -> Unit,
    onCancelOrder: () -> Unit
) {
    Dialog(onDismissRequest = onClose) {
        Card(
            modifier = Modifier
                .fillMaxWidth()
                .padding(14.dp),
            shape = RoundedCornerShape(26.dp),
            colors = CardDefaults.cardColors(containerColor = CoffeeBackground),
            border = BorderStroke(1.dp, CoffeeCardBorder)
        ) {
            Column(
                modifier = Modifier.padding(20.dp),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                // Header
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Column {
                        Text("Theo Dõi Order Real-time", fontSize = 13.sp, color = CoffeeTextSub)
                        Text("Đơn #${order.id}", fontSize = 16.sp, fontWeight = FontWeight.Bold, color = CoffeeTextDark)
                    }
                    IconButton(onClick = onClose) {
                        Icon(Icons.Default.Close, contentDescription = "Đóng")
                    }
                }

                Spacer(modifier = Modifier.height(14.dp))

                // Dynamic progress wheel visual feedback
                Box(
                    modifier = Modifier
                        .size(100.dp)
                        .clip(CircleShape)
                        .background(CoffeeSecondary),
                    contentAlignment = Alignment.Center
                ) {
                    Column(horizontalAlignment = Alignment.CenterHorizontally) {
                        Text(
                            text = when(order.status) {
                                OrderStatus.PENDING -> "🕒"
                                OrderStatus.PREPARING -> "🍳"
                                OrderStatus.DONE -> "🥞"
                                OrderStatus.PAID -> "💵"
                            },
                            fontSize = 36.sp
                        )
                        Text(
                            text = order.status.vietnamese,
                            fontSize = 11.sp,
                            fontWeight = FontWeight.Bold,
                            color = order.status.color
                        )
                    }
                }

                Spacer(modifier = Modifier.height(16.dp))

                // Interactive Progress Timeline Stages (Simulated Realtime Sync Hub Feedback!)
                Column(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(horizontal = 8.dp),
                    verticalArrangement = Arrangement.spacedBy(12.dp)
                ) {
                    val activeStep = order.status.step
                    OrderStatus.values().forEach { state ->
                        val isCompleted = state.step < activeStep
                        val isActive = state.step == activeStep
                        val isPending = state.step > activeStep

                        Row(
                            verticalAlignment = Alignment.CenterVertically,
                            horizontalArrangement = Arrangement.spacedBy(12.dp)
                        ) {
                            Box(
                                modifier = Modifier
                                    .size(26.dp)
                                    .clip(CircleShape)
                                    .background(
                                        when {
                                            isCompleted -> SuccessGreen
                                            isActive -> CoffeePrimary
                                            else -> Color.LightGray
                                        }
                                    ),
                                contentAlignment = Alignment.Center
                            ) {
                                if (isCompleted) {
                                    Icon(Icons.Default.Check, contentDescription = null, modifier = Modifier.size(14.dp), tint = Color.White)
                                } else {
                                    Text("${state.step}", color = Color.White, fontSize = 10.sp, fontWeight = FontWeight.Bold)
                                }
                            }

                            Column(modifier = Modifier.weight(1f)) {
                                Text(
                                    text = when(state) {
                                        OrderStatus.PENDING -> "Bếp tiếp nhận đơn"
                                        OrderStatus.PREPARING -> "Nhà hàng đang chế biến"
                                        OrderStatus.DONE -> "Món ăn đã ra bàn"
                                        OrderStatus.PAID -> "Đã thanh toán"
                                    },
                                    fontSize = 13.sp,
                                    fontWeight = if (isActive) FontWeight.Bold else FontWeight.Medium,
                                    color = if (isPending) Color.Gray else CoffeeTextDark
                                )
                                Text(
                                    text = when(state) {
                                        OrderStatus.PENDING -> "Hệ thống tự động đồng bộ hóa REST & SignalR Hub."
                                        OrderStatus.PREPARING -> "Đầu bếp đang thực hiện nướng/pha chế."
                                        OrderStatus.DONE -> "Phục vụ bưng nước đến bàn ${order.tableLabel}."
                                        OrderStatus.PAID -> "Hoàn tất! Cảm ơn quý khách quý báu."
                                    },
                                    fontSize = 10.sp,
                                    color = if (isPending) Color.LightGray else CoffeeTextSub
                                )
                            }
                        }
                    }
                }

                Spacer(modifier = Modifier.height(18.dp))

                // Display ordered summary item strings
                Column(
                    modifier = Modifier
                        .fillMaxWidth()
                        .clip(RoundedCornerShape(16.dp))
                        .background(CoffeeSecondary)
                        .padding(12.dp),
                    verticalArrangement = Arrangement.spacedBy(4.dp)
                ) {
                    Text("Tóm tắt món gọi:", fontSize = 11.sp, fontWeight = FontWeight.Bold, color = CoffeeTextSub)
                    order.items.forEach { cartItem ->
                        Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                            Text("• ${cartItem.menuItem.name} (x${cartItem.quantity})", fontSize = 11.sp, color = CoffeeTextDark)
                            Text(String.format("$%.2f", cartItem.menuItem.price * cartItem.quantity), fontSize = 11.sp, fontWeight = FontWeight.Bold)
                        }
                    }
                }

                Spacer(modifier = Modifier.height(16.dp))

                // Soft action button
                Text(
                    text = "Khách hàng không cần đăng nhập. Để thanh toán hóa đơn, vui lòng thanh toán tại quầy thu ngân hoặc quẹt thẻ.",
                    fontSize = 10.sp,
                    color = Color.Gray,
                    textAlign = TextAlign.Center,
                    lineHeight = 12.sp
                )

                if (order.status == OrderStatus.PENDING) {
                    Spacer(modifier = Modifier.height(8.dp))
                    TextButton(
                        onClick = onCancelOrder,
                        colors = ButtonDefaults.textButtonColors(contentColor = ErrorColor)
                    ) {
                        Text("Hủy Order")
                    }
                }
            }
        }
    }
}

// ==========================================
// STAFF WORKSPACE VIEW (Real-time updates)
// ==========================================

@Composable
fun StaffDashboard(
    orderQueue: List<Order>,
    menuItems: List<MenuItem>,
    onToggleAvailability: (String) -> Unit,
    onUpdateOrderStatus: (String, OrderStatus) -> Unit,
    onCreateMenuItem: (MenuItem) -> Unit,
    onUpdateMenuItem: (MenuItem) -> Unit,
    onDeleteMenuItem: (String) -> Unit,
    onBackToGateway: () -> Unit
) {
    var activeStaffSubTab by remember { mutableStateOf("orders") } // "orders", "menu", "tables", "doc"

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(CoffeeBackground)
    ) {
        // Staff Dashboard Header bar
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .background(CoffeeDarkAccent)
                .padding(horizontal = 24.dp, vertical = 16.dp)
        ) {
            Column {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(8.dp),
                        modifier = Modifier.weight(1f)
                    ) {
                        Icon(Icons.Filled.Storefront, contentDescription = null, tint = CoffeeGold)
                        Text(
                            text = "Aroma Crew 💼",
                            fontSize = 15.sp,
                            fontWeight = FontWeight.Bold,
                            color = Color.White,
                            maxLines = 1,
                            overflow = TextOverflow.Ellipsis
                        )
                    }

                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        // Simulated server connection status badge
                        Box(
                            modifier = Modifier
                                .clip(RoundedCornerShape(8.dp))
                                .background(SuccessGreen.copy(alpha = 0.2f))
                                .border(BorderStroke(1.dp, SuccessGreen), RoundedCornerShape(8.dp))
                                .padding(horizontal = 8.dp, vertical = 2.dp)
                        ) {
                            Text("SIGNALR ACTIVE", color = Color.White, fontSize = 9.sp, fontWeight = FontWeight.Bold)
                        }

                        // Close/Logout button
                        IconButton(
                            onClick = onBackToGateway,
                            modifier = Modifier
                                .size(32.dp)
                                .clip(CircleShape)
                                .background(Color.White.copy(alpha = 0.15f))
                        ) {
                            Icon(
                                imageVector = Icons.Default.Logout,
                                contentDescription = "Thoát vai trò",
                                tint = Color.White,
                                modifier = Modifier.size(14.dp)
                            )
                        }
                    }
                }

                Spacer(modifier = Modifier.height(12.dp))

                // Crew Secondary Control Segments
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(4.dp)
                ) {
                    listOf(
                        "orders" to "Đơn hàng",
                        "menu" to "Thực đơn",
                        "tables" to "Sơ đồ",
                        "doc" to "C# Kiến trúc"
                    ).forEach { (tab, label) ->
                        val isSelected = activeStaffSubTab == tab
                        Button(
                            onClick = { activeStaffSubTab = tab },
                            modifier = Modifier.weight(1f),
                            shape = RoundedCornerShape(50.dp),
                            colors = ButtonDefaults.buttonColors(
                                containerColor = if (isSelected) CoffeeGold else Color.White.copy(alpha = 0.15f),
                                contentColor = if (isSelected) CoffeeDarkAccent else Color.White
                            ),
                            contentPadding = PaddingValues(0.dp)
                        ) {
                            Text(label, fontSize = 10.sp, fontWeight = FontWeight.Bold)
                        }
                    }
                }
            }
        }

        // Sub View rendering
        when (activeStaffSubTab) {
            "orders" -> {
                StaffOrdersWorkspace(orderQueue = orderQueue, onUpdateStatus = onUpdateOrderStatus)
            }
            "menu" -> {
                StaffMenuAvailabilityWorkspace(
                    menuItems = menuItems,
                    onToggle = onToggleAvailability,
                    onCreateItem = onCreateMenuItem,
                    onUpdateItem = onUpdateMenuItem,
                    onDeleteItem = onDeleteMenuItem
                )
            }
            "tables" -> {
                StaffTablesVisualWorkspace(orderQueue = orderQueue)
            }
            "doc" -> {
                SystemArchitectureDocScreen()
            }
        }
    }
}

@Composable
fun StaffOrdersWorkspace(
    orderQueue: List<Order>,
    onUpdateStatus: (String, OrderStatus) -> Unit
) {
    if (orderQueue.isEmpty()) {
        Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
            Text("Không có hóa đơn/giao dịch order nào hôm nay!", color = CoffeeTextSub, fontSize = 14.sp)
        }
    } else {
        LazyColumn(
            modifier = Modifier.fillMaxSize(),
            contentPadding = PaddingValues(16.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            // Uncompleted orders
            items(orderQueue.toList().reversed()) { order ->
                Card(
                    modifier = Modifier
                        .fillMaxWidth()
                        .border(BorderStroke(1.dp, CoffeeCardBorder), RoundedCornerShape(20.dp)),
                    colors = CardDefaults.cardColors(containerColor = Color.White),
                    shape = RoundedCornerShape(20.dp)
                ) {
                    Column(modifier = Modifier.padding(16.dp)) {
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.SpaceBetween,
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                                Box(
                                    modifier = Modifier
                                        .clip(RoundedCornerShape(8.dp))
                                        .background(CoffeePrimary)
                                        .padding(horizontal = 8.dp, vertical = 4.dp)
                                ) {
                                    Text(order.tableLabel, color = Color.White, fontSize = 11.sp, fontWeight = FontWeight.Bold)
                                }
                                Text("Đơn #${order.id}", fontSize = 13.sp, fontWeight = FontWeight.Bold, color = CoffeeTextDark)
                            }

                            // Active Status Indicator text
                            Box(
                                modifier = Modifier
                                    .clip(RoundedCornerShape(8.dp))
                                    .background(order.status.color.copy(alpha = 0.15f))
                                    .padding(horizontal = 10.dp, vertical = 4.dp)
                            ) {
                                Text(order.status.vietnamese, fontSize = 11.sp, color = order.status.color, fontWeight = FontWeight.Bold)
                            }
                        }

                        // Order list contents string formatting
                        Spacer(modifier = Modifier.height(10.dp))
                        Column(
                            verticalArrangement = Arrangement.spacedBy(4.dp)
                        ) {
                            order.items.forEach { cart ->
                                Row(
                                    modifier = Modifier.fillMaxWidth(),
                                    horizontalArrangement = Arrangement.SpaceBetween
                                ) {
                                    Text(
                                        text = "${cart.menuItem.emoji} ${cart.menuItem.name} (x${cart.quantity})",
                                        fontSize = 13.sp,
                                        color = CoffeeTextDark,
                                        fontWeight = FontWeight.Medium
                                    )
                                    Text(
                                        text = String.format("$%.2f", cart.menuItem.price * cart.quantity),
                                        fontSize = 13.sp,
                                        color = CoffeeTextSub
                                    )
                                }
                            }
                            if (order.note.isNotBlank()) {
                                Spacer(modifier = Modifier.height(4.dp))
                                Box(
                                    modifier = Modifier
                                        .fillMaxWidth()
                                        .clip(RoundedCornerShape(8.dp))
                                        .background(CoffeeSecondary)
                                        .padding(8.dp)
                                ) {
                                    Text(
                                        text = "Ghi chú bếp: ${order.note}",
                                        fontSize = 11.sp,
                                        color = ErrorColor,
                                        fontWeight = FontWeight.Bold
                                    )
                                }
                            }
                        }

                        Spacer(modifier = Modifier.height(12.dp))
                        Divider(color = CoffeeCardBorder)
                        Spacer(modifier = Modifier.height(12.dp))

                        // Interactive state transformation trigger buttons (Translates SignalR state changes instantly to user screen!)
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.spacedBy(8.dp)
                        ) {
                            when (order.status) {
                                OrderStatus.PENDING -> {
                                    Button(
                                        onClick = { onUpdateStatus(order.id, OrderStatus.PREPARING) },
                                        colors = ButtonDefaults.buttonColors(containerColor = CoffeePrimary),
                                        modifier = Modifier.weight(1f),
                                        shape = RoundedCornerShape(12.dp)
                                    ) {
                                        Text("BẾP DUYỆT ➔ CHẾ BIẾN", fontSize = 11.sp, fontWeight = FontWeight.Bold)
                                    }
                                }
                                OrderStatus.PREPARING -> {
                                    Button(
                                        onClick = { onUpdateStatus(order.id, OrderStatus.DONE) },
                                        colors = ButtonDefaults.buttonColors(containerColor = Color(0xFF4CAF50)),
                                        modifier = Modifier.weight(1f),
                                        shape = RoundedCornerShape(12.dp)
                                    ) {
                                        Text("XONG MÓN ➔ RA BÀN", fontSize = 11.sp, fontWeight = FontWeight.Bold)
                                    }
                                }
                                OrderStatus.DONE -> {
                                    Button(
                                        onClick = { onUpdateStatus(order.id, OrderStatus.PAID) },
                                        colors = ButtonDefaults.buttonColors(containerColor = CoffeeDarkAccent),
                                        modifier = Modifier.weight(1f),
                                        shape = RoundedCornerShape(12.dp)
                                    ) {
                                        Text("QUÉT TIỀN ➔ HOÀN TẤT ĐƠN 💵", fontSize = 10.sp, fontWeight = FontWeight.Bold, color = CoffeeGold)
                                    }
                                }
                                OrderStatus.PAID -> {
                                    Row(
                                        modifier = Modifier.fillMaxWidth(),
                                        horizontalArrangement = Arrangement.Center,
                                        verticalAlignment = Alignment.CenterVertically
                                    ) {
                                        Icon(Icons.Filled.CheckCircle, "Đã trả tiền", tint = SuccessGreen)
                                        Spacer(modifier = Modifier.width(6.dp))
                                        Text("Giao dịch đã thanh toán & Lưu trữ", fontSize = 12.sp, color = SuccessGreen, fontWeight = FontWeight.Bold)
                                    }
                                }
                            }
                        }

                    }
                }
            }
        }
    }
}

@Composable
fun StaffMenuAvailabilityWorkspace(
    menuItems: List<MenuItem>,
    onToggle: (String) -> Unit,
    onCreateItem: (MenuItem) -> Unit,
    onUpdateItem: (MenuItem) -> Unit,
    onDeleteItem: (String) -> Unit
) {
    var showDialog by remember { mutableStateOf(false) }
    var editingItem by remember { mutableStateOf<MenuItem?>(null) }

    var inputName by remember { mutableStateOf("") }
    var inputVietnameseName by remember { mutableStateOf("") }
    var inputPrice by remember { mutableStateOf("") }
    var inputDescription by remember { mutableStateOf("") }
    var inputEmoji by remember { mutableStateOf("☕") }
    var inputCategory by remember { mutableStateOf("Coffees") }
    var inputIsAvailable by remember { mutableStateOf(true) }

    Column {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .background(CoffeeSecondary)
                .padding(horizontal = 24.dp, vertical = 10.dp),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Text(
                text = "Danh sách thực đơn & trạng thái trực tuyến. Thay đổi sẽ đồng bộ ngay lập tức cho Khách hàng.",
                fontSize = 11.sp,
                color = CoffeeTextSub,
                modifier = Modifier.weight(1f),
                lineHeight = 14.sp
            )
            Spacer(modifier = Modifier.width(12.dp))
            Button(
                onClick = {
                    editingItem = null
                    inputName = ""
                    inputVietnameseName = ""
                    inputPrice = ""
                    inputDescription = ""
                    inputEmoji = "☕"
                    inputCategory = "Coffees"
                    inputIsAvailable = true
                    showDialog = true
                },
                colors = ButtonDefaults.buttonColors(containerColor = CoffeePrimary),
                shape = RoundedCornerShape(12.dp),
                contentPadding = PaddingValues(horizontal = 12.dp, vertical = 6.dp),
                modifier = Modifier.height(36.dp)
            ) {
                Icon(Icons.Default.Add, contentDescription = null, modifier = Modifier.size(16.dp), tint = Color.White)
                Spacer(modifier = Modifier.width(4.dp))
                Text("Thêm Món", fontSize = 11.sp, fontWeight = FontWeight.Bold, color = Color.White)
            }
        }

        LazyColumn(
            modifier = Modifier.fillMaxSize(),
            contentPadding = PaddingValues(16.dp),
            verticalArrangement = Arrangement.spacedBy(10.dp)
        ) {
            if (menuItems.isEmpty()) {
                item {
                    Column(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(24.dp),
                        horizontalAlignment = Alignment.CenterHorizontally,
                        verticalArrangement = Arrangement.Center
                    ) {
                        Text("🫙", fontSize = 48.sp)
                        Spacer(modifier = Modifier.height(12.dp))
                        Text(
                            text = "Danh sách trống. Vui lòng bấm 'Thêm Món' để tạo!",
                            fontSize = 13.sp,
                            fontWeight = FontWeight.Medium,
                            color = CoffeeTextSub
                        )
                    }
                }
            } else {
                items(menuItems) { item ->
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .clip(RoundedCornerShape(16.dp))
                            .background(Color.White)
                            .padding(12.dp),
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.SpaceBetween
                    ) {
                        Row(
                            verticalAlignment = Alignment.CenterVertically,
                            horizontalArrangement = Arrangement.spacedBy(12.dp),
                            modifier = Modifier.weight(1f)
                        ) {
                            Box(
                                modifier = Modifier
                                    .size(44.dp)
                                    .clip(RoundedCornerShape(8.dp))
                                    .background(CoffeeCardLightBg),
                                contentAlignment = Alignment.Center
                            ) {
                                Text(item.emoji, fontSize = 24.sp)
                            }
                            Column(modifier = Modifier.weight(1f)) {
                                Text(
                                    text = item.name,
                                    fontSize = 13.sp,
                                    fontWeight = FontWeight.Bold,
                                    color = CoffeeTextDark,
                                    maxLines = 1,
                                    overflow = TextOverflow.Ellipsis
                                )
                                Text(
                                    text = item.vietnameseName,
                                    fontSize = 11.sp,
                                    color = Color.Gray,
                                    maxLines = 1,
                                    overflow = TextOverflow.Ellipsis
                                )
                                Spacer(modifier = Modifier.height(2.dp))
                                Row(
                                    verticalAlignment = Alignment.CenterVertically,
                                    horizontalArrangement = Arrangement.spacedBy(6.dp)
                                ) {
                                    Box(
                                        modifier = Modifier
                                            .clip(RoundedCornerShape(6.dp))
                                            .background(CoffeeSecondary.copy(alpha = 0.4f))
                                            .padding(horizontal = 5.dp, vertical = 2.dp)
                                    ) {
                                        Text(
                                            text = when(item.category) {
                                                "Coffees" -> "Cà phê ☕"
                                                "Teas" -> "Trà hoa quả 🍵"
                                                "Pastries" -> "Bánh ngọt 🥐"
                                                "Brunch" -> "Điểm tâm 🥑"
                                                else -> item.category
                                            },
                                            fontSize = 8.sp,
                                            fontWeight = FontWeight.Bold,
                                            color = CoffeeTextDark
                                        )
                                    }
                                    Text(
                                        text = "$${item.price}",
                                        fontSize = 11.sp,
                                        fontWeight = FontWeight.Bold,
                                        color = CoffeePrimary
                                    )
                                }
                            }
                        }

                        // Actions Panel: Edit, Delete, Toggle Availability
                        Row(
                            verticalAlignment = Alignment.CenterVertically,
                            horizontalArrangement = Arrangement.spacedBy(4.dp)
                        ) {
                            IconButton(
                                onClick = {
                                    editingItem = item
                                    inputName = item.name
                                    inputVietnameseName = item.vietnameseName
                                    inputPrice = item.price.toString()
                                    inputDescription = item.description
                                    inputEmoji = item.emoji
                                    inputCategory = item.category
                                    inputIsAvailable = item.isAvailable
                                    showDialog = true
                                },
                                modifier = Modifier.size(32.dp)
                            ) {
                                Icon(
                                    imageVector = Icons.Default.Edit,
                                    contentDescription = "Sửa món",
                                    tint = CoffeePrimary,
                                    modifier = Modifier.size(16.dp)
                                )
                            }

                            IconButton(
                                onClick = { onDeleteItem(item.id) },
                                modifier = Modifier.size(32.dp)
                            ) {
                                Icon(
                                    imageVector = Icons.Default.Delete,
                                    contentDescription = "Xóa món",
                                    tint = ErrorColor,
                                    modifier = Modifier.size(16.dp)
                                )
                            }

                            Spacer(modifier = Modifier.width(2.dp))

                            Column(
                                horizontalAlignment = Alignment.CenterHorizontally,
                                verticalArrangement = Arrangement.Center
                            ) {
                                Switch(
                                    checked = item.isAvailable,
                                    onCheckedChange = { onToggle(item.id) },
                                    colors = SwitchDefaults.colors(
                                        checkedThumbColor = Color.White,
                                        checkedTrackColor = SuccessGreen,
                                        uncheckedThumbColor = Color.White,
                                        uncheckedTrackColor = Color.LightGray
                                    ),
                                    modifier = Modifier.scale(0.8f)
                                )
                                Text(
                                    text = if (item.isAvailable) "BÁN" else "HẾT",
                                    fontSize = 8.sp,
                                    fontWeight = FontWeight.Black,
                                    color = if (item.isAvailable) SuccessGreen else ErrorColor
                                )
                            }
                        }
                    }
                }
            }
        }
    }

    if (showDialog) {
        Dialog(onDismissRequest = { showDialog = false }) {
            Card(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(8.dp),
                colors = CardDefaults.cardColors(containerColor = CoffeeBackground),
                shape = RoundedCornerShape(24.dp),
                border = BorderStroke(1.dp, CoffeeCardBorder)
            ) {
                var inputError by remember { mutableStateOf<String?>(null) }

                Column(
                    modifier = Modifier
                        .padding(20.dp)
                        .verticalScroll(rememberScrollState()),
                    verticalArrangement = Arrangement.spacedBy(12.dp)
                ) {
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Text(
                            text = if (editingItem == null) "Thêm Món Ăn Mới" else "Chỉnh Sửa Món Ăn",
                            fontSize = 16.sp,
                            fontWeight = FontWeight.Bold,
                            color = CoffeeTextDark
                        )
                        IconButton(onClick = { showDialog = false }) {
                            Icon(Icons.Default.Close, contentDescription = "Đóng")
                        }
                    }

                    // Form Fields
                    Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
                        Text("Tên tiếng Anh", fontSize = 11.sp, fontWeight = FontWeight.SemiBold, color = CoffeeTextSub)
                        OutlinedTextField(
                            value = inputName,
                            onValueChange = { inputName = it },
                            placeholder = { Text("e.g. Avocado Toast", fontSize = 13.sp) },
                            modifier = Modifier.fillMaxWidth(),
                            shape = RoundedCornerShape(12.dp),
                            singleLine = true,
                            colors = OutlinedTextFieldDefaults.colors(
                                focusedContainerColor = Color.White,
                                unfocusedContainerColor = Color.White,
                                focusedBorderColor = CoffeePrimary,
                                unfocusedBorderColor = CoffeeCardBorder
                            )
                        )
                    }

                    Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
                        Text("Tên tiếng Việt", fontSize = 11.sp, fontWeight = FontWeight.SemiBold, color = CoffeeTextSub)
                        OutlinedTextField(
                            value = inputVietnameseName,
                            onValueChange = { inputVietnameseName = it },
                            placeholder = { Text("e.g. Bánh Mì Trái Bơ", fontSize = 13.sp) },
                            modifier = Modifier.fillMaxWidth(),
                            shape = RoundedCornerShape(12.dp),
                            singleLine = true,
                            colors = OutlinedTextFieldDefaults.colors(
                                focusedContainerColor = Color.White,
                                unfocusedContainerColor = Color.White,
                                focusedBorderColor = CoffeePrimary,
                                unfocusedBorderColor = CoffeeCardBorder
                            )
                        )
                    }

                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.spacedBy(12.dp)
                    ) {
                        // Price input
                        Column(
                            modifier = Modifier.weight(1f),
                            verticalArrangement = Arrangement.spacedBy(4.dp)
                        ) {
                            Text("Giá tiền ($ USD)", fontSize = 11.sp, fontWeight = FontWeight.SemiBold, color = CoffeeTextSub)
                            OutlinedTextField(
                                value = inputPrice,
                                onValueChange = { inputPrice = it },
                                placeholder = { Text("e.g. 12.00", fontSize = 13.sp) },
                                modifier = Modifier.fillMaxWidth(),
                                shape = RoundedCornerShape(12.dp),
                                singleLine = true,
                                colors = OutlinedTextFieldDefaults.colors(
                                    focusedContainerColor = Color.White,
                                    unfocusedContainerColor = Color.White,
                                    focusedBorderColor = CoffeePrimary,
                                    unfocusedBorderColor = CoffeeCardBorder
                                )
                            )
                        }

                        // Emoji input
                        Column(
                            modifier = Modifier.weight(0.7f),
                            verticalArrangement = Arrangement.spacedBy(4.dp)
                        ) {
                            Text("Biểu tượng Emoji", fontSize = 11.sp, fontWeight = FontWeight.SemiBold, color = CoffeeTextSub)
                            OutlinedTextField(
                                value = inputEmoji,
                                onValueChange = { if (it.length <= 4) inputEmoji = it },
                                placeholder = { Text("🥑", fontSize = 13.sp) },
                                modifier = Modifier.fillMaxWidth(),
                                shape = RoundedCornerShape(12.dp),
                                singleLine = true,
                                colors = OutlinedTextFieldDefaults.colors(
                                    focusedContainerColor = Color.White,
                                    unfocusedContainerColor = Color.White,
                                    focusedBorderColor = CoffeePrimary,
                                    unfocusedBorderColor = CoffeeCardBorder
                                )
                            )
                        }
                    }

                    // Category chips
                    Column(verticalArrangement = Arrangement.spacedBy(6.dp)) {
                        Text("Phân loại danh mục", fontSize = 11.sp, fontWeight = FontWeight.SemiBold, color = CoffeeTextSub)
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.spacedBy(4.dp)
                        ) {
                            listOf(
                                "Coffees" to "☕",
                                "Teas" to "🍵",
                                "Pastries" to "🥐",
                                "Brunch" to "🥑"
                            ).forEach { (catId, icon) ->
                                val selected = inputCategory == catId
                                val label = when(catId) {
                                    "Coffees" -> "Cà phê"
                                    "Teas" -> "Trà"
                                    "Pastries" -> "Bánh"
                                    "Brunch" -> "Điểm tâm"
                                    else -> catId
                                }

                                Box(
                                    modifier = Modifier
                                        .weight(1f)
                                        .clip(RoundedCornerShape(8.dp))
                                        .background(if (selected) CoffeePrimary else Color.White)
                                        .border(BorderStroke(1.dp, if (selected) CoffeePrimary else CoffeeCardBorder), RoundedCornerShape(8.dp))
                                        .clickable { inputCategory = catId }
                                        .padding(vertical = 8.dp),
                                    contentAlignment = Alignment.Center
                                ) {
                                    Column(horizontalAlignment = Alignment.CenterHorizontally) {
                                        Text(icon, fontSize = 14.sp)
                                        Text(
                                            text = label,
                                            fontSize = 9.sp,
                                            fontWeight = FontWeight.Bold,
                                            color = if (selected) Color.White else CoffeeTextDark
                                        )
                                    }
                                }
                            }
                        }
                    }

                    Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
                        Text("Mô tả chi tiết món ăn", fontSize = 11.sp, fontWeight = FontWeight.SemiBold, color = CoffeeTextSub)
                        OutlinedTextField(
                            value = inputDescription,
                            onValueChange = { inputDescription = it },
                            placeholder = { Text("Thành phần nguyên chất, công thức nướng giòn...", fontSize = 13.sp) },
                            modifier = Modifier
                                .fillMaxWidth()
                                .height(64.dp),
                            shape = RoundedCornerShape(12.dp),
                            colors = OutlinedTextFieldDefaults.colors(
                                focusedContainerColor = Color.White,
                                unfocusedContainerColor = Color.White,
                                focusedBorderColor = CoffeePrimary,
                                unfocusedBorderColor = CoffeeCardBorder
                            )
                        )
                    }

                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .clip(RoundedCornerShape(12.dp))
                            .background(Color.White)
                            .border(BorderStroke(1.dp, CoffeeCardBorder), RoundedCornerShape(12.dp))
                            .padding(horizontal = 14.dp, vertical = 8.dp),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Column {
                            Text("Sẵn sàng phục vụ", fontSize = 11.sp, fontWeight = FontWeight.Bold, color = CoffeeTextDark)
                            Text(if (inputIsAvailable) "Cho phép gọi món ngay" else "Tắt món tạm thời", fontSize = 9.sp, color = Color.Gray)
                        }
                        Switch(
                            checked = inputIsAvailable,
                            onCheckedChange = { inputIsAvailable = it },
                            colors = SwitchDefaults.colors(
                                checkedThumbColor = Color.White,
                                checkedTrackColor = SuccessGreen
                            )
                        )
                    }

                    if (inputError != null) {
                        Text(
                            text = inputError!!,
                            color = ErrorColor,
                            fontSize = 11.sp,
                            fontWeight = FontWeight.Bold,
                            modifier = Modifier.padding(top = 2.dp)
                        )
                    }

                    // Action buttons
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.spacedBy(10.dp)
                    ) {
                        OutlinedButton(
                            onClick = { showDialog = false },
                            modifier = Modifier.weight(1f),
                            shape = RoundedCornerShape(14.dp),
                            border = BorderStroke(1.dp, CoffeePrimary),
                            colors = ButtonDefaults.outlinedButtonColors(contentColor = CoffeePrimary)
                        ) {
                            Text("Hủy", fontSize = 13.sp, fontWeight = FontWeight.Bold)
                        }

                        Button(
                            onClick = {
                                if (inputName.trim().isEmpty() || inputVietnameseName.trim().isEmpty()) {
                                    inputError = "Vui lòng nhập tên món!"
                                    return@Button
                                }
                                val priceDouble = inputPrice.toDoubleOrNull()
                                if (priceDouble == null || priceDouble < 0) {
                                    inputError = "Vui lòng đặt giá tiền hợp lệ!"
                                    return@Button
                                }
                                val finalEmoji = if (inputEmoji.trim().isEmpty()) "🥗" else inputEmoji.trim()

                                if (editingItem == null) {
                                    val newId = "m_" + System.currentTimeMillis()
                                    onCreateItem(
                                        MenuItem(
                                            id = newId,
                                            name = inputName.trim(),
                                            vietnameseName = inputVietnameseName.trim(),
                                            price = priceDouble,
                                            description = inputDescription.trim(),
                                            emoji = finalEmoji,
                                            category = inputCategory,
                                            isAvailable = inputIsAvailable
                                        )
                                    )
                                } else {
                                    onUpdateItem(
                                        editingItem!!.copy(
                                            name = inputName.trim(),
                                            vietnameseName = inputVietnameseName.trim(),
                                            price = priceDouble,
                                            description = inputDescription.trim(),
                                            emoji = finalEmoji,
                                            category = inputCategory,
                                            isAvailable = inputIsAvailable
                                        )
                                    )
                                }
                                showDialog = false
                            },
                            modifier = Modifier.weight(1.2f),
                            shape = RoundedCornerShape(14.dp),
                            colors = ButtonDefaults.buttonColors(containerColor = CoffeePrimary)
                        ) {
                            Text("Hoàn tất", fontSize = 13.sp, fontWeight = FontWeight.Bold, color = Color.White)
                        }
                    }
                }
            }
        }
    }
}

@Composable
fun StaffTablesVisualWorkspace(
    orderQueue: List<Order>
) {
    val simulatedTables = listOf(
        Pair("03", "Bàn #03 - Cozy"),
        Pair("08", "Bàn #08 - Window"),
        Pair("12", "Bàn #12 - Balcony"),
        Pair("15", "Bàn #15 - VIP Private")
    )

    Column(
        modifier = Modifier.padding(24.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        Text("Sơ đồ quản lý bàn ăn hiện tại", fontSize = 15.sp, fontWeight = FontWeight.Bold, color = CoffeeTextDark)

        simulatedTables.forEach { (id, spec) ->
            val hasOrder = orderQueue.filter { it.tableId == id && it.status != OrderStatus.PAID }
            val tableStatus = if (hasOrder.isNotEmpty()) "BẬN - CO COOKING" else "TRỐNG"

            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .clip(RoundedCornerShape(16.dp))
                    .background(Color.White)
                    .border(BorderStroke(1.dp, if (hasOrder.isNotEmpty()) CoffeePrimary else CoffeeCardBorder), RoundedCornerShape(16.dp))
                    .padding(16.dp),
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                Column {
                    Text(spec, fontSize = 14.sp, fontWeight = FontWeight.Bold, color = CoffeeTextDark)
                    Text(
                        text = if (hasOrder.isNotEmpty()) "Order đang thực hiện: ${hasOrder.first().id}" else "Sẵn sàng đón khách hàng mới",
                        fontSize = 11.sp,
                        color = CoffeeTextSub
                    )
                }

                // Status Pill
                Box(
                    modifier = Modifier
                        .clip(RoundedCornerShape(12.dp))
                        .background(if (hasOrder.isNotEmpty()) CoffeePrimary.copy(alpha = 0.2f) else SuccessGreen.copy(alpha = 0.15f))
                        .padding(horizontal = 12.dp, vertical = 6.dp)
                ) {
                    Text(
                        text = tableStatus,
                        color = if (hasOrder.isNotEmpty()) CoffeePrimary else SuccessGreen,
                        fontSize = 10.sp,
                        fontWeight = FontWeight.Bold
                    )
                }
            }
        }
    }
}

// ==========================================
// SYSTEM DESIGN DOCUMENTATION TAB SCREEN
// ==========================================

@Composable
fun SystemArchitectureDocScreen() {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(CoffeeBackground)
    ) {
        // Doc Head
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .background(CoffeePrimary)
                .padding(horizontal = 24.dp, vertical = 18.dp)
        ) {
            Column {
                Text(
                    text = "BẢN THIẾT KẾ KIẾN TRÚC HỆ THỐNG",
                    fontSize = 11.sp,
                    color = CoffeeGold,
                    fontWeight = FontWeight.Black,
                    letterSpacing = 1.sp
                )
                Text(
                    text = "QR Order & Real-time Food Delivery Engine",
                    fontSize = 16.sp,
                    color = Color.White,
                    fontWeight = FontWeight.Bold
                )
            }
        }

        LazyColumn(
            modifier = Modifier
                .fillMaxWidth()
                .weight(1f),
            contentPadding = PaddingValues(20.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            item {
                DocSectionCard(
                    title = "1. Kiến Trúc Tổng Thể & Folder Structure System",
                    content = """
                    Hệ thống xây dựng theo mô hình **Clean Architecture 4 lớp** vững chắc:
                    
                    ┌─────────────────────────────────────────────────────────┐
                    │                      Presentation API (WebAPI)          │
                    ├─────────────────────────────────────────────────────────┤
                    │             Application (Business Logic, DTOs, Services) │
                    ├─────────────────────────────────────────────────────────┤
                    │             Infrastructure (EF, SQL Server, SignalR)    │
                    ├─────────────────────────────────────────────────────────┤
                    │             Domain (Entities, Core Interfaces)          │
                    └─────────────────────────────────────────────────────────┘
                    
                    **Backend C# Folder Pattern:**
                    • `/src/AromaBistro.Domain`: Chứa POCO Entities, Enums, IUnitOfWork.
                    • `/src/AromaBistro.Application`: Chứa Interfaces Services, DTOs, Mapping profiles (AutoMapper), Validators (FluentValidation).
                    • `/src/AromaBistro.Infrastructure`: Entity Framework DbContext, Repository implementation, SignalR Hub, Redis cache.
                    • `/src/AromaBistro.WebAPI`: Controllers, Hub endpoints, Middlewares, Program.cs.

                    **Flutter Frontend Directory Tree:**
                    • `/lib/core`: network, theme, routing, error handlers.
                    • `/lib/data/models`: JSON parsing objects, DTOs.
                    • `/lib/data/repositories`: API consumers, SignalR handlers.
                    • `/lib/domain/entities`: Core domain model models.
                    • `/lib/presentation/blocs`: Clean state managers (Cubit / Bloc).
                    • `/lib/presentation/pages`: QR Scan View, Menu Grid, Detail Sheet, Cart tracking view, Staff dashboard.
                    """.trimIndent()
                )
            }

            item {
                DocSectionCard(
                    title = "2. Thiết Kế Database Chuẩn Hóa & Entity Class C#",
                    content = """
                    **Thực thể MenuItem (Món ăn):**
                    ```csharp
                    public class MenuItem : BaseEntity {
                        public string Name { get; set; }
                        public string VietnameseName { get; set; }
                        public decimal Price { get; set; }
                        public string Description { get; set; }
                        public string Emoji { get; set; }
                        public string CategoryId { get; set; }
                        public Category Category { get; set; }
                        public bool IsAvailable { get; set; } = true;
                    }
                    ```
                    
                    **Thực thể Order (Đơn đặt hàng) & OrderDetail:**
                    ```csharp
                    public class Order : BaseEntity {
                        public string TableId { get; set; }
                        public Table Table { get; set; }
                        public OrderStatus Status { get; set; } = OrderStatus.Pending;
                        public decimal Subtotal { get; set; }
                        public decimal TaxAmount { get; set; }
                        public decimal Total { get; set; }
                        public string SpecialNotes { get; set; }
                        public ICollection<OrderDetail> Details { get; set; }
                    }

                    public class OrderDetail : BaseEntity {
                        public string OrderId { get; set; }
                        public string MenuItemId { get; set; }
                        public MenuItem MenuItem { get; set; }
                        public int Quantity { get; set; }
                        public decimal UnitPrice { get; set; }
                    }
                    ```
                    """.trimIndent()
                )
            }

            item {
                DocSectionCard(
                    title = "3. SignalR Real-time Flow & Sync Hubs C#",
                    content = """
                    Sử dụng **ASP.NET SignalR Hub** quản lý kết nối từ cả Khách và Nhân viên:
                    
                    ```csharp
                    public class OrderHub : Hub {
                        // Khách quét QR bàn join vào Group Table để nhận update trạng thái riêng tư bàn đó
                        public async Task JoinTable(string tableId) {
                            await Groups.AddToGroupAsync(Context.ConnectionId, $"Table_{tableId}");
                        }

                        // Staff duyệt đơn: Gửi cập nhật trực tiếp đến nhóm bàn thích hợp
                        public async Task UpdateOrderStatus(string orderId, string tableId, string status) {
                            await Clients.Group($"Table_{tableId}").SendAsync("ReceiveStatusUpdate", orderId, status);
                            await Clients.All.SendAsync("OrderQueueRefreshed");
                        }
                    }
                    ```
                    """.trimIndent()
                )
            }

            item {
                DocSectionCard(
                    title = "4. QR Code Flow & Order Lifecycle States",
                    content = """
                    **Cơ chế hoạt động QR:**
                    1. Mỗi bàn được tạo 1 UUID duy nhất lưu trong DB Table.
                    2. Web Portal Admin xuất mã QR cho Table #08 chứa link:
                       `https://aromabistro.com/order?tableId=08&token=security_crypto_hash`
                    3. Điện thoại khách scan mã QR -> tách lấy tableId -> lưu vào Local Storage.
                    4. Khách order không cần đăng nhập nhờ định danh theo Table ID.
                    
                    **Trạng thái Order Lifecycle:**
                    • **Pending (Chờ duyệt)**: Order mới tạo từ máy khách, đẩy qua API, phát SignalR thông báo Staff.
                    • **Preparing (Đang nấu)**: Staff bấm "Duyệt đơn", chuyển cho bếp làm món.
                    • **Done (Hoàn thành)**: Bếp làm xong, bưng ra cho khách, chuyển trạng thái.
                    • **Paid (Đã thanh toán)**: Khách trả tiền tại quầy, staff cập nhật đóng luồng hóa đơn.
                    """.trimIndent()
                )
            }

            item {
                DocSectionCard(
                    title = "5. Caching & Transaction Security Strategies",
                    content = """
                    • **Caching**: Sử dụng **Redis Cache** cho Menu danh sách món ăn và danh mục Category, lưu với Cache-Aside pattern. TTL = 24h, tự động xóa/invalided cache khi Staff sửa menu hoặc CRUD.
                    • **Transaction (Tính toàn vẹn dẻo)**: Khi khách bắn Order, sử dụng ACID Database Transaction đảm bảo khấu trừ số lượng nguyên liệu chuẩn xác:
                    
                    ```csharp
                    using var transaction = await _context.Database.BeginTransactionAsync();
                    try {
                        await _context.Orders.AddAsync(order);
                        await _context.SaveChangesAsync();
                        // Trừ kho nguyên liệu sỉ/lẻ...
                        await transaction.CommitAsync();
                    } catch {
                        await transaction.RollbackAsync();
                    }
                    ```
                    """.trimIndent()
                )
            }
        }
    }
}

@Composable
fun DocSectionCard(
    title: String,
    content: String
) {
    var expanded by remember { mutableStateOf(false) }

    Card(
        modifier = Modifier
            .fillMaxWidth()
            .clickable { expanded = !expanded }
            .border(BorderStroke(1.dp, CoffeeCardBorder), RoundedCornerShape(16.dp)),
        colors = CardDefaults.cardColors(containerColor = Color.White),
        shape = RoundedCornerShape(16.dp)
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = title,
                    fontSize = 14.sp,
                    fontWeight = FontWeight.Bold,
                    color = CoffeePrimary,
                    modifier = Modifier.weight(1f)
                )
                Icon(
                    imageVector = if (expanded) Icons.Default.ExpandLess else Icons.Default.ExpandMore,
                    contentDescription = null,
                    tint = CoffeePrimary
                )
            }

            if (expanded) {
                Spacer(modifier = Modifier.height(12.dp))
                Divider(color = CoffeeCardBorder)
                Spacer(modifier = Modifier.height(12.dp))
                Text(
                    text = content,
                    fontSize = 12.sp,
                    color = CoffeeTextDark,
                    fontFamily = FontFamily.Monospace,
                    lineHeight = 16.sp
                )
            }
        }
    }
}
