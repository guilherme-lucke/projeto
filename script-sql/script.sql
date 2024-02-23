DROP TABLE IF EXISTS produtos;
DROP TABLE IF exists vendas;

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
    "Codigo" VARCHAR(10),
    "Courier Status" VARCHAR(20),
    "Qty" INT,
    "ship-country" VARCHAR(2),
    "Fulfillment" VARCHAR(3)
);

-- Remover o símbolo "$" dos valores existentes
UPDATE produtos
SET Preco = REPLACE(Preco, '$', '');

-- Alterar a coluna "Preco" para o tipo DECIMAL com conversão explícita
ALTER TABLE produtos
ALTER COLUMN Preco TYPE NUMERIC(10, 2) USING Preco::NUMERIC(10, 2);

--SELECT * FROM produtos;
--SELECT * FROM vendas;

--01 Quantos produtos diferentes temos?
CREATE VIEW vw_total_produtos AS
SELECT COUNT(DISTINCT Codigo) AS total_produtos
FROM produtos;

--02 Qual é o preço médio dos produtos?
CREATE VIEW vw_preco_medio AS
SELECT AVG(Preco::NUMERIC) AS preco_medio
FROM produtos;

--03 Quais são os produtos mais caros?
CREATE VIEW vw_produtos_mais_caros AS
SELECT Produto, Preco::NUMERIC
FROM produtos
ORDER BY Preco::NUMERIC DESC
LIMIT 5;

--04 Quantos pedidos foram cancelados?
CREATE VIEW vw_pedidos_cancelados AS
SELECT COUNT(*) AS total_cancelados
FROM vendas
WHERE "Courier Status" = 'Cancelled';

--05 Qual é a data mais comum para envio?
CREATE VIEW vw_data_envio AS
SELECT "Date", COUNT(*) AS total_pedidos
FROM vendas
GROUP BY "Date"
ORDER BY total_pedidos DESC
LIMIT 1;

--06 Qual é o mês com mais vendas?
CREATE VIEW vw_mes_mais_vendas AS
SELECT EXTRACT(MONTH FROM "Date") AS mes, COUNT(*) AS total_vendas
FROM vendas
GROUP BY mes
ORDER BY total_vendas DESC
LIMIT 1;

--07 Qual é o país com mais vendas?
CREATE VIEW vw_pais_mais_vendas AS
SELECT "ship-country", COUNT(*) AS total_vendas
FROM vendas
GROUP BY "ship-country"
ORDER BY total_vendas DESC
LIMIT 1;

--08 Total de vendas por país:
CREATE VIEW vw_total_vendas_por_pais AS
SELECT "ship-country", COUNT(*) AS total_vendas
FROM vendas
GROUP BY "ship-country";

--09 Qual é o total de vendas enviadas?
CREATE VIEW vw_vendas_enviadas AS
SELECT COUNT(*) AS total_enviado
FROM vendas
WHERE "Courier Status" = 'Shipped';

--10 Qual é o país com a maior média de produtos por pedido?
CREATE VIEW media_produtos_por_pedido_pais AS
SELECT "ship-country", AVG("Qty") AS media_produtos
FROM vendas
GROUP BY "ship-country"
ORDER BY media_produtos DESC
LIMIT 1;







