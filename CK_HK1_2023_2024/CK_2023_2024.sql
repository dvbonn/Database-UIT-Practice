CREATE DATABASE CK_2023_2024

USE CK_2023_2024

-- Bảng PHONG
CREATE TABLE PHONG (
    MaPhong CHAR(5) PRIMARY KEY,
    TenPhong NVARCHAR(100),
    NhiemVu NVARCHAR(200),
    MaTrP CHAR(5) -- Mã trưởng phòng, tham chiếu đến NHANVIEN
);

-- Bảng NHANVIEN
CREATE TABLE NHANVIEN (
    MaNV CHAR(5) PRIMARY KEY,
    HoTen NVARCHAR(100),
    DiaChi NVARCHAR(200),
    Email VARCHAR(100),
    GioiTinh NVARCHAR(10),
    SoDT VARCHAR(20),
    DanToc NVARCHAR(50),
    MaPhong CHAR(5),
    FOREIGN KEY (MaPhong) REFERENCES PHONG(MaPhong)
);

-- Sau khi có NHANVIEN, ta thêm khóa ngoại cho MaTrP:
ALTER TABLE PHONG
ADD CONSTRAINT FK_PHONG_TRP FOREIGN KEY (MaTrP) REFERENCES NHANVIEN(MaNV);

-- Bảng DETAI
CREATE TABLE DETAI (
    MaDT CHAR(5) PRIMARY KEY,
    TenDT NVARCHAR(200),
    TomTat NVARCHAR(500),
    LoaiDT CHAR(2) CHECK (LoaiDT IN ('A', 'B', 'C', 'D1', 'D2', 'D3')),
    KinhPhi DECIMAL(18,2),
    NgayBD DATE,
    NgayKT DATE,
    NghiemThu BIT DEFAULT 0
);

-- Bảng THAMGIADT
CREATE TABLE THAMGIADT (
    MaNV CHAR(5),
    MaDT CHAR(5),
    VaiTroDT NVARCHAR(50) CHECK (VaiTroDT IN ('chủ nhiệm', 'thành viên', 'thư ký')),
    DongGopDT INT CHECK (DongGopDT BETWEEN 0 AND 100),
    PRIMARY KEY (MaNV, MaDT),
    FOREIGN KEY (MaNV) REFERENCES NHANVIEN(MaNV),
    FOREIGN KEY (MaDT) REFERENCES DETAI(MaDT)
);

-- Bảng BAIBAOKH
CREATE TABLE BAIBAOKH (
    MaBB CHAR(5) PRIMARY KEY,
    TenBB NVARCHAR(200),
    NhaXB NVARCHAR(100),
    NgayCN DATE,
    NgayCB DATE,
    Hang CHAR(2) CHECK (Hang IN ('A*', 'A', 'B', 'C')),
    LoaiBB NVARCHAR(50) CHECK (LoaiBB IN ('tạp chí quốc tế', 'tạp chí trong nước', 'hội nghị quốc tế', 'hội nghị trong nước')),
    MaDT CHAR(5),
    FOREIGN KEY (MaDT) REFERENCES DETAI(MaDT)
);

-- Bảng CONGBOBB
CREATE TABLE CONGBOBB (
    MaNV CHAR(5),
    MaBB CHAR(5),
    VaiTroBB NVARCHAR(50) CHECK (VaiTroBB IN ('tác giả chính', 'tác giả liên hệ', 'đồng tác giả')),
    DongGopBB INT CHECK (DongGopBB BETWEEN 0 AND 100),
    PRIMARY KEY (MaNV, MaBB),
    FOREIGN KEY (MaNV) REFERENCES NHANVIEN(MaNV),
    FOREIGN KEY (MaBB) REFERENCES BAIBAOKH(MaBB)
);

--CAU 2
--A-Liệt kê nhân viên (MaNV, HoTen) và tên phòng (TenPhong) của phòng có nhiệm vụ là ‘Nghiên cứu’.
--Sắp xếp kết quả trả về giảm dần theo mã nhân viên.
SELECT NV.MaNV, NV.HoTen, P.TenPhong FROM NHANVIEN NV
JOIN PHONG P ON NV.MaPhong = P.MaPhong 
WHERE P.NhiemVu = N'Nghiên Cứu'
ORDER BY NV.MaNV DESC 

--B-Liệt kê nhân viên (MaNV, HoTen) và loại đề tài (LoaiDT) mà nhân viên đã thamgiatrongnăm 2023 (NgayBD) 
--với vai trò là ‘chủ nhiệm’ đề tài.
SELECT NV.MaNV, NV.HoTen FROM NHANVIEN NV
JOIN THAMGIADT TG ON NV.MaNV = TG.MaNV 
JOIN DETAI DT ON TG.MaDT = DT.MaDT 
WHERE YEAR(DT.NgayBD) = 2023 AND TG.VaiTroDT = N'Chủ Nhiệm'

--C-Cho biết các nhân viên (MaNV, HoTen) đã công bố bài báo khoa học 
--nhưng không phải là ‘tác giả chính’ của bất kỳ bài báo khoa học nào.
SELECT NV.MaNV, NV.HoTen FROM NHANVIEN NV
JOIN CONGBOBB CB ON NV.MaNV = CB.MaNV 
WHERE NV.MaNV NOT IN(
	SELECT MaNV FROM CONGBOBB
	WHERE VaiTroBB = N'tác giả chính' 
)

--D-Liệt kê mã đề tài, tên đề tài cùng với số lượng bài báo khoa học của các đề tài 
--này được công bố trong năm 2023 (NgayCB)
SELECT DT.MaDT, DT.TenDT, COUNT(BB.MaDT) AS SLBB 
FROM DETAI DT
JOIN BAIBAOKH BB ON DT.MaDT = BB.MaDT
WHERE YEAR(BB.NgayCB) = 2023 
GROUP BY DT.MaDT, DT.TenDT

--E-. Tìm nhân viên (HOTEN) đã công bố tất cả các bài báo khoa học trên 
--‘tạp chí quốctế’ của đề tài có mã đề tài ‘DT01’
SELECT NV.HoTen FROM NHANVIEN NV
WHERE NOT EXISTS(
	SELECT BB. MaBB
	FROM BAIBAOKH BB
	WHERE BB.LoaiBB = N'tạp chí quốc tế' AND BB.MaDT = 'DT01'
		AND BB.MaBB NOT IN(
			SELECT CB.MaBB
			FROM CONGBOBB CB
			WHERE CB.MaNV = CB.MaNV
		)
)
--F-Với mỗi phòng, tìm nhân viên (MaNV, HoTen) tham gia ít đề tài nhất
--C1
SELECT NV.MaPhong, NV.MaNV, NV.HoTen, COUNT(TG.MaDT) AS SoDeTai
FROM NHANVIEN NV
LEFT JOIN THAMGIADT TG ON NV.MaNV = TG.MaNV
GROUP BY NV.MaPhong, NV.MaNV, NV.HoTen
HAVING COUNT(TG.MaDT) = (
    SELECT TOP 1 COUNT(TG2.MaDT)
    FROM NHANVIEN NV2
    LEFT JOIN THAMGIADT TG2 ON NV2.MaNV = TG2.MaNV
    WHERE NV2.MaPhong = NV.MaPhong
    GROUP BY NV2.MaNV
    ORDER BY COUNT(TG2.MaDT) ASC
)
GO
--C2
SELECT TOP 1 WITH TIES 
       NV.MaPhong, NV.MaNV, NV.HoTen, COUNT(TG.MaDT) AS SoDeTai
FROM NHANVIEN NV
LEFT JOIN THAMGIADT TG ON NV.MaNV = TG.MaNV
GROUP BY NV.MaPhong, NV.MaNV, NV.HoTen
ORDER BY ROW_NUMBER() OVER (
           PARTITION BY NV.MaPhong 
           ORDER BY COUNT(TG.MaDT) ASC
         )
GO
