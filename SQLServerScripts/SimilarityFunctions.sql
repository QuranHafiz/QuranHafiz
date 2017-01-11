USE [QuranV2]
GO

-----------------------------------------------------------------------------
-- Helper function to find the minimum of two integers
IF OBJECT_ID(N'ufn_min_int') IS NOT NULL
    DROP FUNCTION dbo.ufn_min_int;
GO

CREATE FUNCTION ufn_min_int(@a as int, @b as int) 
returns int
as
begin
    return case when @a < @b then @a else coalesce(@b,@a) end
end
GO
------------------------------------------------------------------------------

IF OBJECT_ID(N'dbo.ufn_Similarity_Chars_NoOrder_NoRepeteition') IS NOT NULL
    DROP FUNCTION dbo.ufn_Similarity_Chars_NoOrder_NoRepeteition;
GO

CREATE FUNCTION dbo.ufn_Similarity_Chars_NoOrder_NoRepeteition(@Word1 nvarchar(max), @Word2 nvarchar(max))
RETURNS @retSimilarityMeasure TABLE 
-- Find the number of characters that show up in both words
-- Order does not matter
-- each character participates in the comparison only one time
-- if word1= AAB and word2 = BA, NoOfMatchingCharacters=2, NoOfMatchingCharactersInWord1=2, NoOfMatchingCharactersInWord2=2
-- this function returns a table of one row
(
    NoOfMatchingCharacters int NOT NULL,
	NoOfMatchingCharactersInWord1 int NOT NULL,
	NoOfMatchingCharactersInWord2 int NOT NULL,
	PercentageOfMatchingCharactersInWord1 int NOT NULL, -- number between 0 and 100
	PercentageOfMatchingCharactersInWord2 int NOT NULL -- number between 0 and 100
-- Hint: in this case NoOfMatchingCharacters= NoOfMatchingCharactersInString1 = NoOfMatchingCharactersInWord2
-- Percentage is calculated by dividing over the word length
)

BEGIN

	DECLARE  @CharList1 TABLE  (CharacterNoWithinWord int primary key, [Character] nvarchar);
	DECLARE  @CharList2 TABLE  (CharacterNoWithinWord int primary key, [Character] nvarchar);

	INSERT INTO @CharList1 SELECT * from [dbo].[SplitWordIntoCharacters](@Word1) where [Character] <> ' ';
	INSERT INTO @CharList2 SELECT * FROM [dbo].[SplitWordIntoCharacters](@Word2) where [Character] <> ' ';

	DECLARE  @AggregatedCharList1 TABLE  ([Character] nvarchar primary key, [CharacterCount] int);
	DECLARE  @AggregatedCharList2 TABLE  ([Character] nvarchar primary key, [CharacterCount] int);

	INSERT INTO @AggregatedCharList1 
	SELECT [Character], count(*)
	FROM @CharList1
	GROUP BY [Character]


	INSERT INTO @AggregatedCharList2 
	SELECT [Character], count(*)
	FROM @CharList2
	GROUP BY [Character]
	
	INSERT INTO @retSimilarityMeasure 
	SELECT ISNULL(SUM(A.NoOfMatchesPerCharacter), 0), 
		   ISNULL(SUM(A.NoOfMatchesPerCharacter), 0), 
		   ISNULL(SUM(A.NoOfMatchesPerCharacter), 0),
		   ISNULL(SUM(A.NoOfMatchesPerCharacter)*100/LEN(@Word1), 0),
		   ISNULL(SUM(A.NoOfMatchesPerCharacter)*100/LEN(@Word2), 0)
		   FROM 
		   (
				SELECT [dbo].[ufn_min_int](L1.CharacterCount, L2.CharacterCount)  as NoOfMatchesPerCharacter
				FROM @AggregatedCharList1 L1, @AggregatedCharList2 L2
				WHERE L1.[Character] = L2.[Character]
			) A

	RETURN
END

GO
------------------------


IF OBJECT_ID(N'dbo.ufn_Similarity_Words_NoOrder_NoRepeteition') IS NOT NULL
    DROP FUNCTION dbo.ufn_Similarity_Words_NoOrder_NoRepeteition;
GO

CREATE FUNCTION dbo.ufn_Similarity_Words_NoOrder_NoRepeteition(@Sentence1 nvarchar(max), @Sentence2 nvarchar(max))
RETURNS @retSimilarityMeasure TABLE 
-- Find the number of words that show up in both words
-- Order does not matter
-- each word participates in the comparison only one time
-- this function returns a table of one row
(
    NoOfMatchingWords int NOT NULL,
	NoOfMatchingWordsInSentence1 int NOT NULL,
	NoOfMatchingWordsInSentence2 int NOT NULL,
	PercentageOfMatchingWordsInSentence1 int NOT NULL, -- number between 0 and 100
	PercentageOfMatchingWordsInSentence2 int NOT NULL -- number between 0 and 100
-- Hint: in this case NoOfMatchingCharacters= NoOfMatchingCharactersInString1 = PercentageOfMatchingCharactersInWord2
-- Percentage is calculated by dividing over the word length
)

BEGIN

	DECLARE  @WordList1 TABLE  (WordNoWithinAyah int primary key, Word nvarchar(max));
	DECLARE  @WordList2 TABLE  (WordNoWithinAyah int primary key, Word nvarchar(max));

	INSERT INTO @WordList1 SELECT WordNoWithinAyah, Word from [dbo].[SplitAyahIntoWords](@Sentence1);
	INSERT INTO @WordList2 SELECT WordNoWithinAyah, Word FROM [dbo].[SplitAyahIntoWords](@Sentence2);

	DECLARE @NoOfWordsInSentence1 int
	DECLARE @NoOfWordsInSentence2 int
	SELECT @NoOfWordsInSentence1 = COUNT(*) FROM @WordList1
	SELECT @NoOfWordsInSentence2 = COUNT(*) FROM @WordList2

	DECLARE  @AggregatedWordList1 TABLE  (Word nvarchar(max), [WordCount] int);
	DECLARE  @AggregatedWordList2 TABLE  (Word nvarchar(max), [WordCount] int);

	INSERT INTO @AggregatedWordList1 
	SELECT Word, count(*)
	FROM @WordList1
	GROUP BY Word


	INSERT INTO @AggregatedWordList2 
	SELECT Word, count(*)
	FROM @WordList2
	GROUP BY Word
	
	INSERT INTO @retSimilarityMeasure 
	SELECT ISNULL(SUM(A.NoOfMatchesPerWord), 0), 
		   ISNULL(SUM(A.NoOfMatchesPerWord), 0), 
		   ISNULL(SUM(A.NoOfMatchesPerWord), 0),
		   ISNULL(SUM(A.NoOfMatchesPerWord)*100/@NoOfWordsInSentence1, 0),
		   ISNULL(SUM(A.NoOfMatchesPerWord)*100/@NoOfWordsInSentence2, 0)
		   FROM 
		   (
				SELECT [dbo].[ufn_min_int](L1.WordCount, L2.WordCount)  as NoOfMatchesPerWord
				FROM @AggregatedWordList1 L1, @AggregatedWordList2 L2
				WHERE L1.Word = L2.Word
			) A

	RETURN
END
GO

------------------------------------------------------------------------------------------------------------------------
IF OBJECT_ID(N'dbo.ufn_Word_ConnectednessMeasure') IS NOT NULL
    DROP FUNCTION dbo.ufn_Word_ConnectednessMeasure;
GO

CREATE FUNCTION dbo.ufn_Word_ConnectednessMeasure(@Sentence1 nvarchar(max), @Sentence2 nvarchar(max))
RETURNS @retConnectednessMeasure TABLE 
-- 
-- 
-- this function returns a table of one row
(
	DegreeOfConnectednessInSentence1 int NOT NULL,
	DegreeOfConnectednessInSentence2 int NOT NULL
)

BEGIN

	DECLARE  @WordList1 TABLE  (WordNoWithinAyah int primary key, Word nvarchar(max));
	DECLARE  @WordList2 TABLE  (WordNoWithinAyah int primary key, Word nvarchar(max));

	INSERT INTO @WordList1 SELECT WordNoWithinAyah, Word from [dbo].[SplitAyahIntoWords](@Sentence1);
	INSERT INTO @WordList2 SELECT WordNoWithinAyah, Word FROM [dbo].[SplitAyahIntoWords](@Sentence2);

	DECLARE  @MatchingWordList1 TABLE  (WordNoWithinAyah int primary key);
	DECLARE  @MatchingWordList2 TABLE  (WordNoWithinAyah int primary key);


	INSERT INTO @MatchingWordList1 SELECT WordNoWithinAyah FROM @WordList1 WHERE Word IN (SELECT Word from @WordList2);
	INSERT INTO @MatchingWordList2 SELECT WordNoWithinAyah FROM @WordList2 WHERE Word IN (SELECT Word from @WordList1);


	DECLARE @FirstWordNoInSentence1 int
	DECLARE @LastWordNoInSentence1 int
	DECLARE @NoOfMatchesInSentence1 int
	DECLARE @FirstWordNoInSentence2 int
	DECLARE @LastWordNoInSentence2 int
	DECLARE @NoOfMatchesInSentence2 int
	SELECT @FirstWordNoInSentence1 = MIN(WordNoWithinAyah) FROM @MatchingWordList1
	SELECT @LastWordNoInSentence1 = MAX(WordNoWithinAyah) FROM @MatchingWordList1
	SELECT @NoOfMatchesInSentence1 = COUNT(*) FROM @MatchingWordList1
	SELECT @FirstWordNoInSentence2 = MIN(WordNoWithinAyah) FROM @MatchingWordList2
	SELECT @LastWordNoInSentence2 = MAX(WordNoWithinAyah) FROM @MatchingWordList2
	SELECT @NoOfMatchesInSentence2 = COUNT(*) FROM @MatchingWordList2



	INSERT INTO @retConnectednessMeasure values (
		ISNULL(@NoOfMatchesInSentence1*100/(@LastWordNoInSentence1- @FirstWordNoInSentence1 +1), 0), 
		ISNULL(@NoOfMatchesInSentence2*100/(@LastWordNoInSentence2- @FirstWordNoInSentence2 +1), 0)
		)

	RETURN
END
GO
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
--MMMMMMMMMMMMM
--CREATE TYPE PositionTableType 
--AS TABLE (Position int)
--GO 

--CREATE FUNCTION dbo.ufn_GetLargestStretch(@PositionTable PositionTableType READONLY)
--RETURNS @retLargestStretch TABLE 
---- 
---- 
---- this function returns a table of one row
--(
--	DegreeOfConnectednessInSentence1 int NOT NULL,
--	DegreeOfConnectednessInSentence2 int NOT NULL
--)
--BEGIN
--	DECLARE  @I1 int;
--	DECLARE  @I2 int;
--	DECLARE @index int;
--	SET @I1 = -1;
--	SET @I2 = -1;

--	WHILE @index <= LEN(@word) 
--	   BEGIN 
--			 INSERT INTO @characters 
--			 VALUES (@index, SUBSTRING(@word, @index,1))
--			 SET @index = @index+1
--	   END 

--END

------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
-- MMMMMMMMMMMMMMMM
--CREATE FUNCTION dbo.ufn_Word_ConnectednessMeasure_LargestStretch(@Sentence1 nvarchar(max), @Sentence2 nvarchar(max))
--RETURNS @retConnectednessMeasure TABLE 
---- 
---- 
---- this function returns a table of one row
--(
--	DegreeOfConnectednessInSentence1 int NOT NULL,
--	DegreeOfConnectednessInSentence2 int NOT NULL
--)

--BEGIN

--	DECLARE  @WordList1 TABLE  (WordNoWithinAyah int primary key, Word nvarchar(max));
--	DECLARE  @WordList2 TABLE  (WordNoWithinAyah int primary key, Word nvarchar(max));



--	INSERT INTO @WordList1 SELECT WordNoWithinAyah, Word from [dbo].[SplitAyahIntoWords](@Sentence1);
--	INSERT INTO @WordList2 SELECT WordNoWithinAyah, Word FROM [dbo].[SplitAyahIntoWords](@Sentence2);

--	DECLARE  @MatchingWordList1 TABLE  (WordNoWithinAyah int primary key);
--	DECLARE  @MatchingWordList2 TABLE  (WordNoWithinAyah int primary key);


--	INSERT INTO @MatchingWordList1 SELECT WordNoWithinAyah FROM @WordList1 WHERE Word IN (SELECT Word from @WordList2);
--	INSERT INTO @MatchingWordList2 SELECT WordNoWithinAyah FROM @WordList2 WHERE Word IN (SELECT Word from @WordList1);


--	DECLARE @FirstWordNoInSentence1 int
--	DECLARE @LastWordNoInSentence1 int
--	DECLARE @NoOfMatchesInSentence1 int
--	DECLARE @FirstWordNoInSentence2 int
--	DECLARE @LastWordNoInSentence2 int
--	DECLARE @NoOfMatchesInSentence2 int
--	SELECT @FirstWordNoInSentence1 = MIN(WordNoWithinAyah) FROM @MatchingWordList1
--	SELECT @LastWordNoInSentence1 = MAX(WordNoWithinAyah) FROM @MatchingWordList1
--	SELECT @NoOfMatchesInSentence1 = COUNT(*) FROM @MatchingWordList1
--	SELECT @FirstWordNoInSentence2 = MIN(WordNoWithinAyah) FROM @MatchingWordList2
--	SELECT @LastWordNoInSentence2 = MAX(WordNoWithinAyah) FROM @MatchingWordList2
--	SELECT @NoOfMatchesInSentence2 = COUNT(*) FROM @MatchingWordList2



--	INSERT INTO @retConnectednessMeasure values (
--		ISNULL(@NoOfMatchesInSentence1*100/(@LastWordNoInSentence1- @FirstWordNoInSentence1 +1), 0), 
--		ISNULL(@NoOfMatchesInSentence2*100/(@LastWordNoInSentence2- @FirstWordNoInSentence2 +1), 0)
--		)

--	RETURN
--END

------------------------------------------------------------------------------------------------------------------------
IF OBJECT_ID(N'dbo.ufn_Char_ConnectednessMeasure') IS NOT NULL
    DROP FUNCTION dbo.ufn_Char_ConnectednessMeasure;
GO


CREATE FUNCTION dbo.ufn_Char_ConnectednessMeasure(@Word1 nvarchar(max), @Word2 nvarchar(max))
RETURNS @retConnectednessMeasure TABLE 
-- 
-- 
-- this function returns a table of one row
(
	DegreeOfConnectednessInSentence1 int NOT NULL,
	DegreeOfConnectednessInSentence2 int NOT NULL
)

BEGIN

	DECLARE  @CharList1 TABLE  (CharacterNoWithinWord int primary key, [Character] nvarchar);
	DECLARE  @CharList2 TABLE  (CharacterNoWithinWord int primary key, [Character] nvarchar);

	INSERT INTO @CharList1 SELECT * from [dbo].[SplitWordIntoCharacters](REPLACE(@Word1, ' ',''));
	INSERT INTO @CharList2 SELECT * FROM [dbo].[SplitWordIntoCharacters](REPLACE(@Word2, ' ',''));

	DECLARE  @MatchingCharList1 TABLE  (CharacterNoWithinWord int primary key);
	DECLARE  @MatchingCharList2 TABLE  (CharacterNoWithinWord int primary key);


	INSERT INTO @MatchingCharList1 SELECT CharacterNoWithinWord FROM @CharList1 WHERE [Character] IN (SELECT [Character] from @CharList2);
	INSERT INTO @MatchingCharList2 SELECT CharacterNoWithinWord FROM @CharList2 WHERE [Character] IN (SELECT [Character] from @CharList1);


	DECLARE @FirstCharNoInSentence1 int
	DECLARE @LastCharNoInSentence1 int
	DECLARE @NoOfMatchesInSentence1 int
	DECLARE @FirstCharNoInSentence2 int
	DECLARE @LastCharNoInSentence2 int
	DECLARE @NoOfMatchesInSentence2 int
	SELECT @FirstCharNoInSentence1 = MIN(CharacterNoWithinWord) FROM @MatchingCharList1
	SELECT @LastCharNoInSentence1 = MAX(CharacterNoWithinWord) FROM @MatchingCharList1
	SELECT @NoOfMatchesInSentence1 = COUNT(*) FROM @MatchingCharList1
	SELECT @FirstCharNoInSentence2 = MIN(CharacterNoWithinWord) FROM @MatchingCharList2
	SELECT @LastCharNoInSentence2 = MAX(CharacterNoWithinWord) FROM @MatchingCharList2
	SELECT @NoOfMatchesInSentence2 = COUNT(*) FROM @MatchingCharList2



	INSERT INTO @retConnectednessMeasure values (
		ISNULL(@NoOfMatchesInSentence1*100/(@LastCharNoInSentence1- @FirstCharNoInSentence1 +1), 0), 
		ISNULL(@NoOfMatchesInSentence2*100/(@LastCharNoInSentence2- @FirstCharNoInSentence2 +1), 0)
		)

	RETURN
END
GO
------------------------------------------------------------------------------------------------------------------
IF OBJECT_ID(N'dbo.ufn_Word_OutOfOrdernessMeasure') IS NOT NULL
    DROP FUNCTION dbo.ufn_Word_OutOfOrdernessMeasure;
GO



CREATE FUNCTION dbo.ufn_Word_OutOfOrdernessMeasure(@Sentence1 nvarchar(max), @Sentence2 nvarchar(max))
RETURNS int

BEGIN
	DECLARE @Measure int;
	DECLARE  @WordList1 TABLE  (WordNoWithInAyah int primary key, Word nvarchar(max));
	DECLARE  @WordList2 TABLE  (WordNoWithInAyah int primary key, Word nvarchar(max));

	INSERT INTO @WordList1 SELECT  WordNoWithInAyah, Word from [dbo].[SplitAyahIntoWords](@Sentence1);
	INSERT INTO @WordList2 SELECT WordNoWithInAyah, Word FROM [dbo].[SplitAyahIntoWords](@Sentence2);

	DECLARE  @MatchingWordList1 TABLE  (SeqNo int, Word nvarchar(max));
	DECLARE  @MatchingWordList2 TABLE  (SeqNo int, Word nvarchar(max));


	INSERT INTO @MatchingWordList1 
	SELECT ROW_NUMBER() OVER (ORDER BY WordNoWithInAyah), Word 
	FROM @WordList1 WL1
	WHERE WL1.Word IN (SELECT Word from @WordList2)
	and (SELECT COUNT(*) FROM @WordList1 WL1_Self WHERE WL1.Word=WL1_Self.Word and WL1.WordNoWithInAyah>WL1_Self.WordNoWithInAyah) < (SELECT COUNT(*) FROM @WordList2 WL2 WHERE WL1.Word=WL2.Word) ;
	
	
	INSERT INTO @MatchingWordList2 
	SELECT ROW_NUMBER() OVER (ORDER BY WordNoWithInAyah), Word 
	FROM @WordList2 WL2 
	WHERE WL2.Word IN (SELECT Word from @WordList1)
	and (SELECT COUNT(*) FROM @WordList2 WL2_Self WHERE WL2.Word=WL2_Self.Word  and WL2.WordNoWithInAyah>WL2_Self.WordNoWithInAyah) < (SELECT COUNT(*) FROM @WordList1 WL1 WHERE WL2.Word=WL1.Word) ;
	


	DECLARE @NoOfMatchesInSentence1 int
	SELECT @NoOfMatchesInSentence1 = COUNT(*) FROM @MatchingWordList1
	
	IF (@NoOfMatchesInSentence1 = 0)
		SET @Measure = NULL
	ELSE 
		BEGIN
		IF (@NoOfMatchesInSentence1 = 1)
			SET @Measure = 100
		ELSE
			BEGIN 
				DECLARE @OutOfOrderness int;
				SET @OutOfOrderness  = 0;
	
				DECLARE @index int;
				SET @index = 1
				WHILE @index <= @NoOfMatchesInSentence1 
				BEGIN 
					 DECLARE @MatchingSeqNo int;
		 
					 SELECT @MatchingSeqNo=MIN(ML2.SeqNo)
					 FROM @MatchingWordList1 ML1, @MatchingWordList2 ML2
					 WHERE ML1.SeqNo = @index and ML1.Word = ML2.Word and ML2.SeqNo>=@index;

					 SET @OutOfOrderness = @OutOfOrderness + (@MatchingSeqNo - @index);
		 
					 UPDATE @MatchingWordList2
					 SET SeqNo = 0 --@index
					 WHERE SeqNo = @MatchingSeqNo;

					 UPDATE @MatchingWordList2
					 SET SeqNo = SeqNo+1
					 WHERE SeqNo >= @index and SeqNo<@MatchingSeqNo;

					 --swap

					 SET @index = @index+1
				END 

				SET @Measure = 100-@OutOfOrderness*100*2/(@NoOfMatchesInSentence1*(@NoOfMatchesInSentence1-1))
			END
		END

		RETURN @Measure
END
GO
--------------------------------------------------------------------------------------------------------------------
IF OBJECT_ID(N'dbo.ufn_Char_OutOfOrdernessMeasure') IS NOT NULL
    DROP FUNCTION dbo.ufn_Char_OutOfOrdernessMeasure;
GO


CREATE FUNCTION dbo.ufn_Char_OutOfOrdernessMeasure(@Word1 nvarchar(max), @Word2 nvarchar(max))
RETURNS int

BEGIN
	DECLARE @Measure int;
	DECLARE  @CharList1 TABLE  (CharacterNoWithinWord int primary key, [Character] nvarchar);
	DECLARE  @CharList2 TABLE  (CharacterNoWithinWord int primary key, [Character] nvarchar);

	INSERT INTO @CharList1 SELECT * from [dbo].[SplitWordIntoCharacters](REPLACE(@Word1, ' ',''));
	INSERT INTO @CharList2 SELECT * FROM [dbo].[SplitWordIntoCharacters](REPLACE(@Word2, ' ',''));


	DECLARE  @MatchingCharList1 TABLE  (SeqNo int, [Character] nvarchar);
	DECLARE  @MatchingCharList2 TABLE  (SeqNo int, [Character] nvarchar);


	INSERT INTO @MatchingCharList1 
	SELECT ROW_NUMBER() OVER (ORDER BY CharacterNoWithinWord), [Character] 
	FROM @CharList1 CL1
	WHERE CL1.[Character] IN (SELECT [Character] from @CharList2)
	and (SELECT COUNT(*) FROM @CharList1 CL1_Self WHERE CL1.[Character]=CL1_Self.[Character] and CL1.CharacterNoWithinWord>CL1_Self.CharacterNoWithinWord) < (SELECT COUNT(*) FROM @CharList2 CL2 WHERE CL1.[Character]=CL2.[Character]) ;
	
	
	INSERT INTO @MatchingCharList2 
	SELECT ROW_NUMBER() OVER (ORDER BY CharacterNoWithinWord), [Character] 
	FROM @CharList2 CL2 
	WHERE CL2.[Character] IN (SELECT [Character] from @CharList1)
	and (SELECT COUNT(*) FROM @CharList2 CL2_Self WHERE CL2.[Character]=CL2_Self.[Character] and CL2.CharacterNoWithinWord>CL2_Self.CharacterNoWithinWord) < (SELECT COUNT(*) FROM @CharList1 CL1 WHERE CL2.[Character]=CL1.[Character]) ;
	
	--DECLARE @v1 xml = (SELECT * from @MatchingCharList1 for xml auto)
	--DECLARE @v2 xml = (SELECT * from @MatchingCharList2 for xml auto)

	DECLARE @NoOfMatchesInWord1 int
	SELECT @NoOfMatchesInWord1 = COUNT(*) FROM @MatchingCharList1

	--DECLARE @NoOfMatchesInWord2 int
	--SELECT @NoOfMatchesInWord2 = COUNT(*) FROM @MatchingCharList2

	
	IF (@NoOfMatchesInWord1 = 0)
		SET @Measure = NULL
	ELSE 
		BEGIN
			IF (@NoOfMatchesInWord1 = 1)
				SET @Measure = 100
			ELSE
				BEGIN
					DECLARE @OutOfOrderness int;
					SET @OutOfOrderness  = 0;
	
					DECLARE @index int;
					SET @index = 1
					WHILE @index <= @NoOfMatchesInWord1 
					BEGIN 
						 DECLARE @MatchingSeqNo int;
		 
						 SELECT @MatchingSeqNo=MIN(ML2.SeqNo)
						 FROM @MatchingCharList1 ML1, @MatchingCharList2 ML2
						 WHERE ML1.SeqNo = @index and ML1.[Character] = ML2.[Character] and ML2.SeqNo>=@index;

						 SET @OutOfOrderness = @OutOfOrderness + (@MatchingSeqNo - @index);
		 
						 UPDATE @MatchingCharList2
						 SET SeqNo = 0  --@index
						 WHERE SeqNo = @MatchingSeqNo;

						 UPDATE @MatchingCharList2
						 SET SeqNo = SeqNo+1
						 WHERE SeqNo >= @index and SeqNo<@MatchingSeqNo;


						 SET @index = @index+1
					END 

					SET @Measure = 100-@OutOfOrderness*100*2/(@NoOfMatchesInWord1*(@NoOfMatchesInWord1-1))
				END
			END
		RETURN @Measure
END
