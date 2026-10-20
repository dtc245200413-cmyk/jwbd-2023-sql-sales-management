-- ==============================================================================
-- BÀI TẬP: XÂY DỰNG CƠ SỞ DỮ LIỆU QUẢN LÝ BÁN HÀNG (QuanLyBanHang)
-- Sinh viên thực hiện: DTC245200413
-- Repository: https://github.com/dtc245200413-cmyk/jwbd-2023-sql-sales-management
-- ==============================================================================

-- 1. Tạo cơ sở dữ liệu có tên là QuanLyBanHang
CREATE DATABASE IF NOT EXISTS QuanLyBanHang CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 2. Chọn Database QuanLyBanHang để thao tác
USE QuanLyBanHang;

-- ==============================================================================
-- 3. TẠO CÁC BẢNG DỮ LIỆU VỚI CÁC RÀNG BUỘC TOÀN VẸN
-- ==============================================================================

-- Bảng 1: Customer (Lưu danh sách khách hàng đến cửa hàng)
CREATE TABLE Customer (
    cID   INT         NOT NULL AUTO_INCREMENT PRIMARY KEY,
    cName VARCHAR(25) NOT NULL,
    cAge  TINYINT     NULL CHECK (cAge > 0)
);

-- Bảng 2: Order (Lưu thông tin hóa đơn mua hàng của khách)
-- Lưu ý: 'Order' là từ khóa trong SQL nên đặt trong dấu backticks `Order`
CREATE TABLE `Order` (
    oID         INT      NOT NULL AUTO_INCREMENT PRIMARY KEY,
    cID         INT      NOT NULL,
    oDate       DATETIME NOT NULL,
    oTotalPrice INT      NULL CHECK (oTotalPrice >= 0),
    FOREIGN KEY (cID) REFERENCES Customer (cID)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

-- Bảng 3: Product (Lưu danh mục sản phẩm của siêu thị)
CREATE TABLE Product (
    pID    INT         NOT NULL AUTO_INCREMENT PRIMARY KEY,
    pName  VARCHAR(25) NOT NULL,
    pPrice INT         NOT NULL CHECK (pPrice >= 0)
);

-- Bảng 4: OrderDetail (Bảng trung gian n - n giữa hóa đơn và sản phẩm)
CREATE TABLE OrderDetail (
    oID   INT NOT NULL,
    pID   INT NOT NULL,
    odQTY INT NOT NULL CHECK (odQTY > 0),
    PRIMARY KEY (oID, pID),
    FOREIGN KEY (oID) REFERENCES `Order` (oID)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    FOREIGN KEY (pID) REFERENCES Product (pID)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

-- ==============================================================================
-- 4. DỮ LIỆU MẪU KIỂM CHỨNG TOÀN VẸN DỮ LIỆU (SEED DATA TEST)
-- ==============================================================================

-- Thêm khách hàng
INSERT INTO Customer (cName, cAge) VALUES
('Minh Quan', 10),
('Ngoc Oanh', 20),
('Hong Ha', 50);

-- Thêm hóa đơn
INSERT INTO `Order` (cID, oDate, oTotalPrice) VALUES
(1, '2006-03-21 00:00:00', NULL),
(2, '2006-03-23 00:00:00', NULL),
(1, '2006-03-16 00:00:00', NULL);

-- Thêm sản phẩm
INSERT INTO Product (pName, pPrice) VALUES
('May Giat', 3),
('Tu Lanh', 5),
('Dieu Hoa', 7),
('Quat', 1),
('Bep Dien', 2);

-- Thêm chi tiết hóa đơn
INSERT INTO OrderDetail (oID, pID, odQTY) VALUES
(1, 1, 3),
(1, 3, 7),
(1, 4, 2),
(2, 1, 1),
(3, 1, 8),
(2, 5, 4),
(2, 3, 3);

-- ==============================================================================
-- 5. TRUY VẤN KIỂM CHỨNG CƠ BẢN
-- ==============================================================================

-- Xem danh sách hóa đơn kèm tên khách hàng và ngày mua
SELECT 
    o.oID, 
    c.cName, 
    o.oDate, 
    o.oTotalPrice
FROM `Order` o
JOIN Customer c ON o.cID = c.cID;

-- Xem chi tiết từng mặt hàng trong từng hóa đơn kèm thành tiền
SELECT 
    od.oID,
    c.cName,
    p.pName,
    od.odQTY,
    p.pPrice,
    (od.odQTY * p.pPrice) AS LineTotal
FROM OrderDetail od
JOIN `Order` o ON od.oID = o.oID
JOIN Customer c ON o.cID = c.cID
JOIN Product p ON od.pID = p.pID;
