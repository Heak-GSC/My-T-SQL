insert into [GasTank]([GasTankID],[GasTankCode],[Life],[ExtendField1],[ExtendField2],[ExtendField3]) values(@GasTankID,@GasTankCode,@Life,@ExtendField1,@ExtendField2,@ExtendField3)
update [GasTank] set [ScanDate]=@ScanDate,[Life]=@Life,[IsInsGasTank]=@IsInsGasTank,[ExtendField1]=@ExtendField1,[ExtendField2]=@ExtendField2,[ExtendField3]=@ExtendField3 where [GasTankID]=@GasTankID
delete from GasTank where [GasTankID]=@GasTankID

create table [GasTank]
(
	[GasTankID]  varchar(36) primary key not null,
	[GasTankCode] varchar(20) null unique,
	[CreateDate] datetime default(getdate()) null,
	[InsDate] datetime default(getdate()) null,
	[ScanDate] datetime default(getdate()) null,
	[Life] int default(1) null,
	[ScanCount]	int null,
	[IsInsGasTank] bit default(0),
	ExtendField1 varchar(50) null,
	ExtendField2 varchar(50) null,
	ExtendField3 varchar(50) null,
	ExtendField4 varchar(50) null,
	ExtendField5 varchar(50) null,
)
go


create trigger T_DistinctInsert 
on [GasTank] 
for insert
as
	begin transaction
	declare @Code varchar(2)
	declare @date varchar(2)
	declare @Count int
	select @Code=[GasTankCode],@date=[InsDate],@Count=[ScanCount], from inserted
		if((select count(*) from [GasTank] where [GasTankCode]=@Code)>0)
		begin
			update [GasTank] set [ScanCount] = @Count + 1,[ScanDate] = getdate() where [GasTankCode]=@Code
			if()
			rollback transaction
		end
go
alter PROCEDURE P_DistinctInsert
--�洢����
alter PROCEDURE P_DistinctInsert
(	
	@GasTankCode varchar(50),
	@ExtendField1 varchar(50),
	@ExtendField2 varchar(50),
	@ExtendField3 varchar(50),
	@Flag bit OUTPUT,--0 ʧ��,1 �ɹ�
    @Result nvarchar(100) OUTPUT  --ִ�н������
)
as
begin
	set @Flag  = 1
	set @Result=''
	declare @Log varchar(Max)
	
	set @Log = 'GasTankCode:' + CONVERT(NVARCHAR(MAX), @GasTankCode) + ',' +
			   'ExtendField1:' + CONVERT(NVARCHAR(MAX), @ExtendField1) + ',' +
			   'ExtendField2:' + CONVERT(NVARCHAR(MAX), @ExtendField1) + ',' +
			   'ExtendField3:' + CONVERT(NVARCHAR(MAX), @ExtendField1)
			   
	insert into dbo.Log
			( EventID ,
                  Priority ,
                  Severity ,
                  Title ,
                  Timestamp ,
                  MachineName ,
                  AppDomainName ,
                  ProcessID ,
                  ProcessName ,
                  ThreadName ,
                  Win32ThreadId ,
                  Message ,
                  FormattedMessage ,
                  OptUserID ,
                  OptUser ,
                  SysCode ,
                  ModelName
                )
        VALUES  ( 0 , -- EventID - int
                  0 , -- Priority - int
                  N'' , -- Severity - nvarchar(32)
                  N'[P_DistinctInsert]��������' , -- Title - nvarchar(256)
                  GETDATE() , -- Timestamp - datetime
                  N'' , -- MachineName - nvarchar(32)
                  N'' , -- AppDomainName - nvarchar(512)
                  N'' , -- ProcessID - nvarchar(256)
                  N'' , -- ProcessName - nvarchar(512)
                  N'' , -- ThreadName - nvarchar(512)
                  NULL , -- Win32ThreadId - sysname
                  @Log , -- Message - nvarchar(1500)
                  @Log , -- FormattedMessage - ntext
                  N'' , -- OptUserID - nvarchar(36)
                  N'' , -- OptUser - nvarchar(36)
                  N'' , -- SysCode - nvarchar(50)
                  'ɨ���¼'  -- ModelName - nvarchar(50)
                )
        --����ֵ
        begin
			set @GasTankCode = ISNULL(@GasTankCode,'')
			set @ExtendField1 = ISNULL(@ExtendField1,'')
			set @ExtendField2 = ISNULL(@ExtendField2,'')
			set @ExtendField3 = ISNULL(@ExtendField3,'')
        
			if @GasTankCode = ''
			begin
				set @Flag=0
				SET @Result=@Result+','+'���ޱ�Ų���Ϊ��'--���÷��ؽ������
				return;
			end
	    end
	    
	    begin 
			begin try
				begin tran
					declare @exist int
					declare @date int 
					declare @InsDate datetime
					declare @life int 
					set @exist = ((select count(GasTankCode) from [GasTank] where [GasTankCode]=@GasTankCode))
					--�ж��Ƿ��Ѿ�����
					if @exist > 0
						begin
							set @InsDate = (select InsDate from [GasTank] where [GasTankCode]=@GasTankCode)
							set @date = ( select DATEDIFF(Year,@InsDate,GETDATE()))
							set @life = (select Life from [GasTank] where [GasTankCode]=@GasTankCode)
							if @life = @date
								begin
									update [GasTank] set IsInsGasTank = 1 where [GasTankCode]=@GasTankCode
									if @@ERROR<>0	
			   						begin
			   							set @Flag=0
										SET @Result=@Result+','+'�����Ƿ���ʧ��'--���÷��ؽ������
			   						end 
								end
							update [GasTank] set ScanDate = GETDATE() where [GasTankCode]=@GasTankCode
							if @@ERROR<>0	
			   				begin
			   					set @Flag=0
								SET @Result=@Result+','+'����ɨ��ʱ��ʧ��'--���÷��ؽ������
			   				end 
						end
					--��������
					if @exist <= 0
					begin
						insert into [GasTank](
						[GasTankID],
						[GasTankCode],
						[Life],
						[ExtendField1],
						[ExtendField2],
						[ExtendField3]) 
						values(
						NEWID(),
						@GasTankCode,
						1,
						@ExtendField1,
						@ExtendField2,
						@ExtendField3)
						
						if @@ERROR<>0	
			   			begin
			   				set @Flag=0
							SET @Result=@Result+','+'д��ɨ���¼ʧ��'--���÷��ؽ������
			   			end 
					end
					if @Flag=1
					SET @Result='�ɹ�'--���÷��ؽ������
					
				COMMIT TRAN
			end try
			BEGIN CATCH
				ROLLBACK
            END CATCH
	    end
	    INSERT  INTO dbo.Log
                ( EventID ,
                  Priority ,
                  Severity ,
                  Title ,
                  Timestamp ,
                  MachineName ,
                  AppDomainName ,
                  ProcessID ,
                  ProcessName ,
                  ThreadName ,
                  Win32ThreadId ,
                  Message ,
                  FormattedMessage ,
                  OptUserID ,
                  OptUser ,
                  SysCode ,
                  ModelName
                )
        VALUES  ( 0 , -- EventID - int
                  0 , -- Priority - int
                  N'' , -- Severity - nvarchar(32)
                  N'[P_DistinctInsert]ִ�н��' , -- Title - nvarchar(256)
                  GETDATE() , -- Timestamp - datetime
                  N'' , -- MachineName - nvarchar(32)
                  N'' , -- AppDomainName - nvarchar(512)
                  N'' , -- ProcessID - nvarchar(256)
                  N'' , -- ProcessName - nvarchar(512)
                  N'' , -- ThreadName - nvarchar(512)
                  NULL , -- Win32ThreadId - sysname
                  N'ִ�н����'+@Result+',�������Ϊ��'+@LOG , -- Message - nvarchar(1500)
                  N'ִ�н����'+@Result+',�������Ϊ��'+@LOG , -- FormattedMessage - ntext
                  N'' , -- OptUserID - nvarchar(36)
                  N'' , -- OptUser - nvarchar(36)
                  N'' , -- SysCode - nvarchar(50)
                  'ɨ���¼'  -- ModelName - nvarchar(50)
                )
end




declare @aa bit, @ss nvarchar(100)

exec P_DistinctInsert 'jdkhfkj',null,null,null,@aa output ,@ss output

print @aa 
print @ss
select COUNT(GasTankCode) from GasTank where GasTankCode = 'sss'