CREATE DATABASE CK_2021_2022

USE CK_2021_2022

CREATE TABLE THANHVIEN (
    MaTV CHAR(10) PRIMARY KEY,
    HoTen NVARCHAR(100),
    NgSinh DATE,
    GioiTinh NVARCHAR(5),
    DienThoai VARCHAR(15),
    Quan NVARCHAR(50),
    LoaiTV NVARCHAR(20) -- Star, G-Star, X-Star
)
GO

CREATE TABLE PHIM (
    MaP CHAR(10) PRIMARY KEY,
    TenP NVARCHAR(100),
    NamSX INT,
    TheLoai NVARCHAR(50),
    ThoiLuong INT, -- phút
    TinhTrang NVARCHAR(20), -- 'Đang chiếu' hoặc 'Ngừng chiếu'
    SoLuotXem INT
)
GO

CREATE TABLE RAPPHIM (
    MaRP CHAR(10) PRIMARY KEY,
    TenRP NVARCHAR(100),
    SLVe INT,
    DiaChi NVARCHAR(200),
    ThanhPho NVARCHAR(100)
)
GO

CREATE TABLE LICHCHIEU (
    MaLC CHAR(10) PRIMARY KEY,
    MaRP CHAR(10),
    MaP CHAR(10),
    PhongChieu NVARCHAR(20),
    SuatChieu CHAR(4), -- ví dụ: '1900' cho 19h00
    SucChua INT,
    TuNgay DATE,
    DenNgay DATE,
    FOREIGN KEY (MaRP) REFERENCES RAPPHIM(MaRP),
    FOREIGN KEY (MaP) REFERENCES PHIM(MaP)
)
GO

CREATE TABLE VE (
    MaVe CHAR(10) PRIMARY KEY,
    MaTV CHAR(10),
    MaLC CHAR(10),
    NgayMua DATE,
    LoaiVe NVARCHAR(10), -- 2D hoặc 3D
    GiaTien DECIMAL(10,2),
    FOREIGN KEY (MaTV) REFERENCES THANHVIEN(MaTV),
    FOREIGN KEY (MaLC) REFERENCES LICHCHIEU(MaLC)
)
GO

--CAU 2 -----------------------------------------
--a1---------------------------------------------
SELECT HoTen, DienThoai FROM THANHVIEN
WHERE LoaiTV = N'X-Star' OR Quan = N'Phú Nhuận'
ORDER BY NgSinh DESC
GO

--a2---------------------------------------------
SELECT TenP, NamSX FROM PHIM
WHERE TheLoai = N'Hành Động' OR TheLoai = N'Hoạt Hình'
ORDER BY SoLuotXem DESC
GO

--b1---------------------------------------------
SELECT TV.MaTV, TV.HoTen FROM THANHVIEN TV
JOIN VE V ON TV.MaTV = V.MaTV
WHERE YEAR(TV.NgSinh) >= 2000 AND V.LoaiVe = '3D'
GO

--b2---------------------------------------------
SELECT TV.MaTV, TV.HoTen FROM THANHVIEN TV
JOIN VE V ON TV.MaTV = V.MaTV
WHERE MONTH(V.NgayMua) = 11 AND YEAR(V.NgayMua) = 2021
GO

--c1---------------------------------------------
SELECT P.TenP, P.MaP FROM PHIM P 
WHERE NOT EXISTS(
				SELECT * FROM LICHCHIEU LC 
				JOIN RAPPHIM RP ON LC.MaRP = RP.MaRP 
				WHERE LC.MaP = P.MaP 
				AND RP.TenRP = N'Galaxy Linh Trung'
				)
GO
--c2---------------------------------------------
SELECT RP.MaRP, RP.TenRP FROM RAPPHIM RP
WHERE NOT EXISTS(
				SELECT * FROM LICHCHIEU LC
				JOIN PHIM P ON LC.MaP = P.MaP
				WHERE LC.MaRP = RP.MaRP 
				AND P.TenP = N'Stand by me Doraemon'
				)
GO

--d1---------------------------------------------
SELECT V.MaTV FROM VE V
JOIN LICHCHIEU LC ON V.MaLC = LC.MaLC
JOIN PHIM P ON LC.MaP = P.MaP
WHERE P.TenP = N'Lật Mặt'

INTERSECT

SELECT V.MaTV FROM VE V
JOIN LICHCHIEU LC ON V.MaLC = LC.MaLC
JOIN PHIM P ON LC.MaP = P.MaP
WHERE P.TenP = N'Bố Già'

GO

--d2---------------------------------------------
SELECT V.MaTV FROM VE V
JOIN LICHCHIEU LC ON V.MaLC = LC.MaLC
JOIN RAPPHIM RP ON LC.MaRP = RP.MaRP
WHERE RP.TenRP = N'Galaxy Linh Trung'

INTERSECT

SELECT V.MaTV FROM VE V
JOIN LICHCHIEU LC ON V.MaLC = LC.MaLC
JOIN RAPPHIM RP ON LC.MaRP = RP.MaRP
WHERE RP.TenRP = N'Galaxy Tân Bình'

GO
--e1---------------------------------------------
SELECT P.MaP, P.TenP, SUM(V.GiaTien) AS DOANHTHUPHIM 
FROM PHIM P, LICHCHIEU LC 
JOIN VE V ON LC.MaLC = V.MaLC 
WHERE LC.MaP = P.MaP 
AND YEAR(V.NgayMua) = 2019
GROUP BY P.MaP, P.TenP
GO
--e2---------------------------------------------
SELECT RP.MaRP, RP.TenRP, SUM(V.GiaTien) AS TONGDOANHRAP
FROM RAPPHIM RP, LICHCHIEU LC
JOIN VE V ON LC.MALC = V.MaLC
WHERE LC.MaRP = RP.MaRP
AND YEAR(V.NgayMua) = 2017
GROUP BY RP.MaRP, RP.TenRP
GO

--f1---------------------------------------------
SELECT TOP 1 WITH TIES TV.MaTV, TV.HoTen, COUNT(*) AS SOLUONGVE FROM VE V
JOIN THANHVIEN TV ON V.MaTV = TV.MaTV
GROUP BY TV.MaTV, TV.HoTen
ORDER BY SOLUONGVE DESC
GO

--f2---------------------------------------------
SELECT TOP 1 WITH TIES TV.MaTV, TV.HoTen, COUNT(V.GiaTien) AS GIAVE FROM VE V
JOIN THANHVIEN TV ON V.MaTV = TV.MaTV
GROUP BY TV.MaTV, TV.HoTen
ORDER BY GIAVE DESC
GO




