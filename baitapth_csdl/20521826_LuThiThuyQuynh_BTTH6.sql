CREATE DATABASE QLDKH
use QLDKH
CREATE TABLE SINHVIEN
(
	MSSV CHAR(3) PRIMARY KEY ,
	HOTEN VARCHAR(40),
	NGAYSINH SMALLDATETIME,
	GIOITINH VARCHAR(3),
	DIACHI VARCHAR(40),
	MANGANH CHAR(3)
	 
)
CREATE TABLE NGANH 
(
	MANGANH CHAR(3) PRIMARY KEY,
	TENNGANH VARCHAR(40),
	SOSVTHEOHOC INT
)
CREATE TABLE CHUYENDE(
	MACD CHAR(3) PRIMARY KEY,
	TENCD VARCHAR(40),
	SOSVTOIDA INT,
	MANGANH VARCHAR(3)
)
CREATE TABLE DANGKY(
	MACD CHAR(3),
	MSSV CHAR(3),
	HOCKY TINYINT,
	PRIMARY KEY(MACD,MSSV),
	NAM SMALLINT
)
CREATE TABLE PHANCONG(
	MACD CHAR(3),
	MANGANH CHAR(3),
	HOCKY TINYINT,
	PRIMARY KEY(MACD,MANGANH),
	NAM SMALLINT
)
ALTER TABLE SINHVIEN ADD CONSTRAINT FK_SV_NG FOREIGN KEY(MANGANH) REFERENCES NGANH(MANGANH) 
ALTER TABLE CHUYENDE ADD CONSTRAINT FK_CD_NG FOREIGN KEY(MACD) REFERENCES CHUYENDE(MACD)
ALTER TABLE DANGKY ADD CONSTRAINT FK_DK_CD FOREIGN KEY(MACD) REFERENCES CHUYENDE(MACD)
ALTER TABLE DANGKY ADD CONSTRAINT FK_DK_SV FOREIGN KEY(MSSV) REFERENCES SINHVIEN(MSSV)
ALTER TABLE PHANCONG ADD CONSTRAINT FK_PC_CD FOREIGN KEY(MACD) REFERENCES CHUYENDE(MACD)
ALTER TABLE PHANCONG ADD CONSTRAINT FK_PC_NG FOREIGN KEY(MANGANH) REFERENCES NGANH(MANGANH)

ALTER TABLE SINHVIEN ADD CONSTRAINT CHECK_GTHV CHECK (GIOITINH IN ('Nam', 'Nu'))
ALTER TABLE DANGKY ADD CONSTRAINT CHECK_SOHK CHECK (HOCKY IN (1, 2))
ALTER TABLE CHUYENDE ADD CONSTRAINT CHECK_SOSVMAX CHECK (SOSVTOIDA>5)

--TRIGGER:
CREATE TRIGGER TRG_CHUYENDE_SODK
ON DANGKY
FOR INSERT, UPDATE
AS
BEGIN

       DECLARE @MSSV CHAR(3), @SLCD INT, @MANGANH CHAR(3), @HOCKY TINYINT, @NAM SMALLINT
       SELECT @MSSV = MSSV, @HOCKY = HOCKY, @NAM = NAM FROM inserted
       SELECT @MANGANH = MANGANH FROM SINHVIEN
       WHERE MSSV = @MSSV
       SELECT @SLCD = COUNT(MACD) FROM DANGKY
       WHERE MSSV = @MSSV AND HOCKY = @HOCKY AND NAM = @NAM
       IF(@SLCD >= 3)
       BEGIN
              PRINT 'LOI VI PHAM RANG BUOC.KHONG INSERT DUOC!'
              ROLLBACK TRANSACTION
       END

END
SET DATEFORMAT DMY
--Nhap SV:
INSERT INTO SINHVIEN(MSSV, HOTEN, GIOITINH,DIACHI,NGAYSINH,MANGANH) VALUES('S01','Nguyen  A','Nam','TP HCM','13/6/2000','N01')
INSERT INTO SINHVIEN(MSSV, HOTEN, GIOITINH,DIACHI,NGAYSINH,MANGANH) VALUES('S02','Nguyen  B','Nu','TP HCM','12/4/2002','N02')
INSERT INTO SINHVIEN(MSSV, HOTEN, GIOITINH,DIACHI,NGAYSINH,MANGANH) VALUES('S03','Nguyen  C','Nam','TP HCM','10/8/2000','N03')
INSERT INTO SINHVIEN(MSSV, HOTEN, GIOITINH,DIACHI,NGAYSINH,MANGANH) VALUES('S04','Nguyen  D','Nam','TP HCM','13/9/2002','N02')

--Nhap Nganh:
INSERT INTO NGANH(MANGANH,TENNGANH,SOSVTHEOHOC) VALUES('N01','TOAN',1)
INSERT INTO NGANH(MANGANH,TENNGANH,SOSVTHEOHOC) VALUES('N02','VAN HOC',2)
INSERT INTO NGANH(MANGANH,TENNGANH,SOSVTHEOHOC) VALUES('N03','TIENG ANH',1)

--Nhap Chuyen de:
INSERT INTO CHUYENDE(MACD,TENCD,SOSVTOIDA,MANGANH) VALUES('C01','TOAN DC',10,'N01')
INSERT INTO CHUYENDE(MACD,TENCD,SOSVTOIDA,MANGANH) VALUES('C02','VAN DC',12,'N02')
INSERT INTO CHUYENDE(MACD,TENCD,SOSVTOIDA,MANGANH) VALUES('C03','AV DC',15,'N03')
INSERT INTO CHUYENDE(MACD,TENCD,SOSVTOIDA,MANGANH) VALUES('C04','VAN DC 1',12,'N02')
--Nhap dang ky:
INSERT INTO DANGKY(MACD,MSSV,NAM,HOCKY) VALUES('C01','S01',2021,1)
INSERT INTO DANGKY(MACD,MSSV,NAM,HOCKY) VALUES('C02','S02',2021,1)
INSERT INTO DANGKY(MACD,MSSV,NAM,HOCKY) VALUES('C03','S03',2021,1)
INSERT INTO DANGKY(MACD,MSSV,NAM,HOCKY) VALUES('C04','S04',2021,2)
--Nhap Phan cong:
INSERT INTO PHANCONG(MACD,MANGANH,NAM,HOCKY) VALUES('C01','N01',2021,1)
INSERT INTO PHANCONG(MACD,MANGANH,NAM,HOCKY) VALUES('C02','N02',2021,1)
INSERT INTO PHANCONG(MACD,MANGANH,NAM,HOCKY) VALUES('C03','N03',2021,1)
INSERT INTO PHANCONG(MACD,MANGANH,NAM,HOCKY) VALUES('C04','N02',2021,2)
-- BAI 5:
--CAU A:
SELECT * FROM PHANCONG
WHERE NAM=2021 AND HOCKY=2
--CAU B:
SELECT COUNT(MACD) AS 'SO CHUYEN DE',MANGANH FROM PHANCONG
WHERE NAM=2021 AND HOCKY=2
GROUP BY MANGANH
--CAU C:
SELECT MANGANH
FROM PHANCONG
WHERE NAM=2021 AND HOCKY=2
GROUP BY MANGANH
HAVING COUNT(MACD)>=(
SELECT MAX(SO_CD)
FROM
(SELECT COUNT(MACD) AS SO_CD,MANGANH FROM PHANCONG
WHERE NAM=2021 AND HOCKY=2
GROUP BY MANGANH) AS A)

--CAU D:
SELECT R1.MACD
FROM DANGKY R1 
WHERE NOT EXISTS (
       SELECT *
       FROM SINHVIEN S
	   WHERE S.MANGANH='N02' AND
        NOT EXISTS (
           SELECT *
           FROM DANGKY R2
           WHERE R2.MSSV=S.MSSV AND R2.MACD=R1.MACD AND R2.HOCKY=1 AND R2.NAM=2021)
		   )