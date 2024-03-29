﻿CREATE DATABASE QLGV
USE QLGV

--PHAN III


--CAU 17:
SELECT HOCVIEN.*, DIEM AS 'DIEM CSDL CUOI CUNG'
FROM HOCVIEN INNER JOIN KETQUATHI ON HOCVIEN.MAHV=KETQUATHI.MAHV
WHERE MAMH='CSDL' AND 
LANTHI= ( SELECT MAX(LANTHI) FROM KETQUATHI WHERE HOCVIEN.MAHV=KETQUATHI.MAHV AND MAMH='CSDL'  GROUP BY KETQUATHI.MAHV)  
--CAU 18:
SELECT HOCVIEN.*, DIEM AS DIEM_CSDL_CAONHAT
FROM HOCVIEN INNER JOIN KETQUATHI ON KETQUATHI.MAHV=HOCVIEN.MAHV
WHERE MAMH='CSDL' AND DIEM= 
	(SELECT MAX(DIEM) FROM KETQUATHI  
	WHERE HOCVIEN.MAHV=KETQUATHI.MAHV AND MAMH='CSDL'
	GROUP BY KETQUATHI.MAHV)
--CAU 19:
SELECT MAKHOA,TENKHOA
FROM KHOA
WHERE NGTLAP =(SELECT MIN(NGTLAP) FROM KHOA)
--CAU 20:
SELECT COUNT(*) AS 'SO GV CO HOC HAM GS VA PGS'
FROM GIAOVIEN
WHERE HOCHAM IN('GS','PGS')
--CAU 21:
SELECT MAKHOA,COUNT(*) AS SO_GV
FROM GIAOVIEN
WHERE HOCVI IN('CN', 'KS', 'Ths', 'TS', 'PTS')
GROUP BY MAKHOA
--CAU 22:
SELECT MAMH,KQUA,COUNT(*) AS SOHV
FROM KETQUATHI
GROUP BY MAMH,KQUA
ORDER BY MAMH
--CAU 23:
SELECT DISTINCT GIAOVIEN.MAGV, HOTEN
FROM GIAOVIEN, GIANGDAY,LOP
WHERE GIANGDAY.MAGV=GIAOVIEN.MAGV AND
LOP.MAGVCN=GIAOVIEN.MAGV
--CAU 24:
SELECT CONCAT(HO,' ',TEN) AS HOTEN
FROM HOCVIEN
INNER JOIN LOP ON LOP.MALOP=HOCVIEN.MALOP
WHERE HOCVIEN.MAHV=LOP.TRGLOP AND LOP.SISO >=(SELECT MAX(SISO) FROM LOP )
--CAU 25:
SELECT CONCAT(HO,' ',TEN) AS HOTEN
FROM HOCVIEN, LOP,KETQUATHI
WHERE HOCVIEN.MAHV=LOP.TRGLOP
AND KETQUATHI.MAHV=HOCVIEN.MAHV
AND KQUA='Khong Dat'
GROUP BY HO,TEN
HAVING COUNT(*)>3
--CAU 26:
SELECT TOP 1 WITH TIES
HOCVIEN.MAHV,CONCAT(HO,' ',TEN) AS HOTEN
FROM HOCVIEN INNER JOIN KETQUATHI ON HOCVIEN.MAHV=KETQUATHI.MAHV
WHERE DIEM>=9
GROUP BY HO,TEN,HOCVIEN.MAHV
ORDER BY COUNT(*) DESC
--CAU 27:
SELECT MALOP,A.MAHV, HOTEN
FROM
(SELECT HOCVIEN.MAHV,MALOP,CONCAT(HO,' ',TEN) AS HOTEN, COUNT(*) AS SO_LUONG, DENSE_RANK() OVER (PARTITION BY MALOP ORDER BY COUNT(*) DESC) AS XEPHANG
FROM HOCVIEN INNER JOIN KETQUATHI ON HOCVIEN.MAHV=KETQUATHI.MAHV
WHERE DIEM>=9
GROUP BY MALOP,HOCVIEN.MAHV,HO,TEN
) AS A
WHERE XEPHANG=1
--CAU 28:
SELECT MAGV, COUNT(DISTINCT MAMH) AS 'SO MON', COUNT(DISTINCT MALOP) AS 'SO LOP',NAM,HOCKY
FROM GIANGDAY
GROUP BY MAGV,HOCKY,NAM
--CAU 29:
SELECT NAM,HOCKY, A.MAGV, HOTEN
FROM GIAOVIEN,
(
	SELECT HOCKY, NAM, MAGV,COUNT(*) AS SO_LOP, DENSE_RANK() OVER (PARTITION BY HOCKY, NAM ORDER BY COUNT(*) DESC) AS XEPHANG
	FROM GIANGDAY
	GROUP BY HOCKY, NAM, MAGV
) AS A
WHERE A.MAGV = GIAOVIEN.MAGV AND XEPHANG = 1
ORDER BY NAM, HOCKY
--CAU 30:
SELECT TOP 1 WITH TIES MONHOC.MAMH, TENMH
FROM MONHOC INNER JOIN KETQUATHI ON MONHOC.MAMH = KETQUATHI.MAMH
WHERE LANTHI = 1 AND KQUA = 'Khong Dat'
GROUP BY MONHOC.MAMH, TENMH
ORDER BY COUNT(*) DESC
--CAU 31:
	SELECT HOCVIEN.MAHV, CONCAT(HO,' ',TEN) AS HOTEN
	FROM HOCVIEN 
	INNER JOIN KETQUATHI ON KETQUATHI.MAHV=HOCVIEN.MAHV 
EXCEPT
	(SELECT HOCVIEN.MAHV, CONCAT(HO,' ',TEN) AS HOTEN
	FROM HOCVIEN 
	INNER JOIN KETQUATHI ON KETQUATHI.MAHV=HOCVIEN.MAHV
	WHERE LANTHI=1 AND KQUA='Khong Dat')
--CAU 32:
	SELECT HOCVIEN.MAHV, CONCAT(HO,' ',TEN) AS HOTEN
	FROM HOCVIEN 
	INNER JOIN KETQUATHI ON KETQUATHI.MAHV=HOCVIEN.MAHV 
EXCEPT
	(SELECT HOCVIEN.MAHV, CONCAT(HO,' ',TEN) AS HOTEN
	FROM HOCVIEN 
	INNER JOIN KETQUATHI ON KETQUATHI.MAHV=HOCVIEN.MAHV
	WHERE LANTHI=(SELECT MAX(LANTHI) FROM KETQUATHI WHERE KETQUATHI.MAHV=HOCVIEN.MAHV GROUP BY MAHV) AND KQUA='Khong Dat')
--CAU 33:
-- THI HẾT TẤT CẢ MÔN HỌC LẦN THỨ NHẤT ĐỀU ĐẠT. Bởi vì chỉ có 4 môn học trong bảng kqt thay vì 14 môn nên kết quả sẽ không có ai hết 
SELECT MAHV, CONCAT(HO,' ',TEN) AS HOTEN
FROM HOCVIEN WHERE MAHV IN(
SELECT DISTINCT MAHV
FROM KETQUATHI A
WHERE NOT EXISTS
( SELECT * 
	FROM MONHOC AS C
	WHERE NOT EXISTS(
		SELECT* 
		FROM KETQUATHI B
		WHERE B.MAMH=C.MAMH
		AND B.MAHV=A.MAHV
		AND LANTHI =1
		AND KQUA='DAT'
	)
))

--CAU 34: 
SELECT MAHV, CONCAT(HO,' ',TEN) AS HOTEN
FROM HOCVIEN WHERE MAHV IN(
SELECT DISTINCT MAHV
FROM KETQUATHI A
WHERE NOT EXISTS
( SELECT * 
	FROM MONHOC AS C
	WHERE NOT EXISTS(
		SELECT* 
		FROM KETQUATHI B
		WHERE B.MAMH=C.MAMH
		AND B.MAHV=A.MAHV
		AND LANTHI =(SELECT MAX(LANTHI) FROM KETQUATHI WHERE KETQUATHI.MAHV=A.MAHV GROUP BY MAHV)
		AND KQUA='DAT'
	)
))
--CAU 35:
SELECT MAMH,A.MAHV,HOTEN
FROM (
	SELECT MAMH,KETQUATHI.MAHV,CONCAT(HO,' ',TEN) AS HOTEN, DENSE_RANK() OVER(PARTITION BY MAMH ORDER BY MAX(DIEM) DESC) AS XEPHANG
	FROM KETQUATHI INNER JOIN HOCVIEN ON HOCVIEN.MAHV=KETQUATHI.MAHV
	WHERE LANTHI=(SELECT MAX(LANTHI) FROM KETQUATHI WHERE KETQUATHI.MAHV=HOCVIEN.MAHV GROUP BY MAHV)
	GROUP BY MAMH,KETQUATHI.MAHV,HO,TEN
) AS A
WHERE A.XEPHANG=1
