---BT-THUC-HANH-SO-10----
 
CREATE DATABASE BTTH10

USE BTTH10

-------------------------
--DE--01-----------------
/*
DROP TABLE TACGIA
DROP TABLE SACH
DROP TABLE TACGIA_SACH
DROP TABLE PHATHANH
*/

--CREATE-TABLE-----------
CREATE TABLE TACGIA(
	MaTG CHAR(5) PRIMARY KEY,
	HoTen VARCHAR(20) NOT NULL,
	DiaChi VARCHAR(50), 
	NgSinh SMALLDATETIME, 
	SoDT VARCHAR(15) NOT NULL
)
GO

CREATE TABLE SACH(
	MaSach CHAR(5) PRIMARY KEY, 
	TenSach VARCHAR(25) NOT NULL,
	TheLoai VARCHAR(25) NOT NULL 
)
GO 

CREATE TABLE TACGIA_SACH(
	MaTG CHAR(5),
	MaSach CHAR(5),
	PRIMARY KEY (MaTG, MaSach)
)
GO 

CREATE TABLE PHATHANH(
	MaPH CHAR(5) PRIMARY KEY, 
	MaSach CHAR(5), 
	NgayPH SMALLDATETIME, 
	SoLuong INT,
	NhaXuatBan VARCHAR(20) NOT NULL
)
GO 

ALTER TABLE TACGIA_SACH
ADD CONSTRAINT FK_TacGiaSach_TacGia
    FOREIGN KEY (MaTG) REFERENCES TACGIA(MaTG)

ALTER TABLE TACGIA_SACH
ADD CONSTRAINT FK_TacGiaSach_Sach
    FOREIGN KEY (MaSach) REFERENCES SACH(MaSach)

ALTER TABLE PHATHANH
ADD CONSTRAINT FK_PhatHanh_Sach
    FOREIGN KEY (MaSach) REFERENCES SACH(MaSach)

--IMAGATION-DATA-TEST-------------------------------
INSERT INTO TACGIA VALUES
('TG001', 'Nguyen Van A', 'HCM', '1975-05-10', '0909123456'),
('TG002', 'Tran Thi B', 'Hanoi', '1980-08-20', '0911222333'),
('TG003', 'Le Van C', 'Danang', '1990-12-05', '0933444555');

INSERT INTO SACH (MaSach, TenSach, TheLoai) VALUES
('S001', N'Toán 1', N'Giáo khoa'),
('S002', N'Kỹ năng sống', N'Tham khảo'),
('S003', N'Văn 9', N'Giáo khoa');

INSERT INTO TACGIA_SACH VALUES
('TG001', 'S001'),
('TG001', 'S003'),
('TG002', 'S002'),
('TG003', 'S004'),
('TG002', 'S005');

INSERT INTO PHATHANH VALUES
('PH01', 'S001', '2024-01-10', 1000, N'Giáo dục'),
('PH002', 'S002', '2024-02-15', 500, 'Giao duc'),
('PH003', 'S003', '2024-03-01', 800, 'Tre'),
('PH004', 'S004', '2024-04-20', 300, 'NXB KHKT'),
('PH005', 'S005', '2024-05-12', 600, 'Chinh tri');

select * from SACH where MaSach = 'S001'
GO
--CAU-2-----------------------------------------
--CAU-2.1---------------------------------------
CREATE TRIGGER trg_CheckNgayPH_NgSinh 
ON PHATHANH
FOR INSERT, UPDATE
AS 
BEGIN 
	IF EXISTS(
		SELECT * FROM inserted I
		JOIN TACGIA_SACH TGS ON I.MaSach = TGS.MaSach 
		JOIN TACGIA TG ON TGS.MaTG = TG.MaTG
		WHERE I.NgayPH <= TG.NgSinh
	)
	BEGIN 
		RAISERROR (N'Ngày phát hành sách phải lớn hơn ngày sinh của tác giả !!!', 16, 1)
		ROLLBACK TRANSACTION
	END
END

GO
--CAU-2.2---------------------------------------
IF OBJECT_ID('trg_CheckTheLoai_GiaoKhoa', 'TR') IS NOT NULL
    DROP TRIGGER trg_CheckTheLoai_GiaoKhoa;
GO

CREATE TRIGGER trg_CheckTheLoai_GiaoKhoa ON PHATHANH
FOR INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM INSERTED I
        JOIN SACH S ON I.MaSach = S.MaSach
        WHERE S.TheLoai = N'Giáo khoa'
          AND I.NhaXuatBan != N'Giáo dục'
    )
    BEGIN
        RAISERROR ('Sách giáo khoa chỉ do NXB Giáo dục phát hành!', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;

	GO 
--CAU-3-----------------------------------------
--CAU-3.1---------------------------------------
--Tìm tác giả (MaTG,HoTen,SoDT) của những quyển sách thuộc thể loại “Văn học” do nhà xuất bản Trẻ phát hành
SELECT DISTINCT TG.MaTG, HoTen, SoDT FROM TACGIA TG
INNER JOIN TACGIA_SACH TGS ON TG.MaTG = TGS.MaTG
INNER JOIN PHATHANH PH ON TGS.MaSach = PH.MaSach
INNER JOIN SACH S ON PH.MaSach = S.MaSach
WHERE S.TheLoai = N'Van Hoc' 
	AND PH.NhaXuatBan = N'Tre'
--CAU-3.2.
--Tìm nhà xuất bản phát hành nhiều thể loại sách nhất
SELECT TOP 1 WITH TIES PH.NhaXuatBan, COUNT(DISTINCT S.TheLoai) AS SoLuongTheLoai
FROM PHATHANH PH
JOIN SACH S ON PH.MaSach = S.MaSach
GROUP BY PH.NhaXuatBan
ORDER BY SoLuongTheLoai DESC
--CAU-3.3.
--Trong mỗi nhà xuất bản, tìm tác giả (MaTG,HoTen) có số lần phát hành nhiều sách nhất
--C1--
WITH SoLanPhatHanh AS (
    SELECT
        PH.NhaXuatBan,
        TG.MaTG,
        TG.HoTen,
        COUNT(*) AS SoLan, /*Tính số lần phát hành của mỗi tg tại nxb*/

		/*Gán hạng cho mỗi tác giả theo số lần phát hành, chia nhóm theo từng nxb*/
        RANK() OVER (PARTITION BY PH.NhaXuatBan ORDER BY COUNT(*) DESC) AS XepHang
    FROM PHATHANH PH
    JOIN SACH S ON PH.MaSach = S.MaSach
    JOIN TACGIA_SACH TGS ON S.MaSach = TGS.MaSach
    JOIN TACGIA TG ON TGS.MaTG = TG.MaTG
    GROUP BY PH.NhaXuatBan, TG.MaTG, TG.HoTen
)

SELECT NhaXuatBan, MaTG, HoTen, SoLan
FROM SoLanPhatHanh
WHERE XepHang = 1

--C2--
--Đếm số lần phát hành của mỗi tác giả theo từng NXB
SELECT PH.NhaXuatBan, TG.MaTG, TG.HoTen, COUNT(*) AS SoLan
INTO Temp_TacGiaPhatHanh
FROM PHATHANH PH
JOIN SACH S ON PH.MaSach = S.MaSach
JOIN TACGIA_SACH TGS ON S.MaSach = TGS.MaSach
JOIN TACGIA TG ON TGS.MaTG = TG.MaTG
GROUP BY PH.NhaXuatBan, TG.MaTG, TG.HoTen;

--Tìm số phát hành tối đa mỗi nhà xuất bản
SELECT NhaXuatBan, MAX(SoLan) AS MaxLan
INTO Temp_MaxPhatHanh
FROM Temp_TacGiaPhatHanh
GROUP BY NhaXuatBan;

--Lấy tác giả có số lần phát hành = tối đa
SELECT T1.NhaXuatBan, T1.MaTG, T1.HoTen, T1.SoLan
FROM Temp_TacGiaPhatHanh T1
JOIN Temp_MaxPhatHanh T2
  ON T1.NhaXuatBan = T2.NhaXuatBan AND T1.SoLan = T2.MaxLan;

--Xóa bảng tạm nếu cần sửa
DROP TABLE Temp_TacGiaPhatHanh;
DROP TABLE Temp_MaxPhatHanh;

--C3---------------------
SELECT PH.NhaXuatBan, TG.MaTG, TG.HoTen, COUNT(PH.MaPH) [SOLUONGPH]
FROM PHATHANH PH, TACGIA TG, TACGIA_SACH TGS
WHERE TG.MaTG = TGS.MaTG AND
		TGS.MaSach = PH.MaSach
GROUP BY NhaXuatBan, TG.MaTG, TG.HoTen
HAVING COUNT(PH.MaPH) >= ALL (
								SELECT COUNT(PH.MaPH) [SOLUONGPH]
								FROM TACGIA TG, PHATHANH PH2, TACGIA_SACH TGS
								WHERE TG.MaTG = TGS.MaTG AND TGS.MaSach = PH2.MaSach
								GROUP BY NhaXuatBan, TG.MaTG
								HAVING PH2.NhaXuatBan = PH.NhaXuatBan 
								)
-------------------------
--DE--02-----------------
-------------------------
/*
DROP TABLE PHONGBAN
DROP TABLE NHANVIEN
DROP TABLE XE
DROP TABLE PHANCONG
*/
CREATE TABLE PHONGBAN (
    MaPhong CHAR(5) PRIMARY KEY,
    TenPhong VARCHAR(25),
    TruongPhong CHAR(5)
)
GO

CREATE TABLE NHANVIEN (
    MaNV CHAR(5) PRIMARY KEY,
    HoTen VARCHAR(20),
    NgayVL SMALLDATETIME,
    HSLuong NUMERIC(4,2),
    MaPhong CHAR(5),
    FOREIGN KEY (MaPhong) REFERENCES PHONGBAN(MaPhong)
)
GO

CREATE TABLE XE (
    MaXe CHAR(5) PRIMARY KEY,
    LoaiXe VARCHAR(20),
    SoChoNgoi INT,
    NamSX INT
)
GO

CREATE TABLE PHANCONG (
    MaPC CHAR(5) PRIMARY KEY,
    MaNV CHAR(5),
    MaXe CHAR(5),
    NgayDi SMALLDATETIME,
    NgayVe SMALLDATETIME,
    NoiDen VARCHAR(25),
    FOREIGN KEY (MaNV) REFERENCES NHANVIEN(MaNV),
    FOREIGN KEY (MaXe) REFERENCES XE(MaXe)
)
GO

ALTER TABLE PHONGBAN
ADD CONSTRAINT FK_TruongPhong
FOREIGN KEY (TruongPhong) REFERENCES NHANVIEN(MaNV) 

--Cau-2-----------------
--Cau-2.1---------------
ALTER TABLE XE
ADD CONSTRAINT CK_Toyota_NamSX
CHECK (LoaiXe != 'Toyota' OR NamSX >= 2006) 
GO
--Cau-2.2---------------
CREATE TRIGGER trg_ChiLaiToyotaNgoaiThanh ON PHANCONG
FOR INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT *
        FROM INSERTED I
        JOIN NHANVIEN NV ON I.MaNV = NV.MaNV
        JOIN PHONGBAN PB ON NV.MaPhong = PB.MaPhong
        JOIN XE X ON I.MaXe = X.MaXe
        WHERE PB.TenPhong = N'Ngoại thành'
          AND X.LoaiXe != 'Toyota'
    )
    BEGIN
        RAISERROR (N'Nhân viên phòng Ngoại thành chỉ được lái xe Toyota!', 16, 1);
        ROLLBACK TRANSACTION
    END
END

--Cau-3-----------------
--Cau-3.1---------------
SELECT DISTINCT NV.MaNV, NV.HoTen
FROM NHANVIEN NV
JOIN PHONGBAN PB ON NV.MaPhong = PB.MaPhong 
JOIN PHANCONG PC ON NV.MaNV = PC.MaNV
JOIN XE ON PC. MaXe = XE.MaXe 
WHERE XE.LoaiXe = N'Toyota' 
	AND PB.TenPhong = N'Nội thành' 
	AND XE.SoChoNgoi = 4

GO
--Cau-3.2---------------
--C1--------------------
SELECT NV.MaNV, NV.HoTen
FROM NHANVIEN NV
JOIN PHONGBAN PB ON NV.MaNV = PB.TruongPhong
WHERE NOT EXISTS (
    SELECT LX.LoaiXe
    FROM XE LX
    EXCEPT
    SELECT DISTINCT X.LoaiXe
    FROM PHANCONG PC
    JOIN XE X ON PC.MaXe = X.MaXe
    WHERE PC.MaNV = NV.MaNV
)
GO
--C2--------------------
SELECT NV.MaNV, NV.HoTen
FROM NHANVIEN NV
JOIN PHONGBAN PB ON NV.MaNV = PB.TruongPhong
JOIN PHANCONG PC ON NV.MaNV = PC.MaNV
JOIN XE X ON PC.MaXe = X.MaXe
GROUP BY NV.MaNV, NV.HoTen
HAVING COUNT(DISTINCT X.LoaiXe) = (	
									SELECT COUNT(DISTINCT LoaiXe)
									FROM XE
								  )
GO
--Cau-3.3---------------
SELECT DISTINCT NV.MaNV, NV.HoTen
FROM NHANVIEN NV
JOIN PHANCONG PC ON NV.MaNV = PC.MaNV
JOIN XE ON PC.MaXe = XE.MaXe
WHERE XE.LoaiXe = 'Toyota'
GO
------------------------
--De--3-----------------
------------------------
CREATE TABLE DOCGIA(
	MaDG CHAR(5) PRIMARY KEY,
	HoTen VARCHAR(30),
	NgaySinh SMALLDATETIME,
	DiaChi VARCHAR(30),
	SoDT VARCHAR(15)
)
GO

CREATE TABLE SACHD2(
	MaSach CHAR(5) PRIMARY KEY,
	TenSach VARCHAR(25),
	TheLoai VARCHAR(25),
	NhaXuatBan VARCHAR(30)
)
GO

CREATE TABLE PHIEUTHUE(
	MaPT CHAR(5) PRIMARY KEY,
	MaDG CHAR(5) REFERENCES DOCGIA,
	NgayThue SMALLDATETIME,
	NgayTra SMALLDATETIME,
	SoSachThue INT
)
GO

CREATE TABLE CHITIET_PT(
	MaPT CHAR(5) REFERENCES PHIEUTHUE,
	MaSach CHAR(5) REFERENCES SACHD2,
	PRIMARY KEY(MaPT, MaSach)
)
GO

--CAU-2--------------------
--2.1----------------------
CREATE TRIGGER TRG_CheckNgayThue ON PHIEUTHUE
FOR INSERT, UPDATE
AS
BEGIN
	IF EXISTS(
		SELECT 1 FROM inserted I
		WHERE NgayTra IS NOT NULL
		  AND DATEDIFF(DAY, NgayThue, NgayTra) >10 
	)

	BEGIN
		RAISERROR('10 DAY IS LIMITED !!', 16, 1)
		ROLLBACK TRANSACTION
	END
END

--2.2-----------------------
CREATE TRIGGER TRG_CheckSoSachThue ON PHIEUTHUE
AFTER INSERT, UPDATE
AS 
BEGIN 
	IF EXISTS(
		SELECT 1 FROM inserted I
		JOIN (
			SELECT MaPT, COUNT(*) AS SoSachThucTe
			FROM CHITIET_PT
			GROUP BY MaPT
		) CT ON I.MaPT = CT.MaPT
		WHERE I.SoSachThue <> CT.SoSachThucTe
	)

	BEGIN
		RAISERROR('TRY AGAIN', 16, 1)
		ROLLBACK TRANSACTION
	END
END