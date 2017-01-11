USE [QuranV2]
GO

/****** Object:  Table [dbo].[new_table]    Script Date: 2/2/2016 8:25:29 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--------------------------------------------------------------------
--------------------------------------------------------------------
CREATE TABLE [dbo].[Similarity_Wordbased_NoOrder_NoRepetetion](
	[AyahSerialNo1] [int] NOT NULL,
	[AyahSerialNo2] [int] NOT NULL,
	[NoOfMatchingWords] [int] NOT NULL,
	[NoOfMatchingWordsInSentence1] [int] NOT NULL,
	[NoOfMatchingWordsInSentence2] [int] NOT NULL,
	[PercentageOfMatchingWordsInSentence1] [int] NOT NULL,
	[PercentageOfMatchingWordsInSentence2] [int] NOT NULL
) 

GO

ALTER TABLE [dbo].[Similarity_Wordbased_NoOrder_NoRepetetion]  WITH CHECK ADD FOREIGN KEY([AyahSerialNo1])
REFERENCES [dbo].[N1-Ayahs] ([AyahSerialNo])

ALTER TABLE [dbo].[Similarity_Wordbased_NoOrder_NoRepetetion]  WITH CHECK ADD FOREIGN KEY([AyahSerialNo2])
REFERENCES [dbo].[N1-Ayahs] ([AyahSerialNo])

CREATE NONCLUSTERED INDEX IX_Similarity_Wordbased_NoOrder_NoRepetetion_PercentageMathing
    ON [dbo].[Similarity_Wordbased_NoOrder_NoRepetetion] ([PercentageOfMatchingWordsInSentence1], [PercentageOfMatchingWordsInSentence2]);

--------------------------------------------------------------------
--------------------------------------------------------------------


insert into [dbo].[Similarity_Wordbased_NoOrder_NoRepetetion]
select   AyahSerialNo1, AyahSerialNo2, [NoOfMatchingWords], [NoOfMatchingWordsInSentence1], [NoOfMatchingWordsInSentence2], [PercentageOfMatchingWordsInSentence1], [PercentageOfMatchingWordsInSentence2]
from 
(
select  a1.AyahSerialNo AyahSerialNo1, a2.AyahSerialNo AyahSerialNo2, a1.Ayah Ayah1, a2.Ayah Ayah2
from dbo.[N1-Ayahs] a1, dbo.[N1-Ayahs] a2
where a1.AyahSerialNo<a2.AyahSerialNo
) a
cross apply dbo.ufn_Similarity_Words_NoOrder_NoRepeteition(a.Ayah1, a.Ayah2) b


--------------------------------------------------------------------
--------------------------------------------------------------------
CREATE TABLE [dbo].[Similarity_Charbased_NoOrder_NoRepetetion](
	[AyahSerialNo1] [int] NOT NULL,
	[AyahSerialNo2] [int] NOT NULL,
	[NoOfMatchingChars] [int] NOT NULL,
	[NoOfMatchingCharsInSentence1] [int] NOT NULL,
	[NoOfMatchingCharsInSentence2] [int] NOT NULL,
	[PercentageOfMatchingCharsInSentence1] [int] NOT NULL,
	[PercentageOfMatchingCharsInSentence2] [int] NOT NULL
) 

GO

ALTER TABLE [dbo].[Similarity_Charbased_NoOrder_NoRepetetion]  WITH CHECK ADD FOREIGN KEY([AyahSerialNo1])
REFERENCES [dbo].[N1-Ayahs] ([AyahSerialNo])

ALTER TABLE [dbo].[Similarity_Charbased_NoOrder_NoRepetetion]  WITH CHECK ADD FOREIGN KEY([AyahSerialNo2])
REFERENCES [dbo].[N1-Ayahs] ([AyahSerialNo])

CREATE NONCLUSTERED INDEX IX_Similarity_Charbased_NoOrder_NoRepetetion_PercentageMathing
    ON [dbo].[Similarity_Charbased_NoOrder_NoRepetetion] ([PercentageOfMatchingCharsInSentence1], [PercentageOfMatchingCharsInSentence2]);

--------------------------------------------------------------------
--------------------------------------------------------------------
insert into [dbo].[Similarity_Charbased_NoOrder_NoRepetetion]
select  AyahSerialNo1, AyahSerialNo2, [NoOfMatchingCharacters], [NoOfMatchingCharactersInWord1], [NoOfMatchingCharactersInWord2], [PercentageOfMatchingCharactersInWord1], [PercentageOfMatchingCharactersInWord2]
from 
(
select  a1.AyahSerialNo AyahSerialNo1, a2.AyahSerialNo AyahSerialNo2, a1.Ayah Ayah1, a2.Ayah Ayah2
from dbo.[N1-Ayahs] a1, dbo.[N1-Ayahs] a2
where a1.AyahSerialNo<a2.AyahSerialNo
) a
cross apply dbo.ufn_Similarity_Chars_NoOrder_NoRepeteition(a.Ayah1, a.Ayah2) b

--------------------------------------------------------------------
--------------------------------------------------------------------
ALTER TABLE [dbo].[Similarity_Wordbased_NoOrder_NoRepetetion] ADD 
Connectedness1 int NULL, 
Connectedness2 int NULL ;
GO

update S
set S.Connectedness1 = CM.DegreeOfConnectednessInSentence1, S.Connectedness2 = CM.DegreeOfConnectednessInSentence2
FROM [dbo].[Similarity_Wordbased_NoOrder_NoRepetetion] S 
     inner join [dbo].[N1-Ayahs] A1 on S.AyahSerialNo1 = A1.AyahSerialNo
     inner join [dbo].[N1-Ayahs] A2 on S.AyahSerialNo2 = A2.AyahSerialNo
     cross apply dbo.ufn_Word_ConnectednessMeasure(A1.Ayah, A2.Ayah) CM  
GO

ALTER TABLE [dbo].[Similarity_Charbased_NoOrder_NoRepetetion] ADD 
Connectedness1 int NULL, 
Connectedness2 int NULL ;
GO

update S
set S.Connectedness1 = CM.DegreeOfConnectednessInSentence1, S.Connectedness2 = CM.DegreeOfConnectednessInSentence2
FROM [dbo].[Similarity_Charbased_NoOrder_NoRepetetion] S 
     inner join [dbo].[N1-Ayahs] A1 on S.AyahSerialNo1 = A1.AyahSerialNo
     inner join [dbo].[N1-Ayahs] A2 on S.AyahSerialNo2 = A2.AyahSerialNo
     cross apply dbo.ufn_Char_ConnectednessMeasure(A1.Ayah, A2.Ayah) CM  
GO

--------------------------------------------------------------------
--------------------------------------------------------------------
ALTER TABLE [dbo].[Similarity_Wordbased_NoOrder_NoRepetetion] ADD 
DegreeOfOrderness int NULL;
GO

update S
set S.DegreeOfOrderness = dbo.ufn_Word_OutOfOrdernessMeasure(A1.Ayah, A2.Ayah)
FROM [dbo].[Similarity_Wordbased_NoOrder_NoRepetetion] S 
     inner join [dbo].[N1-Ayahs] A1 on S.AyahSerialNo1 = A1.AyahSerialNo
     inner join [dbo].[N1-Ayahs] A2 on S.AyahSerialNo2 = A2.AyahSerialNo
       
GO

ALTER TABLE [dbo].[Similarity_Charbased_NoOrder_NoRepetetion] ADD 
DegreeOfOrderness int NULL;
GO

update S
set S.DegreeOfOrderness = dbo.ufn_Char_OutOfOrdernessMeasure(A1.Ayah, A2.Ayah)
FROM [dbo].[Similarity_Charbased_NoOrder_NoRepetetion] S 
     inner join [dbo].[N1-Ayahs] A1 on S.AyahSerialNo1 = A1.AyahSerialNo
     inner join [dbo].[N1-Ayahs] A2 on S.AyahSerialNo2 = A2.AyahSerialNo
      
GO

GO