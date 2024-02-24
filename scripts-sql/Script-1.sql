DROP TABLE IF EXISTS produtos;
DROP TABLE IF EXISTS vendas;

CREATE TABLE produtos (
    Codigo VARCHAR(10),
    Produto VARCHAR(255),
    Preco VARCHAR(10)
);

CREATE TABLE vendas (
    "Order ID" VARCHAR(20) ,
    "Date" DATE ,
    "ship-service-level" VARCHAR(20) ,
    "Style" VARCHAR(20),
    Codigo VARCHAR(10),
    "Courier Status" VARCHAR(20),
    Qty INT,
    "ship-country" VARCHAR(2),
    Fulfillment VARCHAR(3)
);

--Importação dos dados dos CSVs para as tabelas atravez do próprio DBeaver

-- Remover o símbolo "$" dos valores existentes
UPDATE produtos
SET Preco = REPLACE(Preco, '$', '');

-- Alterar a coluna "Preco" para o tipo DECIMAL com conversão explícita
ALTER TABLE produtos
ALTER COLUMN Preco TYPE NUMERIC(10, 2) USING Preco::NUMERIC(10, 2);

SELECT * FROM produtos;
SELECT * FROM vendas;
