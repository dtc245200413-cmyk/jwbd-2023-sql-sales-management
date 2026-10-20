-- ==============================================================================
-- BÀI TẬP: TRUY VẤN DỮ LIỆU CSDL QUẢN LÝ BÁN HÀNG (QuanLyBanHang)
-- Học viên: DTC245200413
-- File: select-query.sql
-- ==============================================================================

USE QuanLyBanHang;

-- 1. Hiển thị các thông tin gồm oID, oDate, oPrice của tất cả các hóa đơn trong bảng Order
SELECT 
    oID, 
    oDate, 
    oTotalPrice AS oPrice 
FROM `Order`;


-- 2. Hiển thị danh sách các khách hàng đã mua hàng, và danh sách sản phẩm được mua bởi các khách
SELECT 
    c.cName, 
    p.pName 
FROM Customer c
JOIN `Order` o ON c.cID = o.cID
JOIN OrderDetail od ON o.oID = od.oID
JOIN Product p ON od.pID = p.pID;


-- 3. Hiển thị tên những khách hàng không mua bất kỳ một sản phẩm nào
SELECT 
    c.cName 
FROM Customer c
LEFT JOIN `Order` o ON c.cID = o.cID
WHERE o.oID IS NULL;


-- 4. Hiển thị mã hóa đơn, ngày bán và giá tiền của từng hóa đơn
-- (giá một hóa đơn được tính bằng tổng giá bán của từng loại mặt hàng: odQTY * pPrice)
SELECT 
    o.oID, 
    o.oDate, 
    SUM(od.odQTY * p.pPrice) AS oPrice
FROM `Order` o
JOIN OrderDetail od ON o.oID = od.oID
JOIN Product p ON od.pID = p.pID
GROUP BY o.oID, o.oDate;
