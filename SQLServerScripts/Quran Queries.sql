USE [QuranV22]
GO

-- Simple queries to dump table contents
-----------------------------------------
select * from dbo.[N1-Juzs]
order by RubSerialNo;

select J.RubSerialNo, J.JuzNo, J.FirstAyahSerialNo, S1.SurahName, A1.Ayah, J.LastAyahSerialNo, S2.SurahName, A2.Ayah
from dbo.[N1-Juzs] J, dbo.[N1-Ayahs] A1, dbo.[N1-Ayahs] A2, dbo.[N1-Surahs] S1, dbo.[N1-Surahs] S2
where J.FirstAyahSerialNo = A1.AyahSerialNo and A1.SurahSerialNo = S1.SurahSerialNo
and J.LastAyahSerialNo = A2.AyahSerialNo and A2.SurahSerialNo = S2.SurahSerialNo
order by J.RubSerialNo;

select * from dbo.[N1-Surahs];

select S.SurahSerialNo, S.SurahName, S.FirstAyahSerialNo, J1.JuzNo, J1.RubNoWithinJuz, A1.Ayah, S.LastAyahSerialNo, J2.JuzNo, J2.RubNoWithinJuz, A2.Ayah
from dbo.[N1-Surahs] S, dbo.[N1-Ayahs] A1, dbo.[N1-Ayahs] A2, dbo.[N1-Juzs] J1, dbo.[N1-Juzs] J2
where S.FirstAyahSerialNo = A1.AyahSerialNo and A1.RubSerialNo = J1.RubSerialNo
and S.LastAyahSerialNo = A2.AyahSerialNo and A2.RubSerialNo = J2.RubSerialNo
order by S.SurahSerialNo;

select S.SurahSerialNo, S.SurahName, P.Place from dbo.[N1-Surahs] S inner join dbo.PlaceOfRevelation P on S.PlaceOfRevelation=P.PlaceId;


select SajdahSerialNo, [AyahSerialNo_ReasonOfSojod], [AyahSerialNo_PlaceOfSojod], SurahSerialNo, [AyahNoWithinSurah_ReasonOfSojod], ReasonOfSojod, [AyahNoWithinSurah_PlaceOfSojod] from dbo.[N1-Sajdahs];

select S.SajdahSerialNo, S.[AyahSerialNo_ReasonOfSojod], A1.Ayah as [Ayah_ReasonOfSojod], S.[AyahSerialNo_PlaceOfSojod], A2.Ayah  as [Ayah_PlaceOfSojod], S.SurahSerialNo, Su.SurahName, S.[AyahNoWithinSurah_ReasonOfSojod], S.ReasonOfSojod, S.[AyahNoWithinSurah_PlaceOfSojod] 
from dbo.[N1-Sajdahs] S, dbo.[N1-Ayahs] A1, dbo.[N1-Ayahs] A2, dbo.[N1-Surahs] Su
where s.SurahSerialNo= su.SurahSerialNo and s.AyahSerialNo_ReasonOfSojod=A1.AyahSerialNo and s.AyahSerialNo_PlaceOfSojod=A2.AyahSerialNo;


select * from dbo.PlaceOfRevelation;

select * from dbo.[N1-Ayahs];

select * from dbo.[N1-Words];

select * from dbo.[N1-Characters];

select * from dbo.UniCodeCharacters;

select WSC.DecimalUniCode, master.dbo.fn_varbintohexstr(WSC.DecimalUniCode) HexUniCode, NCHAR(WSC.DecimalUniCode) UniCodeCharacter from dbo.[UniCodeCharacters_WhiteSpaceCharacters] WSC;

select C.DecimalUniCode, C.HexUniCode, C.UniCodeCharacter from dbo.[UniCodeCharacters_letters] LC JOIN  dbo.UniCodeCharacters C ON LC.DecimalUniCode = C.DecimalUniCode;

select C.DecimalUniCode, C.HexUniCode, C.UniCodeCharacter from dbo.[UniCodeCharacters_Tashkeel] TC JOIN  dbo.UniCodeCharacters C ON TC.DecimalUniCode = C.DecimalUniCode;

select C.DecimalUniCode, C.HexUniCode, C.UniCodeCharacter  from dbo.[UniCodeCharacters_OtherCharacters] OC JOIN  dbo.UniCodeCharacters C ON OC.DecimalUniCode = C.DecimalUniCode;
-------------------------------------------------------------------
-------------------------------------------------------------------
-- Count queries
---------------------------

-- Count number of ayat in Quran
select count(*) 
from dbo.[N1-Ayahs];

-- Count number of words in Quran
select count(*) 
from [N1-Words];

-- Count number of all characters in Quran
select count(*) 
from [N1-Characters];

-- Count number of characters in Quran (not incuding tashkeel and special characters)
select count(*) 
from [N1-Characters] C
where UniCode(C.[Character]) in 
(
	select UCCL.DecimalUniCode
	from [UniCodeCharacters_letters] UCCL
);

-- Count number of Ayat per surah
select SurahSerialNo, count(*)
from dbo.[N1-Ayahs]
group by SurahSerialNo
order by SurahSerialNo;


-- Count number of words per surah
select SurahSerialNo, count(*)
from dbo.[N1-Ayahs] QI, [N1-Words] W
where QI.AyahSerialNo = w.AyahSerialNo
group by SurahSerialNo
order by SurahSerialNo;

-- Count number of all characters per surah
select SurahSerialNo, count(*)
from dbo.[N1-Ayahs] QI, [N1-Words] W, [N1-Characters] C
where QI.AyahSerialNo = w.AyahSerialNo and w.WordSerialNo = C.WordSerialNo
group by SurahSerialNo
order by SurahSerialNo;

-- Count number of all characters per surah (not incuding tashkeel and special characters)
select QI.SurahSerialNo, count(*)
from dbo.[N1-Ayahs] QI, [N1-Words] W, [N1-Characters] C
where QI.AyahSerialNo = w.AyahSerialNo and w.WordSerialNo = C.WordSerialNo
and UniCode(C.[Character]) in 
(
	select UCCL.DecimalUniCode
	from [UniCodeCharacters_letters] UCCL
)
group by SurahSerialNo
order by SurahSerialNo;
-------------------------------------------------------
-- Find Ayah with specific text
-------------------------------
SELECT A.AyahSerialNo, A.Ayah, S.SurahSerialNo, S.SurahName, A.AyahNoWithinSurah, J.JuzNo, J.RubNoWithinJuz
FROM dbo.[N1-Ayahs] A, dbo.[N1-Juzs] J, dbo.[N1-Surahs] S
where A.RubSerialNo=J.RubSerialNo and A.SurahSerialNo=S.SurahSerialNo
and [Ayah] LIKE '%'+N'بَرَاءَةٌ'+'%'
--and [Ayah] LIKE N'بَرَاءَةٌ'+'%'
ORDER BY A.AyahSerialNo
GO


SELECT QI.AyahSerialNo, QI.Ayah, S.SurahSerialNo, S.SurahName, QI.AyahNoWithinSurah, J.JuzNo, J.RubNoWithinJuz
FROM dbo.[N1-Ayahs] QI, dbo.[N1-Juzs] J, dbo.[N1-Surahs] s
where QI.RubSerialNo=J.RubSerialNo and QI.SurahSerialNo=S.SurahSerialNo
--and CONTAINS([Ayah], N'بَرَاءَةٌ')
--and FREETEXT([Ayah], N'بَرَاءَةٌ')
--and FREETEXT([Ayah], N'الرَّحْمَٰنِ الرَّحِيم')
and FREETEXT([Ayah], N'تَرَىٰ ')
--and FREETEXT([Ayah], N'تَرىٰ')
ORDER BY QI.AyahSerialNo
GO

-- Ayat with 10 kafs
-------------------------
select QI.AyahSerialNo, QI.SurahSerialNo, S.SurahName, QI.Ayah, count(*)
from dbo.[N1-Characters] C, dbo.[N1-Words] w, dbo.[N1-Ayahs] QI, dbo.[N1-Surahs] S
where UNICODE(C.Character) = 1602
and C.WordSerialNo = W.WordSerialNo and W.AyahSerialNo=QI.AyahSerialNo and QI.SurahSerialNo = S.SurahSerialNo
group by QI.AyahSerialNo, QI.SurahSerialNo, S.SurahName, QI.Ayah
Having count(*) =10
order by AyahSerialNo

----------------------------------
-- Get ayahs of a specifc surah
SELECT *
FROM dbo.[N1-Ayahs] A
where A.SurahSerialNo = 73
ORDER BY A.AyahSerialNo

-- Get words of a specific surah
SELECT *
FROM dbo.[N1-Words] W, dbo.[N1-Ayahs] A
where W.AyahSerialNo = A.AyahSerialNo and A.SurahSerialNo = 73
ORDER BY W.WordSerialNo

---------------------------------------------------------
---------------------------------------------------------

