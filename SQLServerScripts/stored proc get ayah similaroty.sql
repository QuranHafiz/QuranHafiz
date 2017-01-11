USE QuranV2
GO

IF OBJECT_ID(N'dbo.getAyahSimilarity') IS NOT NULL
    DROP FUNCTION dbo.getAyahSimilarity;
GO

CREATE FUNCTION dbo.getAyahSimilarity(@surahNumber int, @ayahNumber int, @sentence1Percentage int, @sentence2Percentage int, @connectedness1 int, @connectedness2 int, @orderness int)
RETURNS @retSimilarAyahs TABLE 
(
    SurahName nvarchar(255) NOT NULL, 
    AyahNoWithinSurah int NOT NULL, 
    Ayah nvarchar(255) NOT NULL
)
AS 
BEGIN
	INSERT INTO @retSimilarAyahs 
	select SurahName, AyahNoWithinSurah, Ayah 
	from [n1-ayahs] a Join [n1-surahs] s on a.SurahSerialNo = s.SurahSerialNo
	where AyahSerialNo  in
    ( 
		SELECT AyahSerialNo2 FROM [similarity_wordbased_noorder_norepetetion] 
			where AyahSerialNo1 = 
			(SELECT AyahSerialNo FROM [n1-ayahs] where SurahSerialNo= @surahNumber 
				and AyahNoWithinSurah= @ayahNumber) 
			and PercentageOfMatchingWordsInSentence1 >= @sentence1Percentage
			AND PercentageOfMatchingWordsInSentence2 >= @sentence2Percentage
            AND Connectedness1 >= @connectedness1
            AND Connectedness2 >= @connectedness2
            AND DegreeOfOrderness >= @orderness
            
	);
	RETURN;
END



CREATE PROCEDURE dbo.getAyahSimilarity2(@surahNumber int, @ayahNumber int, @sentence1Percentage int, @sentence2Percentage int, @connectedness1 int, @connectedness2 int, @orderness int)
AS 
BEGIN
	select SurahName, AyahNoWithinSurah, Ayah 
	from [n1-ayahs] a Join [n1-surahs] s on a.SurahSerialNo = s.SurahSerialNo
	where AyahSerialNo  in
    ( 
		SELECT AyahSerialNo2 FROM [similarity_wordbased_noorder_norepetetion] 
			where AyahSerialNo1 = 
			(SELECT AyahSerialNo FROM [n1-ayahs] where SurahSerialNo= @surahNumber 
				and AyahNoWithinSurah= @ayahNumber) 
			and PercentageOfMatchingWordsInSentence1 >= @sentence1Percentage
			AND PercentageOfMatchingWordsInSentence2 >= @sentence2Percentage
            AND Connectedness1 >= @connectedness1
            AND Connectedness2 >= @connectedness2
            AND DegreeOfOrderness >= @orderness
            
	);
END

EXEC dbo.getAyahSimilarity2 1,1,50,50,0,0,0 