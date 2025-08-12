--22521564
--Nguyen-Duc-Trung
--Bai-tap-thuc-hanh-buoi-4

USE BTBuoi1 

--------------------------

--CAU-2-------------------
--A--Số tín chỉ của một môn học phải nằm trong khoảng từ 2 đến 4.
--Cách 1 : Sử dụng check 
ALTER TABLE MON 
ADD CONSTRAINT CHK_SOTC CHECK (SoTC BETWEEN 2 AND 4) 
GO 
--Cách 2 : Sử dụng trigger
CREATE TRIGGER TRG_INS_MONHOC_SOTC ON MON
FOR INSERT
AS
BEGIN
    DECLARE @MaMH VARCHAR(10), @SoTC INT

    SELECT @MaMH = MaMH, @SoTC = SoTC
    FROM INSERTED

    IF (@SoTC < 2 OR @SoTC > 4)
    BEGIN
        PRINT N'LỖI: Số tín chỉ của môn học phải nằm trong khoảng từ 2 đến 4!'
        ROLLBACK TRANSACTION
    END
    ELSE
    BEGIN
        PRINT N'Thêm môn học hợp lệ.'
    END
END


--B--Năm đăng ký học của một sinh viên phải lớn hơn năm sinh của sinh viên đó.
CREATE TRIGGER TRG_DANGKY_NAMHOC ON DANGKY
FOR INSERT
AS
BEGIN
    DECLARE @MaSV VARCHAR(10), @NamHoc SMALLINT, @NamSinh SMALLINT

    SELECT @MaSV = MaSV, @NamHoc = NamHoc
    FROM INSERTED

    SELECT @NamSinh = NamSinh
    FROM SINHVIEN
    WHERE MaSV = @MaSV

    IF (@NamHoc <= @NamSinh)
    BEGIN
        PRINT N'LỖI: Năm học phải lớn hơn năm sinh của sinh viên!'
        ROLLBACK TRANSACTION
    END
    ELSE
    BEGIN
        PRINT N'Thêm bản ghi đăng ký hợp lệ.'
    END
END
