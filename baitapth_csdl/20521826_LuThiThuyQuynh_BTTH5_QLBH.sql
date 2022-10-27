use QLBH

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
