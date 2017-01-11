USE [QuranV2]
GO

-----------------------------------------------------------------------
-- Ayahs that came exactly the same way in different surahs
select QI.Ayah, count(*)
from dbo.[N1-Ayahs] QI
group by QI.Ayah
Having count(*)>1
GO


select DENSE_RANK() OVER (ORDER BY QI.Ayah) AS RowFilter,
	   QI.Ayah, A.NoOfOccurrences, S.SurahSerialNo, S.SurahName, AyahNoWithinSurah
from dbo.[N1-Ayahs] QI
inner join
(select QI.Ayah, count(*) as NoOfOccurrences
from dbo.[N1-Ayahs] QI
group by QI.Ayah
Having count(*)>1
) A on QI.Ayah = A.Ayah
inner join dbo.[N1-Surahs] S on QI.SurahSerialNo = S.SurahSerialNo
order by Ayah, S.SurahSerialNo, AyahNoWithinSurah
--order by S.SurahSerialNo, AyahNoWithinSurah
-----------------------------------------------------------------------------------------------
-- Ayat that is similar based on word comaprison, no order, no repetition

select top 1000 s1.SurahName, a1.Ayah, s2.SurahName, a2.Ayah, 
					sim.NoOfMatchingWords, sim.PercentageOfMatchingWordsInSentence1, sim.PercentageOfMatchingWordsInSentence2,
					sim.Connectedness1, sim.Connectedness2,
					sim.DegreeOfOrderness
from dbo.[N1-Ayahs] a1, dbo.[N1-Ayahs] a2, dbo.[N1-Surahs] s1,  dbo.[N1-Surahs] s2, [dbo].[Similarity_Wordbased_NoOrder_NoRepetetion] sim
where sim.AyahSerialNo1 = a1.AyahSerialNo
and sim.AyahSerialNo2 = a2.AyahSerialNo
and a1.SurahSerialNo = s1.SurahSerialNo
and a2.SurahSerialNo = s2.SurahSerialNo
and sim.PercentageOfMatchingWordsInSentence1 > 60
and sim.PercentageOfMatchingWordsInSentence2 > 70

-----------------------------------------------------------------------------------------------
-- Ayat that is similar based on charachter comaprison, no order, no repetition

select top 1000 s1.SurahName, a1.Ayah, s2.SurahName, a2.Ayah, 
			sim.NoOfMatchingChars, sim.PercentageOfMatchingCharsInSentence1, sim.PercentageOfMatchingCharsInSentence2,
			sim.Connectedness1, sim.Connectedness2,
			sim.DegreeOfOrderness
from dbo.[N1-Ayahs] a1, dbo.[N1-Ayahs] a2, dbo.[N1-Surahs] s1,  dbo.[N1-Surahs] s2, [dbo].[Similarity_Charbased_NoOrder_NoRepetetion] sim
where sim.AyahSerialNo1 = a1.AyahSerialNo
and sim.AyahSerialNo2 = a2.AyahSerialNo
and a1.SurahSerialNo = s1.SurahSerialNo
and a2.SurahSerialNo = s2.SurahSerialNo
and sim.PercentageOfMatchingCharsInSentence1 > 90
and sim.PercentageOfMatchingCharsInSentence2 > 70
-----------------------------------------------------------------------------------------------
