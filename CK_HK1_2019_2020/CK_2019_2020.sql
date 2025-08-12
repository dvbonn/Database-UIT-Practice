CREATE DATABASE CK_2019_2020

USE CK_2019_2020

----------------------------------------
-- 1. Bảng Quốc gia
CREATE TABLE Quocgia (
    MaQG CHAR(5) PRIMARY KEY,
    TenQG NVARCHAR(100),
    ChauLuc NVARCHAR(50),
    DienTich FLOAT
)
GO
-- 2. Bảng Thế vận hội
CREATE TABLE Thevanhoi (
    MaTVH CHAR(5) PRIMARY KEY,
    TenTVH NVARCHAR(100),
    MaQG CHAR(5),
    Nam INT,
    FOREIGN KEY (MaQG) REFERENCES Quocgia(MaQG)
)
GO
-- 3. Bảng Vận động viên
CREATE TABLE Vandongvien (
    MaVDV CHAR(5) PRIMARY KEY,
    HoTen NVARCHAR(100),
    NgSinh DATE,
    GioiTinh NVARCHAR(10),
    QuocTich CHAR(5),
    FOREIGN KEY (QuocTich) REFERENCES Quocgia(MaQG)
)
GO
-- 4. Bảng Nội dung thi
CREATE TABLE Noidungthi (
    MaNDT CHAR(5) PRIMARY KEY,
    TenNDT NVARCHAR(100),
    GhiChu NVARCHAR(255)
)
GO
-- 5. Bảng Tham gia
CREATE TABLE Thamgia (
    MaVDV CHAR(5),
    MaNDT CHAR(5),
    MaTVH CHAR(5),
    HuyChuong INT CHECK (HuyChuong IN (0, 1, 2, 3)),
    PRIMARY KEY (MaVDV, MaNDT, MaTVH),
    FOREIGN KEY (MaVDV) REFERENCES Vandongvien(MaVDV),
    FOREIGN KEY (MaNDT) REFERENCES Noidungthi(MaNDT),
    FOREIGN KEY (MaTVH) REFERENCES Thevanhoi(MaTVH)
)
GO	
-----------------------------------------------------------
--Cau-2
--a--
SELECT HoTen, NgSinh, GioiTinh FROM Vandongvien
WHERE QuocTich = 'UK'
ORDER BY HoTen ASC 
GO
--b--
SELECT TG.MaVDV FROM Thamgia TG
JOIN Noidungthi NDT ON TG.MaNDT = NDT.MaNDT
JOIN Thevanhoi TVH ON TG.MaTVH = TVH.MaTVH 
WHERE NDT.TenNDT = N'Bắn Cung' AND TVH.TenTVH = 'Olympic Tokyo 2020'
GO
--c--
SELECT COUNT(TG.HuyChuong) AS SLHC 
FROM Thamgia TG
JOIN Vandongvien VDV ON TG.MaVDV = VDV.MaVDV
JOIN Thevanhoi TVH ON TG.MaTVH = TVH.MaTVH 
JOIN Quocgia QG ON VDV.QuocTich = QG.MaQG
WHERE QG.TenQG = N'Nhật Bản' AND TVH.Nam = 2020
	AND TG.HuyChuong = 1
GO 
--d--
SELECT HoTen, QuocTich FROM Vandongvien VDV
JOIN Thamgia TG ON VDV.MaVDV = TG.MaVDV 
JOIN Noidungthi NDT ON TG.MaNDT = NDT.MaNDT 
WHERE NDT.TenNDT = N'100m Bơi Ngửa'
INTERSECT
SELECT HoTen, QuocTich FROM Vandongvien VDV
JOIN Thamgia TG ON VDV.MaVDV = TG.MaVDV 
JOIN Noidungthi NDT ON TG.MaNDT = NDT.MaNDT 
WHERE NDT.TenNDT = N'200m Tự Do'
GO
--e--
SELECT VDV.MaVDV, VDV.HoTen FROM Vandongvien VDV
WHERE VDV.GioiTinh = N'Nữ' AND VDV.QuocTich = 'UK' 
AND NOT EXISTS (
	SELECT TVH.MaTVH FROM Thevanhoi TVH
	WHERE TVH.Nam >= 2008
		AND NOT EXISTS (
			SELECT * FROM Thamgia TG
			WHERE TG.MaVDV = VDV.MaVDV
			  AND TG.MaTVH = TVH.MaTVH
		)
	)
GO
--f--
SELECT VDV.MaVDV, VDV.HoTen FROM Vandongvien VDV 
JOIN Thamgia TG ON VDV.MaVDV = TG.MaVDV
JOIN Thevanhoi TVH ON TG.MaTVH = TVH.MaTVH 
WHERE TVH.TenTVH = N'Olympic Rio 2016' AND TG.HuyChuong = 1
GROUP BY VDV.MaVDV, VDV.HoTen
HAVING COUNT(*) >= 2
GO