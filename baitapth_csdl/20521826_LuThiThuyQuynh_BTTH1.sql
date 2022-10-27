use QLBH

--PHAN III
SET DATEFORMAT DMY

--CAU 30:
SELECT MASP, TENSP
FROM SANPHAM
WHERE NUOCSX = 'Trung Quoc' AND GIA IN (SELECT DISTINCT TOP 3 GIA
FROM SANPHAM WHERE NUOCSX = 'Trung Quoc'
ORDER BY GIA DESC)
--CAU 31:
SELECT TOP 3 MAKH ,HOTEN,RANK() OVER(ORDER BY DOANHSO DESC) AS HANGKH FROM KHACHHANG
--CAU 32:
SELECT COUNT(MASP) AS TONGSPTRQSX
FROM SANPHAM
WHERE NUOCSX='Trung Quoc'
--CAU 33:
SELECT NUOCSX, COUNT( MASP) AS SL
FROM SANPHAM
GROUP BY NUOCSX
--CAU 34:
SELECT NUOCSX ,MAX(GIA) AS GIALN,MIN(GIA) AS GIANN,AVG(GIA) AS GIATB
FROM SANPHAM
GROUP BY NUOCSX
--CAU 35:
SELECT NGHD, SUM(TRIGIA) AS DOANHTHU
FROM HOADON
GROUP BY NGHD
--CAU 36:
SELECT MASP, SUM(SL) AS SOSP
FROM CTHD INNER JOIN HOADON ON CTHD.SOHD=HOADON.SOHD
WHERE MONTH(NGHD)=10 AND YEAR(NGHD)=2006
GROUP BY MASP
--CAU 37:
SELECT MONTH(NGHD) AS THANG, SUM(TRIGIA) AS DOANHTHU
FROM HOADON
WHERE YEAR(NGHD)=2006
GROUP BY MONTH(NGHD)
--CAU 38:
SELECT*
FROM HOADON
WHERE SOHD IN (SELECT SOHD
FROM CTHD
GROUP BY SOHD
HAVING COUNT(MASP)>=4)
--CAU 39:
SELECT* FROM HOADON
WHERE SOHD IN(
SELECT SOHD
FROM CTHD INNER JOIN SANPHAM ON CTHD.MASP=SANPHAM.MASP
WHERE NUOCSX='Viet Nam'
GROUP BY SOHD
HAVING COUNT(SANPHAM.MASP)>=3)
--CAU 40:
SELECT MAKH, HOTEN
FROM KHACHHANG 
WHERE MAKH IN(
	SELECT MAKH FROM HOADON
	GROUP BY MAKH
	HAVING COUNT(SOHD)>=(
		SELECT MAX(SL_MH) AS SL FROM(SELECT MAKH, COUNT(SOHD) AS SL_MH
		FROM HOADON
		WHERE MAKH IS NOT NULL
		GROUP BY MAKH) AS T))
--CAU 41:
SELECT MONTH(NGHD) AS THANG FROM HOADON
GROUP BY MONTH(NGHD) HAVING SUM(TRIGIA)>=(
(SELECT MAX(DOANHSO) AS SL FROM
	(SELECT MONTH(NGHD) AS THANG, SUM(TRIGIA) AS DOANHSO
	FROM HOADON
	WHERE YEAR(NGHD)=2006
	GROUP BY MONTH(NGHD) ) AS A)
	)
--CAU 42:
SELECT MASP, TENSP FROM SANPHAM
WHERE MASP IN(
SELECT SANPHAM.MASP FROM SANPHAM INNER JOIN CTHD ON SANPHAM.MASP=CTHD.MASP
 GROUP BY SANPHAM.MASP HAVING SUM(SL)<=
	(SELECT MIN(SOLUONG) FROM(
	SELECT MASP, SUM(SL) AS SOLUONG
	FROM CTHD
	GROUP BY MASP) AS A))
--CAU 43:
SELECT MASP,TENSP 
FROM SANPHAM AS SP1
WHERE GIA=(SELECT MAX(GIA)
FROM SANPHAM AS SP2
WHERE SP1.NUOCSX=SP2.NUOCSX
GROUP BY NUOCSX)
--CAU 44:
SELECT NUOCSX FROM SANPHAM
GROUP BY NUOCSX
HAVING COUNT(DISTINCT GIA)>=3
--CAU 45:
SELECT *
FROM KHACHHANG
	WHERE MAKH IN 
	(SELECT TOP 1 WITH TIES A.MAKH
	FROM
		(SELECT TOP 10 MAKH
		FROM KHACHHANG
		ORDER BY DOANHSO DESC) AS A
		INNER JOIN 
		(SELECT MAKH, COUNT(SOHD) AS SL
		FROM HOADON
		GROUP BY MAKH) AS B
	ON A.MAKH = B.MAKH
	ORDER BY SL DESC)
--CAU 10:
ALTER TABLE KHACHHANG
ADD CONSTRAINT CHECK_NGDK CHECK(NGDK>NGSINH)

--CAU 11:
--TRIGGER HOADON
CREATE TRIGGER TRG_KH_DH ON HOADON
FOR INSERT, UPDATE
AS
BEGIN
	DECLARE @NGHD SMALLDATETIME, @NGDK SMALLDATETIME,
	@MAKH CHAR(4)
	SELECT @NGHD = NGHD, @MAKH = MAKH FROM inserted
	SELECT @NGDK = NGDK FROM KHACHHANG
	 WHERE MAKH=@MAKH
	IF (@NGDK > @NGHD)
	BEGIN
	PRINT 'LOI. NGAY DANG KY PHAI LON HON NGAY MUA'
	ROLLBACK TRANSACTION
	END
	ELSE
	PRINT 'THANH CONG'
--TRIGGER KHACHHANG
END
CREATE TRIGGER TRG_KH_DH_1 ON KHACHHANG
FOR UPDATE
AS
BEGIN
	DECLARE @NGHD SMALLDATETIME, @NGDK SMALLDATETIME,
	@MAKH CHAR(4)
	SELECT @MAKH = MAKH, @NGDK = NGDK FROM inserted
	SELECT @NGHD = MIN(NGHD) FROM HOADON
	 WHERE MAKH=@MAKH
	IF (@NGDK > @NGHD)
	BEGIN
	PRINT 'LOI. NGAY DANG KY PHAI LON HON NGAY MUA'
	ROLLBACK TRANSACTION
	END
	ELSE
	PRINT 'THANH CONG'
END
--CAU 12:
--TRIGGER HOADON
CREATE TRIGGER TR_HD_NV ON HOADON
FOR INSERT, UPDATE
AS 
BEGIN
	DECLARE @NGVL SMALLDATETIME,@NGHD SMALLDATETIME,@MANV CHAR(4)
	SELECT @NGHD= NGHD,@MANV=MANV FROM inserted
	SELECT @NGVL=NGVL FROM NHANVIEN
	 WHERE MANV=@MANV 
		IF (@NGVL>@NGHD)
			BEGIN
			PRINT'LOI. NGVL PHAI NHO HON NGHD.'
			ROLLBACK TRANSACTION
			END
END
--TRIGGER NHANVIEN
CREATE TRIGGER TR_NV_HD ON NHANVIEN
FOR UPDATE
AS 
BEGIN
	DECLARE @NGVL SMALLDATETIME,@NGHD SMALLDATETIME,@MANV CHAR(4)
	SELECT @NGVL= NGVL,@MANV=MANV FROM inserted
	SELECT @NGHD=MIN(NGHD) FROM HOADON
	 WHERE MANV=@MANV 
		IF (@NGVL>@NGHD)
			BEGIN
			PRINT'LOI. NGVL PHAI NHO HON NGHD.'
			ROLLBACK TRANSACTION
			END
END
--CAU 13:
--TRIGGER CTHOADON
CREATE TRIGGER TRG_DELETE_CTHD ON CTHD
FOR DELETE, UPDATE
AS
BEGIN 
	DECLARE @SOHD INT, @SLHD INT
	SELECT @SOHD=SOHD FROM deleted
	SELECT @SLHD=COUNT(SOHD) FROM CTHD
	WHERE SOHD=@SOHD
		IF(@SLHD<=1)
		BEGIN
		 PRINT'SAI VI VI PHAM RANG BUOC TOAN VEN.'
		ROLLBACK TRANSACTION 
		END
END
--CAU 14:
--INSERT CTHD
CREATE TRIGGER INSERT_CTHD_HD_C14
ON CTHD
FOR INSERT
AS
BEGIN
 DECLARE  @SL  INT,@GIA  MONEY,@SOHD INT

 SELECT @GIA=GIA,@SL=SL,@SOHD=SOHD
 FROM  INSERTED A, SANPHAM B
 WHERE A.MASP=B.MASP

 UPDATE HOADON
 SET  TRIGIA=TRIGIA+@SL*@GIA
 WHERE SOHD=@SOHD
  PRINT'INSERT 1 CTHD THANH CONG'
END
--DELETE CTHD
 CREATE TRIGGER DELETE_CTHD_HD_14
ON CTHD
FOR DELETE
AS
BEGIN
 DECLARE  @SL  INT,@GIA  MONEY,@SOHD INT

 SELECT @GIA=GIA,@SL=SL,@SOHD=SOHD
 FROM  DELETED A, SANPHAM B
 WHERE A.MASP=B.MASP

 UPDATE HOADON
 SET  TRIGIA=TRIGIA-@SL*@GIA
 WHERE SOHD=@SOHD
  PRINT'DELETE CTHD THANH CONG'
END

--UPDATE CTHD MASP,SL
CREATE TRIGGER UPDATE_CTHD_C14
ON CTHD
FOR UPDATE
AS
BEGIN
 DECLARE  @SL_CU INT,
   @SL_MOI INT,   
   @GIA_CU MONEY,@GIA_MOI MONEY,@SOHD INT,@MASP_MOI CHAR(4),@MASP_CU CHAR(4)

 SELECT @MASP_MOI=A.MASP,@GIA_CU=B.GIA,@SL_CU=SL,@SOHD=SOHD
 FROM  deleted A, SANPHAM B
 WHERE A.MASP=B.MASP
 
 SELECT @MASP_CU=B.MASP,@GIA_MOI=B.GIA,@SL_MOI=SL,@SOHD=SOHD
 FROM  inserted A, SANPHAM B
 WHERE A.MASP=B.MASP

 IF(@MASP_CU=@MASP_MOI)
  BEGIN
   UPDATE HOADON
   SET  TRIGIA=TRIGIA+@SL_MOI*@GIA_MOI-@SL_CU*@GIA_CU
   WHERE SOHD=@SOHD
  END
 ELSE
  BEGIN
   UPDATE HOADON
   SET  TRIGIA=TRIGIA-@SL_CU*@GIA_CU
   WHERE SOHD=@SOHD

   UPDATE HOADON
   SET  TRIGIA=TRIGIA+@SL_MOI*@GIA_MOI
   WHERE SOHD=@SOHD
  END
 PRINT'UPDATE 1 CTHD THANH CONG'
END

 --KHONG CHO UPDATE TRI GIA HOADON SAI

 CREATE TRIGGER TRG_UPDATE_HD_C14
 ON HOADON  FOR UPDATE
 AS
BEGIN
 DECLARE @TRIGIA_CU MONEY,@TRIGIA_MOI MONEY,@SOHD INT,@GIA INT, @SL INT,@MASP CHAR(4)
	SELECT @TRIGIA_CU=SUM(B.SL*C.GIA),@SOHD=B.SOHD
	FROM deleted A,CTHD B, SANPHAM C
	WHERE A.SOHD=B.SOHD AND B.MASP=C.MASP
	GROUP BY B.SOHD

	SELECT @TRIGIA_MOI=TRIGIA
	FROM inserted
 IF(@TRIGIA_CU!=@TRIGIA_MOI )
	BEGIN
		PRINT('KHONG THE UPDATE DO SAI TRIGIA.')
		ROLLBACK TRANSACTION
	END
END
--CAU 15:
--UPDATE KHACHHANG DOANHSO
CREATE TRIGGER UPDATE_KHACHHANG_C15
ON KHACHHANG
FOR UPDATE
AS
BEGIN
 DECLARE @MAKH  CHAR(4),@DOANHSO_CU MONEY

 SELECT @MAKH=MAKH
 FROM  inserted
 
 SELECT @DOANHSO_CU=DOANHSO
 FROM  deleted
 
 UPDATE KHACHHANG
 SET  DOANHSO=@DOANHSO_CU
 WHERE MAKH=@MAKH

 PRINT 'DA UPDATE 1 KHACHHANG'
 END

 --INSERT HOADON
CREATE TRIGGER INSERT_HOADON_C15
ON HOADON
FOR INSERT
AS
BEGIN
 DECLARE @TRIGIA MONEY,
   @MAKH CHAR(4)

 SELECT @MAKH=MAKH,@TRIGIA=TRIGIA
 FROM  inserted
 
 UPDATE KHACHHANG
 SET  DOANHSO=DOANHSO+@TRIGIA
 WHERE MAKH=@MAKH

 PRINT 'INSERT HOADON THANH CONG'
END
--DELETE HOADON

CREATE TRIGGER DELETE_HOADON_C15
ON HOADON
FOR DELETE
AS
BEGIN
 DECLARE @TRIGIA MONEY,
   @MAKH CHAR(4)

 SELECT @MAKH=MAKH,@TRIGIA=TRIGIA
 FROM  DELETED
 
 UPDATE KHACHHANG
 SET  DOANHSO=DOANHSO-@TRIGIA
 WHERE MAKH=@MAKH

 PRINT 'DELETE HOADON THANH CONG'
END
--UPDATE TRIGIA HOADON

CREATE TRIGGER UPDATE_HOADON_TRIGIA_C15
ON HOADON
FOR UPDATE
AS
BEGIN
 DECLARE @TRIGIA_CU MONEY,
   @TRIGIA_MOI MONEY,
   @MAKH  CHAR(4)

 SELECT @MAKH=MAKH,@TRIGIA_MOI=TRIGIA
 FROM  inserted

 SELECT @MAKH=MAKH,@TRIGIA_CU=TRIGIA
 FROM  deleted
  
 UPDATE KHACHHANG
 SET  DOANHSO=DOANHSO+@TRIGIA_MOI-@TRIGIA_CU
 WHERE MAKH=@MAKH

 PRINT 'UPDATE 1 HOADON THANH CONG'
END
 --UPDATE MAKH
 CREATE TRIGGER TRG_UPDATE_MAKH_C15
 ON HOADON
 FOR UPDATE
 AS 
 BEGIN
	DECLARE @MAKH_MOI CHAR(4),@MAKH_CU CHAR(4),@TRIGIA_CU INT, @TRIGIA_MOI INT
		SELECT @MAKH_CU=MAKH,@TRIGIA_CU=TRIGIA FROM deleted
		SELECT @MAKH_MOI=MAKH,@TRIGIA_MOI=TRIGIA FROM inserted

		IF(@MAKH_MOI!='Null')
		BEGIN
			UPDATE KHACHHANG
			SET  DOANHSO=DOANHSO-@TRIGIA_CU
			WHERE MAKH=@MAKH_CU

			UPDATE KHACHHANG
			SET  DOANHSO=DOANHSO+@TRIGIA_MOI
			WHERE MAKH=@MAKH_MOI
		PRINT('UPDATE THANH CONG MAKH VA DOANH SO MOI.')
		END
		ELSE
		BEGIN
			PRINT('KHONG UPDATE DUOC DOANH SO CUA MAKH = NULL')
			ROLLBACK TRANSACTION
		END			
 END
