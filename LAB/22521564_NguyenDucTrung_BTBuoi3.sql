--22521564
--Nguyen-Duc-Trung
--Bai-tap-thuc-hanh-buoi-3

USE BTBuoi1 

--CAU-3-C--------------------
SELECT SV.MaSV, SV.HoTen FROM SINHVIEN SV
WHERE SV.MaLop = N'HTCL2021'
  AND SV.MaSV NOT IN (
    SELECT DK.MaSV 
	FROM DANGKY DK
    JOIN MON M ON DK.MaMH = M.MaMH
    WHERE M.TenMH = N'Hệ quản trị Cơ sở dữ liệu'
      AND DK.NamHoc = 2023
)
GO

--CAU-3-D--------------------
SELECT SV.HoTen FROM SINHVIEN SV 
WHERE SV.MaLop = 'HTCL2021'
	AND SV.MaSV IN (
		SELECT DK1.MaSV FROM DANGKY DK1
		JOIN MON M1 ON DK1.MaMH = M1.MaMH
		WHERE DK1.HocKy = 2
		AND DK1.NamHoc = 2023
		AND M1.TenMH = N'Hệ quản trị Cơ sở dữ liệu'
	)
	AND SV.MaSV IN(
		SELECT DK2.MaSV FROM DANGKY DK2
		JOIN MON M2 ON DK2.MaMH = M2.MaMH
		WHERE DK2.HocKy = 2
		AND DK2.NamHoc = 2023	
		AND M2.TenMH = N'Lập trình Java'
	)
GO

--CAU-3-E------------------------
SELECT SV.HoTen FROM SINHVIEN SV 
WHERE NOT EXISTS(
	SELECT M.MaMH
	FROM MON M
	JOIN KHOA K ON M.MaKhoa = K.MaKhoa
	WHERE K.TenKhoa = N'He thong thong tin'
	AND NOT EXISTS (
		SELECT *
		FROM DANGKY DK
		WHERE DK.MaSV = SV.MaSV 
			AND DK.MaMH = M.MaMH
		)
	)
GO 

--CAU-3-F--------------------------
SELECT TOP 1 WITH TIES M.MaMH, M.TenMH  
FROM DANGKY DK 
JOIN MON M ON DK.MaMH = M.MaMH
WHERE DK.HocKy = 1 AND DK.NamHoc = 2023
GROUP BY M.MaMH, M.TenMH
ORDER BY COUNT(*) DESC 
GO 

-------------------------------------------------
--INSERT TO TEST---------------------------------
/*
INSERT INTO KHOA (MaKhoa, TenKhoa) VALUES
('KTMT', N'Kỹ Thuật Máy Tính'),
('HTTT', N'He thong thong tin'),
('CNTT', N'Công nghệ thông tin');

INSERT INTO MON (MaMH, TenMH, SoTC, MaKhoa) VALUES
('MH07', N'AI FOR EBS', 3, 'KTMT'),
('MH06', N'DATABASE', 3, 'HTTT'),
('MH05', N'Hệ quản trị Cơ sở dữ liệu', 3, 'HTTT'),
('MH01', N'Cơ sở dữ liệu', 3, 'HTTT'),
('MH02', N'Hệ điều hành', 3, 'HTTT'),
('MH03', N'Mạng máy tính', 3, 'CNTT'),
('MH04', N'Trí tuệ nhân tạo', 3, 'CNTT');

INSERT INTO SINHVIEN (MaSV, HoTen, NamSinh, MaLop) VALUES
('SV07', N'NGUYEN DUC TRUNG', 2004, 'HTCL2021'),
('SV06', N'MADAM NGUYEN', 1995, 'KTMT2022'),
('SV04', N'Nguyễn NHAT ANH', 2003, 'L01'),
('SV05', N'Nguyễn ANH', 2003, 'L01'),
('SV01', N'Nguyễn A', 2003, 'L01'),
('SV02', N'Trần B', 2003, 'L01'),
('SV03', N'Lê C', 2002, 'L02');

INSERT INTO DANGKY (MaSV, MaMH, HocKy, NamHoc) VALUES
('SV06', 'MH01', 2, 2023),
('SV06', 'MH02', 1, 2023),
('SV06', 'MH05', 2, 2023),
('SV06', 'MH06', 2, 2022),
('SV04', 'MH01', 1, 2023),
('SV04', 'MH03', 1, 2023),
('SV04', 'MH03', 2, 2023),
('SV04', 'MH01', 2, 2023),
('SV01', 'MH02', 1, 2023),
('SV02', 'MH01', 1, 2023),
('SV03', 'MH03', 1, 2023),
('SV03', 'MH01', 1, 2023),
('SV01', 'MH03', 1, 2023),
('SV01', 'MH03', 2, 2023);
*/
-----------------------------------------
/*
DELETE FROM DANGKY
DELETE FROM SINHVIEN
DELETE FROM MON
DELETE FROM KHOA

SELECT * FROM DANGKY
SELECT * FROM SINHVIEN
SELECT * FROM MON 
SELECT * FROM KHOA
*/