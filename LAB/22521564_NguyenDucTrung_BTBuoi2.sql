--22521564
--Nguyen-Duc-Trung
--Bai-tap-thuc-hanh-buoi-2

USE BTBuoi1 

--CAU-3-A----------------
SELECT * FROM SINHVIEN
WHERE MaLop = N'HTCL2022' 
ORDER BY HoTen ASC 

--CAU-3-B----------------
SELECT DK.MaSV, SV.HoTen, COUNT(DK.MaMH) AS SoLuongMon
FROM DANGKY DK
JOIN SINHVIEN SV ON DK.MaSV = SV.MaSV
WHERE DK.HocKy = 1 AND DK.NamHoc = 2023
GROUP BY DK.MaSV, SV.HoTen
