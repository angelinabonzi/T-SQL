USE db_teste_asp;
-----------------------------------------------------------------------------------------------------------------
-- Quest�o 1

--Lista todas as descri��es da tabela "Tabela" que est�o duplicadas
SELECT descricao AS Descri��o, Count(*) AS Qtd_Duplicados FROM Tabela
GROUP BY descricao
HAVING Count(*) > 1;

-----------------------------------------------------------------------------------------------------------------
-- Quest�o 2

--Listar todos os campos da tabela "Tabela" que n�o est�o na tabela "Tabela_esp"
SELECT * FROM Tabela WHERE codigo not in (SELECT codigo FROM Tabela_esp);

-----------------------------------------------------------------------------------------------------------------
-- Quest�o 3

--Atualiza o campo obs = 'S' da tabela Tabela que possui registro na tabela Tabela_esp 
UPDATE Tabela 
SET obs = 'S'
FROM Tabela t INNER JOIN Tabela_esp te 
ON t.codigo = te.codigo;

-----------------------------------------------------------------------------------------------------------------
-- Quest�o 4

USE db_teste_asp
GO

-- Cria tabela tempor�ria
CREATE TABLE ##Registros_duplicados_global (
codigo int NOT NULL,
descricao varchar(50) NOT NULL,
obs varchar(50) NULL);
GO

-- Cria Stored Procedure
CREATE PROCEDURE tst_sp_descricoes_duplicadas 
@descricao VARCHAR(50)
AS
BEGIN
INSERT INTO ##Registros_duplicados_global (codigo, descricao, obs) 
	 SELECT codigo, descricao, obs 
	   FROM Tabela
	  WHERE descricao = @descricao;
	 
END
GO

--Executa Stored Procedure
EXEC tst_sp_descricoes_duplicadas 'descricao'
GO

--Select tabela tempor�ria
SELECT * FROM ##Registros_duplicados_global;

-----------------------------------------------------------------------------------------------------------------
-- Quest�o 5

-- Cria Trigger
USE db_teste_asp
GO
CREATE TRIGGER Trigger_Historico
ON Tabela
AFTER 
UPDATE, DELETE
AS
BEGIN	
	INSERT INTO Tabela_hist (data_historico, codigo, descricao, obs)
		 SELECT GETDATE(), codigo, descricao, obs
		   FROM DELETED 
END          
GO

--Testar Trigger
USE db_teste_asp
GO
UPDATE t SET obs = 'A'
FROM Tabela AS t
WHERE obs IS NULL;
GO

DELETE FROM Tabela
WHERE codigo = '1900';

-- CONSULTA
SELECT * FROM Tabela_hist;

-----------------------------------------------------------------------------------------------------------------
-- Quest�o 6
USE db_teste_asp
GO
CREATE FUNCTION tst_fn_existecodigo (
	@codigo INT
)
RETURNS BIT
AS 
BEGIN
	DECLARE @Retorno AS BIT
			
		SET @Retorno = IIF(EXISTS (SELECT TOP 1 1 
									 FROM Tabela 
									WHERE codigo = @codigo), 1, 0) 
	
	 RETURN @Retorno
END
GO

--Consulta Sql Fun��o com valor de tabela
--Par�metro : @codigo
USE db_teste_asp
GO
DECLARE @codigo INT = 2000;
SELECT dbo.tst_fn_existecodigo(@codigo);

-----------------------------------------------------------------------------------------------------------------
-- Quest�o 7

--Criar um script que crie uma tabela identica a tabela "Tabela" de nome "Tabela_espelho" caso ela n�o exista. 
--Inclua nessa tabela o conteudo da tabela "Tabela" de 1 em 1 registro (utilizando cursor) e executando um commit a cada 100 registros.

USE db_teste_asp
GO
-- Verifica se a tabela existe e apaga
IF OBJECT_ID('Tabela_espelho','U') is not null
	DROP TABLE Tabela_espelho;
GO
-- Cria a tabela Tabela_espelho (somente estrutura) identica a tabela Tabela. 
SELECT *
  INTO Tabela_espelho
  from Tabela
  where 1 = 0;

-- Vari�veis
DECLARE @codigo INT,
		@descricao VARCHAR(50),
		@obs VARCHAR(50);

-- Criando o cursor
DECLARE cur_Dados_Tabela CURSOR
FOR SELECT codigo, descricao, obs FROM Tabela;

-- Abrindo o cursor
OPEN cur_Dados_Tabela;

-- Selecionar os dados
FETCH NEXT FROM cur_Dados_Tabela
INTO @codigo, @descricao, @obs;

-- Itera��o entre os dados retornados pelo cursor
WHILE @@FETCH_STATUS = 0
BEGIN
	-- Pegar os pr�ximos dados
	FETCH NEXT FROM cur_Dados_Tabela
	INTO @codigo, @descricao, @obs;

	-- Inicia a transa��o
	BEGIN TRANSACTION

	-- Insere os dados da tabela Tabela, linha a linha, na tabela Tabela_espelho
	INSERT INTO Tabela_espelho (codigo, descricao, obs)
		 SELECT @codigo, @descricao, @obs;

	-- Comita a transa��o 
	COMMIT;
END

-- Fechando e desalocando o cursor da mem�ria
CLOSE cur_Dados_Tabela;
DEALLOCATE cur_Dados_Tabela;

-----------------------------------------------------------------------------------------------------------------
-- Quest�o 8

USE db_teste_asp
GO

-- Cria Stored Procedure
CREATE PROCEDURE tst_sp_importa_arquivo
@arquivo VARCHAR(500) 
AS
BEGIN	
	DROP TABLE dbo.ARQUIVO_TESTE
	
	CREATE TABLE dbo.ARQUIVO_TESTE (
		linha_arquivo varchar(1800) NULL)	
	
	DECLARE @sql varchar ( max ) 

	SELECT @sql = 'BULK INSERT ARQUIVO_TESTE FROM '''; 
	SELECT @sql = @sql + @arquivo;	
	exec(@sql)
END
GO










 














