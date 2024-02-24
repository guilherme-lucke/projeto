--01 Quais os produtos mais vendidos?
CREATE VIEW vwProdutosMaisVendidos AS (
SELECT
    p.Produto,
    SUM(v.Qty) AS TotalQuantidadeVendida
FROM
    produtos p
JOIN
    vendas v ON p.Codigo = v.Codigo
GROUP BY
    p.Produto
ORDER BY
    TotalQuantidadeVendida desc);

SELECT * FROM vwProdutosMaisVendidos;


--02 Quais os produtos mais caros?
CREATE VIEW vwProdutosMaisCaros AS (
SELECT
    Produto,
    Preco
FROM
    produtos
ORDER BY
    Preco desc);

SELECT * FROM vwProdutosMaisCaros;

   
--03 Quais os produtos com maior receita?
CREATE VIEW vwProdutosMaiorReceita AS (
SELECT
    p.Produto,
    SUM(p.Preco * v.Qty) AS ReceitaTotal
FROM
    produtos p
JOIN
    vendas v ON p.Codigo = v.Codigo
GROUP BY
    p.Produto
ORDER BY
    ReceitaTotal desc);

SELECT * FROM vwProdutosMaiorReceita;

--04 Quais os produtos tem maior média de quantidade vendidas?
CREATE VIEW vwProdutosMaiorMediaQuantidade AS (
SELECT
    p.Produto,
    ROUND(AVG(v.Qty), 2) AS MediaQuantidadeVendida
FROM
    produtos p
JOIN
    vendas v ON p.Codigo = v.Codigo
GROUP BY
    p.Produto
ORDER BY
    MediaQuantidadeVendida desc);

SELECT * FROM vwProdutosMaiorMediaQuantidade;

--05 Quais produtos tem mais vendas?
CREATE VIEW vwProdutosMaisVendas AS (
SELECT
    p.Produto,
    COUNT(v."Order ID") AS TotalVendas
FROM
    produtos p
JOIN
    vendas v ON p.Codigo = v.Codigo
GROUP BY
    p.Produto
ORDER BY
    TotalVendas desc);

SELECT * FROM vwProdutosMaisVendas;

--06 Quais os produtos com o maior ticket médio
CREATE VIEW vwProdutosMaiorTicketMedio AS (
SELECT
    p.Produto,
    SUM(v.Qty) AS TotalQuantidadeVendida,
    COUNT(DISTINCT v."Order ID") AS TotalVendas,
    ROUND(SUM(v.Qty) / COUNT(DISTINCT v."Order ID"), 2) AS TicketMedio
FROM
    produtos p
JOIN
    vendas v ON p.Codigo = v.Codigo
GROUP BY
    p.Produto
ORDER BY
    TicketMedio desc);

SELECT * FROM vwProdutosMaiorTicketMedio;
   
-- 07 Quais os meses com mais vendas?
CREATE VIEW vwVendasPorMes as (
SELECT
    TO_CHAR(v."Date", 'Month') AS Mes,
    SUM(v.Qty) AS QuantidadeVendida
FROM
    vendas v
GROUP BY
    Mes);

SELECT * FROM vwVendasPorMes;

--08 Quais os produros com maior consistência de vendas?
CREATE VIEW vwProdutosMaiorConsistencia AS (
WITH VendasProdutosMensais AS (
    SELECT
        p.Produto,
        EXTRACT(MONTH FROM v."Date") AS Mes,
        SUM(v.Qty) AS TotalQuantidadeVendida
    FROM
        produtos p
    JOIN
        vendas v ON p.Codigo = v.Codigo
    GROUP BY
        p.Produto, Mes
)
SELECT
    Produto,
    AVG(TotalQuantidadeVendida) AS MediaMensal,
    STDDEV(TotalQuantidadeVendida) AS DesvioPadrao
FROM
    VendasProdutosMensais
GROUP BY
    Produto
ORDER BY
    DesvioPadrao ASC);

SELECT * FROM vwProdutosMaiorConsistencia;

--09 Qual o produto mais pedido de cada mês?
CREATE VIEW vwProdutoMaisPedidoPorMes AS (
WITH VendasProdutosMensais AS (
    SELECT
        EXTRACT(MONTH FROM "Date") AS Mes,
        p.Produto,
        SUM(v.Qty) AS QuantidadeVendida
    FROM vendas v
    JOIN produtos p ON v.Codigo = p.Codigo
    GROUP BY Mes, p.Produto
),
RankPorMes AS (
    SELECT
        Mes,
        Produto,
        QuantidadeVendida,
        RANK() OVER (PARTITION BY Mes ORDER BY QuantidadeVendida DESC) AS Ranking
    FROM VendasProdutosMensais
)
SELECT
    TO_CHAR(TO_DATE(Mes::TEXT, 'MM'), 'Month') AS NomeMes,
    Produto,
    QuantidadeVendida
FROM RankPorMes
WHERE Ranking = 1
ORDER BY Mes);

SELECT * FROM vwProdutoMaisPedidoPorMes;

--10 Quais os países com maior número de pedidos?
CREATE VIEW vwPaisesMaisPedidos AS (
SELECT
    v."ship-country" AS Pais,
    COUNT(DISTINCT v."Order ID") AS TotalPedidos
FROM
    vendas v
GROUP BY
    Pais
ORDER BY
    TotalPedidos DESC);

SELECT * FROM vwPaisesMaisPedidos;

--11 Qual o produto mais pedido em cada país?
CREATE VIEW vwProdutoMaisPedidoPorPais AS (
WITH VendasPorPais AS (
    SELECT
        v."ship-country" AS Pais,
        p.Produto,
        SUM(v.Qty) AS TotalQuantidadeVendida
    FROM
        produtos p
    JOIN
        vendas v ON p.Codigo = v.Codigo
    GROUP BY
        Pais, p.Produto
),
RankPorPais AS (
    SELECT
        Pais,
        Produto,
        TotalQuantidadeVendida,
        RANK() OVER (PARTITION BY Pais ORDER BY TotalQuantidadeVendida DESC) AS Ranking
    FROM
        VendasPorPais
)
SELECT
    Pais,
    Produto,
    TotalQuantidadeVendida
FROM
    RankPorPais
WHERE
    Ranking = 1);

SELECT * FROM vwProdutoMaisPedidoPorPais;

--12 Quais os produtos tem mais cancelamento de envio?
CREATE VIEW vwProdutosMaisCancelamentos AS (
SELECT
    p.Produto,
    SUM(CASE WHEN v."Courier Status" = 'Cancelled' THEN 1 ELSE 0 END) AS Cancelamentos
FROM produtos p
JOIN vendas v ON p.Codigo = v.Codigo
GROUP BY p.Produto
ORDER BY Cancelamentos DESC);

SELECT * FROM vwProdutosMaisCancelamentos;

--13 Quais os produtos tem mais envio?
CREATE VIEW vwProdutosMaisEnvios as (
SELECT
    p.Produto,
    SUM(CASE WHEN v."Courier Status" = 'Shipped' THEN 1 ELSE 0 END) AS Enviados
FROM produtos p
JOIN vendas v ON p.Codigo = v.Codigo
GROUP BY p.Produto
ORDER BY Enviados DESC);

SELECT * FROM vwProdutosMaisEnvios;

--14 Quais os serviços de entregas mais pedidos?
CREATE VIEW vwServicosEntregaMaisPedidos AS (
SELECT
    DISTINCT v."ship-service-level" AS "Serviço de Entrega",
    COUNT(v."Order ID") OVER (PARTITION BY v."ship-service-level") AS TotalVendas
FROM
    vendas v
ORDER BY
    TotalVendas DESC);

SELECT * FROM vwServicosEntregaMaisPedidos;

--15 Quais os estilos mais pedidos?
CREATE VIEW vwEstilosMaisPedidos AS (
SELECT
    DISTINCT v."Style" AS Estilo,
    COUNT(v."Order ID") OVER (PARTITION BY v."Style") AS TotalVendas
FROM
    vendas v
ORDER BY
    TotalVendas DESC);

SELECT * FROM vwEstilosMaisPedidos;
   
