CREATE TABLE PRODUTOS (
  ID NUMBER(10) PRIMARY KEY,
  NOME VARCHAR2(100) NOT NULL,
  QUANTIDADE NUMBER(10) NOT NULL,
  PRECO NUMBER(10, 2) NOT NULL
);

CREATE TABLE VENDAS (
  ID NUMBER(10) PRIMARY KEY,
  DATA DATE NOT NULL,
  ID_PRODUTO NUMBER(10) NOT NULL REFERENCES PRODUTOS(ID),
  QUANTIDADE NUMBER(10) NOT NULL
);

CREATE TABLE ESTOQUE (
  ID NUMBER(10) PRIMARY KEY,
  DATA DATE NOT NULL,
  VALOR NUMBER(10, 2) NOT NULL
);

-- Criação do trigger para atualização do estoque:
CREATE OR REPLACE TRIGGER TRG_ATUALIZA_ESTOQUE AFTER
  INSERT ON VENDAS FOR EACH ROW
BEGIN
  UPDATE ESTOQUE
  SET
    VALOR = VALOR - :NEW.QUANTIDADE * (
      SELECT PRECO FROM PRODUTOS WHERE ID = :NEW.ID_PRODUTO
    )
  WHERE
    ID = (
      SELECT MAX(ID) FROM ESTOQUE
    );
END;

 -- Criação da função para cálculo do valor total de vendas:
 CREATE OR REPLACE FUNCTION FN_VALOR_TOTAL_VENDAS RETURN NUMBER IS VALOR_TOTAL NUMBER(10, 2);
BEGIN
  SELECT
    SUM(QUANTIDADE * PRECO) INTO VALOR_TOTAL
  FROM
    VENDAS   V
    JOIN PRODUTOS P
    ON V.ID_PRODUTO = P.ID;
  RETURN VALOR_TOTAL;
END;

 -- Criação do procedimento para notificação de estoque baixo:
 CREATE OR REPLACE PROCEDURE PROC_NOTIFICA_ESTOQUE_BAIXO AS V_QUANTIDADE_MINIMA NUMBER(10) := 10;
BEGIN
  FOR PRODUTO IN (
    SELECT
      ID,
      NOME,
      QUANTIDADE
    FROM
      PRODUTOS
    WHERE
      QUANTIDADE <= V_QUANTIDADE_MINIMA
  ) LOOP
 -- Aqui, pode ser implementada a lógica de notificação por e-mail ou outro meio
    DBMS_OUTPUT.PUT_LINE('O produto '
      || PRODUTO.NOME
      || ' está com estoque baixo.');
  END LOOP;
END;

 -- Criação do pacote para backup do banco de dados:
 CREATE OR REPLACE PACKAGE PKG_BACKUP_BANCO_DADOS IS PROCEDURE PROC_BACKUP;
END;
/

CREATE OR REPLACE PACKAGE BODY PKG_BACKUP_BANCO_DADOS IS
  PROCEDURE PROC_BACKUP AS
  BEGIN
 -- Aqui, pode ser implementada a lógica para realização do backup do banco de dados
    DBMS_OUTPUT.PUT_LINE('Realizando backup do banco de dados...');
    DBMS_SCHEDULER.CREATE_JOB (
      JOB_NAME => 'job_backup_banco_dados',
      JOB_TYPE => 'PLSQL_BLOCK',
      JOB_ACTION => 'BEGIN pkg_backup_banco_dados.proc_backup; END;',
      START_DATE => SYSTIMESTAMP,
      REPEAT_INTERVAL => 'FREQ=DAILY; BYHOUR=23;',
      ENABLED => TRUE
    );
  END;
END;
/

-- Popula a tabela de produtos
INSERT INTO produtos (id, nome, quantidade, preco) VALUES (1, 'Camiseta', 100, 29.99);
INSERT INTO produtos (id, nome, quantidade, preco) VALUES (2, 'Calça jeans', 50, 89.99);
INSERT INTO produtos (id, nome, quantidade, preco) VALUES (3, 'Tênis', 30, 149.99);

-- Popula a tabela de vendas
INSERT INTO vendas (id, data, id_produto, quantidade) VALUES (1, TO_DATE('2022-05-10', 'YYYY-MM-DD'), 1, 5);
INSERT INTO vendas (id, data, id_produto, quantidade) VALUES (2, TO_DATE('2022-05-10', 'YYYY-MM-DD'), 2, 3);
INSERT INTO vendas (id, data, id_produto, quantidade) VALUES (3, TO_DATE('2022-05-11', 'YYYY-MM-DD'), 3, 2);
INSERT INTO vendas (id, data, id_produto, quantidade) VALUES (4, TO_DATE('2022-05-11', 'YYYY-MM-DD'), 1, 10);

-- Popula a tabela de estoque
INSERT INTO estoque (id, data, valor) VALUES (1, TO_DATE('2022-05-10', 'YYYY-MM-DD'), 3028.70);
INSERT INTO estoque (id, data, valor) VALUES (2, TO_DATE('2022-05-11', 'YYYY-MM-DD'), 2509.73);
