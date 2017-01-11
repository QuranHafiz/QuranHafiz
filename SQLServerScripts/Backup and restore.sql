BACKUP DATABASE QuranV2 
 TO DISK = 'C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\Backup\QV2.bak'
   WITH FORMAT;
GO



RESTORE FILELISTONLY 
   FROM DISK = 'C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\Backup\QV2.bak'
  
RESTORE DATABASE QuranV22
   FROM DISK = 'C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\Backup\QV2.bak'
   WITH 
   MOVE 'QuranV2' TO 'C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\Data\QuranV22.mdf', 
   MOVE 'QuranV2_Log'  TO 'C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\Data\QuranV22.ldf';


