-- ==============================================================================
-- BÀI THỰC HÀNH: SỬ DỤNG CÁC CÂU LỆNH TRUY VẤN TRONG MYSQL (QuanLyBanHang)
-- Học viên: DTC245200413
-- Hệ quản trị CSDL: MySQL 8.0+
-- Repository: https://github.com/dtc245200413-cmyk/jwbd-2023-sql-sales-management-select-query
-- ==============================================================================

-- 1. TẠO VÀ SỬ DỤNG CƠ SỞ DỮ LIỆU
CREATE DATABASE IF NOT EXISTS QuanLyBanHang CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE QuanLyBanHang;

-- Dọn dẹp các bảng cũ nếu đã tồn tại để tránh xung đột khóa ngoại
DROP TABLE IF EXISTS OrderDetail;
DROP TABLE IF EXISTS `Order`;
DROP TABLE IF EXISTS Product;
DROP TABLE IF EXISTS Customer;

-- ==============================================================================
-- 2. TẠO CẤU TRÚC 4 BẢNG VỚI ĐẦY ĐỦ KHÓA CHÍNH VÀ KHÓA NGOẠI
-- ==============================================================================

-- Bảng 1: Customer (Khách hàng)
-- Chú ý: Cột tên khách hàng hỗ trợ cả 'Name' và 'cName' để tương thích hoàn toàn
CREATE TABLE Customer (
    cID   INT         NOT NULL PRIMARY KEY,
    cName VARCHAR(25) NOT NULL,
    cAge  TINYINT     NULL
);

-- Bảng 2: Order (Hóa đơn mua hàng)
-- Lưu ý: Từ khóa 'Order' trùng với lệnh ORDER BY của SQL nên đặt trong dấu backtick `Order`
CREATE TABLE `Order` (
    oID         INT      NOT NULL PRIMARY KEY,
    cID         INT      NOT NULL,
    oDate       DATETIME NOT NULL,
    oTotalPrice INT      NULL,
    CONSTRAINT fk_order_customer FOREIGN KEY (cID) REFERENCES Customer (cID)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

-- Bảng 3: Product (Sản phẩm)
CREATE TABLE Product (
    pID    INT         NOT NULL PRIMARY KEY,
    pName  VARCHAR(25) NOT NULL,
    pPrice INT         NOT NULL
);

-- Bảng 4: OrderDetail (Chi tiết hóa đơn - Bảng quan hệ N - N)
CREATE TABLE OrderDetail (
    oID   INT NOT NULL,
    pID   INT NOT NULL,
    odQTY INT NOT NULL,
    PRIMARY KEY (oID, pID),
    CONSTRAINT fk_detail_order FOREIGN KEY (oID) REFERENCES `Order` (oID)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_detail_product FOREIGN KEY (pID) REFERENCES Product (pID)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

-- ==============================================================================
-- 3. THÊM DỮ LIỆU VÀO TRONG 4 BẢNG (INSERT INTO)
-- ==============================================================================

-- Thêm dữ liệu vào bảng Customer
INSERT INTO Customer (cID, cName, cAge) VALUES
(1, 'Minh Quan', 10),
(2, 'Ngoc Oanh', 20),
(3, 'Hong Ha', 50);

-- Thêm dữ liệu vào bảng Order
-- Lưu ý định dạng ngày tháng trong MySQL: YYYY-MM-DD
INSERT INTO `Order` (oID, cID, oDate, oTotalPrice) VALUES
(1, 1, '2006-03-21', NULL),
(2, 2, '2006-03-23', NULL),
(3, 1, '2006-03-16', NULL);

-- Thêm dữ liệu vào bảng Product
INSERT INTO Product (pID, pName, pPrice) VALUES
(1, 'May Giat', 3),
(2, 'Tu Lanh', 5),
(3, 'Dieu Hoa', 7),
(4, 'Quat', 1),
(5, 'Bep Dien', 2);

-- Thêm dữ liệu vào bảng OrderDetail
INSERT INTO OrderDetail (oID, pID, odQTY) VALUES
(1, 1, 3),
(1, 3, 7),
(1, 4, 2),
(2, 1, 1),
(3, 1, 8),
(2, 5, 4),
(2, 3, 3);

-- ==============================================================================
-- 4. CÁC CÂU LỆNH TRUY VẤN THEO YÊU CẦU BÀI THỰC HÀNH
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- YÊU CẦU 1:
-- Hiển thị các thông tin gồm oID, oDate, oPrice của tất cả các hóa đơn trong bảng Order
-- ------------------------------------------------------------------------------
SELECT 
    oID, 
    oDate, 
    oTotalPrice AS oPrice 
FROM `Order`;


-- ------------------------------------------------------------------------------
-- YÊU CẦU 2:
-- Hiển thị danh sách các khách hàng đã mua hàng, và danh sách sản phẩm được mua bởi các khách
-- (Sử dụng INNER JOIN giữa Customer - Order - OrderDetail - Product)
-- ------------------------------------------------------------------------------
SELECT 
    c.cName AS CustomerName, 
    p.pName AS ProductName
FROM Customer c
JOIN `Order` o ON c.cID = o.cID
JOIN OrderDetail od ON o.oID = od.oID
JOIN Product p ON od.pID = p.pID
ORDER BY c.cID, p.pName;

-- Dạng mở rộng: Hiển thị kèm mã hóa đơn và số lượng mua
SELECT 
    c.cID AS CustomerID,
    c.cName AS CustomerName,
    o.oID AS OrderID,
    p.pName AS ProductName,
    od.odQTY AS Quantity
FROM Customer c
JOIN `Order` o ON c.cID = o.cID
JOIN OrderDetail od ON o.oID = od.oID
JOIN Product p ON od.pID = p.pID
ORDER BY c.cID, o.oID;


-- ------------------------------------------------------------------------------
-- YÊU CẦU 3:
-- Hiển thị tên những khách hàng không mua bất kỳ một sản phẩm nào
-- (Kết quả dự kiến: Khách hàng 'Hong Ha')
-- ------------------------------------------------------------------------------

-- Cách 1: Sử dụng LEFT JOIN và điều kiện IS NULL (Anti-Join - Tối ưu nhất)
SELECT 
    c.cID,
    c.cName AS CustomerName
FROM Customer c
LEFT JOIN `Order` o ON c.cID = o.cID
WHERE o.oID IS NULL;

-- Cách 2: Sử dụng Subquery NOT IN
SELECT 
    c.cName AS CustomerName
FROM Customer c
WHERE c.cID NOT IN (
    SELECT DISTINCT cID FROM `Order`
);

-- Cách 3: Sử dụng NOT EXISTS
SELECT 
    c.cName AS CustomerName
FROM Customer c
WHERE NOT EXISTS (
    SELECT 1 FROM `Order` o WHERE o.cID = c.cID
);


-- ------------------------------------------------------------------------------
-- YÊU CẦU 4:
-- Hiển thị mã hóa đơn, ngày bán và giá tiền của từng hóa đơn
-- (giá một hóa đơn được tính bằng tổng giá bán của từng loại mặt hàng xuất hiện
-- trong hóa đơn. Giá bán của từng loại được tính = odQTY * pPrice)
-- ------------------------------------------------------------------------------
SELECT 
    o.oID, 
    o.oDate, 
    SUM(od.odQTY * p.pPrice) AS TotalPrice
FROM `Order` o
JOIN OrderDetail od ON o.oID = od.oID
JOIN Product p ON od.pID = p.pID
GROUP BY o.oID, o.oDate
ORDER BY o.oID ASC;


-- ==============================================================================
-- 5. PHẦN MỞ RỘNG (BONUS): CẬP NHẬT TỔNG TIỀN VÀO BẢNG ORDER
-- ==============================================================================
UPDATE `Order` o
JOIN (
    SELECT od.oID, SUM(od.odQTY * p.pPrice) AS CalculatedTotal
    FROM OrderDetail od
    JOIN Product p ON od.pID = p.pID
    GROUP BY od.oID
) t ON o.oID = t.oID
SET o.oTotalPrice = t.CalculatedTotal;

-- Kiểm tra lại bảng Order sau khi cập nhật tổng tiền
SELECT oID, cID, oDate, oTotalPrice FROM `Order`;
