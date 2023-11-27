/* CRIANDO UM BANCO DE DADOS  */
CREATE DATABASE BANCO
GO

/* CONCETANDO A UM BANCO DE DADOS */
USE BANCO
GO

/* CRIANDO UM CLIENTE */
CREATE TABLE CLIENTE( 
	IDCLIENTE INT PRIMARY KEY IDENTITY,
	NOME VARCHAR(30) NOT NULL,
	NASCIMENTO DATE NOT NULL,
	SEXO CHAR(1) NOT NULL,
	EMAIL VARCHAR(30) UNIQUE NOT NULL,
)
GO

ALTER TABLE CLIENTE
ADD CONSTRAINT CK_SEXO CHECK (SEXO IN ('M', 'F'))
GO

CREATE TABLE ENDERECO(
	IDENDERECO INT PRIMARY KEY IDENTITY,
	BAIRRO VARCHAR(30) NOT NULL,
	UF CHAR(2) NOT NULL,
	ID_CLIENTE INT UNIQUE
)
GO

ALTER TABLE ENDERECO ADD CONSTRAINT FK_ENDERECO_CLIENTE
FOREIGN KEY(ID_CLIENTE) REFERENCES CLIENTE(IDCLIENTE)
GO

CREATE TABLE TELEFONE(
	IDTELEFONE INT PRIMARY KEY IDENTITY,
	TIPO CHAR(3) NOT NULL,
	NUMERO VARCHAR(10) NOT NULL,
	ID_CLIENTE INT UNIQUE,
	CHECK (TIPO IN('RES', 'COM', 'CEL'))
)
GO

ALTER TABLE TELEFONE ADD CONSTRAINT FK_TELEFONE_CLIENTE
FOREIGN KEY(ID_CLIENTE) REFERENCES CLIENTE(IDCLIENTE)
GO

CREATE TABLE LANCAMENTO_CONTABIL(
	VALOR INT,
	DEB_CRED CHAR(1),
	ID_CLIENTE INT
)
GO

ALTER TABLE LANCAMENTO_CONTABIL ADD CONSTRAINT FK_LANCAMENTO_CONTABIL_CLIENTE
FOREIGN KEY(ID_CLIENTE) REFERENCES CLIENTE(IDCLIENTE)
GO

/* INSERINDO CLINTES */
INSERT INTO CLIENTE VALUES('ANA LUA', '2000/11/05', 'F', 'ANALUA@EMAIL.COM')
INSERT INTO CLIENTE VALUES('MANEVA', '1998/05/07', 'F', 'MANEVA@EMAIL.COM')
INSERT INTO CLIENTE VALUES('BOB', '1968/12/15', 'M', 'BOB@EMAIL.COM')
INSERT INTO CLIENTE VALUES('MARINA', '1987/10/25', 'F', 'MARINA@EMAIL.COM')
INSERT INTO CLIENTE VALUES('LEO', '1995/09/17', 'M', 'LEO@EMAIL.COM')
INSERT INTO CLIENTE VALUES('JOAO', '1964/01/20', 'M', 'JOAO@EMAIL.COM')
INSERT INTO CLIENTE VALUES('HELENA', '2001/04/07', 'F', 'HELENA@EMAIL.COM')
INSERT INTO CLIENTE VALUES('MIGUEL', '1982/05/24', 'M', 'MIGUEL@EMAIL.COM')
INSERT INTO CLIENTE VALUES('CLARA', '2001/06/13', 'F', 'CLARA@EMAIL.COM')
INSERT INTO CLIENTE VALUES('LOISY', '1996/06/27', 'F', 'LOISY@EMAIL.COM')
GO

/* INSERINDO ENDERECOS */
INSERT INTO ENDERECO VALUES('CENTRO', 'MG', 5)
INSERT INTO ENDERECO VALUES('PELOURINH', 'BA', 9)
INSERT INTO ENDERECO VALUES('LIBERDADE', 'SP', 2)
INSERT INTO ENDERECO VALUES('JARDINS', 'SP',4)
INSERT INTO ENDERECO VALUES('URCA', 'RJ', 7)
INSERT INTO ENDERECO VALUES('LEME', 'RJ', 10)
INSERT INTO ENDERECO VALUES('CIDADE VELHA', 'BA', 1)
INSERT INTO ENDERECO VALUES('MORUMBI', 'SP', 3)
INSERT INTO ENDERECO VALUES('CENTRO', 'BH', 6)
INSERT INTO ENDERECO VALUES('JARDIM EUROPA', 'GO', 8)
GO

/* INSERINDO TELEFONES */
INSERT INTO TELEFONE VALUES('CEL', '65214789', 1)
INSERT INTO TELEFONE VALUES('COM', '52147855', 3)
INSERT INTO TELEFONE VALUES('CEL', '11245435', 5)
INSERT INTO TELEFONE VALUES('CEL', '99875332', 9)
INSERT INTO TELEFONE VALUES('RES', '15472236', 4)
INSERT INTO TELEFONE VALUES('CEL', '15154879', 2)
INSERT INTO TELEFONE VALUES('CEL', '54003688', 6)
INSERT INTO TELEFONE VALUES('RES', '78896554', 7)
INSERT INTO TELEFONE VALUES('CEL', '15456625', 8)
INSERT INTO TELEFONE VALUES('CEL', '12457896', 10)
GO

/* INSERE OS DADOS NA TABLEA ATRAVES DE UM ARQUIVO .TXT */
BULK INSERT LANCAMENTO_CONTABIL
FROM 'C:\Users\biby_\Downloads\CONTAS.txt'
WITH
(
	FIRSTROW = 2, -- COMECA A LEITURA A PARTIR DA LINHA 2 
	DATAFILETYPE = 'CHAR',
	FIELDTERMINATOR = '\t', -- DELIMITADOR DO COLUNA 
	ROWTERMINATOR = '\n' -- DELIMITADOR FIM DA LINHA 
)
GO


/* QUERY QUE TRAZ O NOME DO CLIENTE E O SALDO DA CONTA */
SELECT	C.NOME, 
		SUM(L.VALOR * (CHARINDEX('C', L.DEB_CRED) * 2 - 1)) AS "SALDO" -- SOMA OS CREDITOS E DEBITOS DE CADA CONTA 
FROM CLIENTE C
INNER JOIN LANCAMENTO_CONTABIL L
ON C.IDCLIENTE = L.ID_CLIENTE
GROUP BY C.NOME
GO

/* QUERY QUE TRAS O NOME DO CLIENTE, NUMERO DE TELEFONE, EMAIL E SALDO DA CONTA */
SELECT	C.NOME, 
		T.NUMERO,
		C.EMAIL,
		SUM(L.VALOR * (CHARINDEX('C', L.DEB_CRED) * 2 - 1)) AS "SALDO" -- SOMA OS CREDITOS E DEBITOS DE CADA CONTA 
FROM CLIENTE C
INNER JOIN TELEFONE T
ON C.IDCLIENTE = T.ID_CLIENTE
INNER JOIN LANCAMENTO_CONTABIL L
ON C.IDCLIENTE = L.ID_CLIENTE
GROUP BY C.NOME, T.NUMERO, C.EMAIL
GO

/* VERIFICANDO O USUARIO DO BANCO */
SELECT SUSER_NAME()
GO

/* TABELA PARA SALVAR ALTERACOES DE TELEFONE */
CREATE TABLE HISTORICO_TELEFONE(
	IDOPERACAO INT PRIMARY KEY IDENTITY,
	TIPO CHAR(3),
	NUMEROANTIGO VARCHAR(10) NOT NULL,
	NUMERONOVO VARCHAR(10) NOT NULL, 
	DATA DATETIME, 
	USUARIO VARCHAR(30),
	MENSAGEM VARCHAR(100)
)
GO

/* TRIGGER DE DADOS - ATUALIZA NUMERO DE TELEFONE */
CREATE TRIGGER TRG_ATUALIZA_TELEFONE
ON DBO.TELEFONE 
FOR UPDATE AS
IF UPDATE(NUMERO)
BEGIN
	-- DECLARANDO VARIAVEIS 
	DECLARE @IDTELEFONE INT
	DECLARE @TIPO CHAR(3)
	DECLARE @NUMERO VARCHAR(10)
	DECLARE @NUMERONOVO VARCHAR(10)
	DECLARE @DATA DATETIME
	DECLARE @USUARIO VARCHAR(30)
	DECLARE @ACAO VARCHAR(100)

	--ATRIBUINDO VALOR AS VARIAVEIS 
	SELECT @IDTELEFONE = IDTELEFONE FROM inserted
	SELECT @NUMERO = NUMERO FROM deleted -- NUMERO ANTIGO QUE VAI SER DELETADO 
	SELECT @NUMERONOVO = NUMERO FROM inserted

	SET @DATA = GETDATE()
	SET @USUARIO =SUSER_NAME()
	SET @ACAO = 'NUMERO ALTERADO PELA TRIGGER TRG_ATUALIZA_TELEFONE'

	INSERT INTO HISTORICO_TELEFONE
	(TIPO, NUMEROANTIGO, NUMERONOVO, DATA, USUARIO, MENSAGEM)
	VALUES
	(@TIPO, @NUMERO, @NUMERONOVO, @DATA, @USUARIO, @ACAO)
	
	PRINT 'TRIGGER EXECUTADA COM SUCESSO'
END
GO

/* EXECUTANDO UM UPDATE */
UPDATE TELEFONE SET NUMERO = '95488754', TIPO = 'COM'
WHERE IDTELEFONE = 1
GO
