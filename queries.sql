-- Получение информации о сумме товаров заказанных под каждого клиента (Наименование клиента, сумма)
select c."name" as client_name, sum (o2.quantity * o2.price) as order_amount from clients c
join orders o on o.clientid = c.id 
join ordernomenclatures o2 on o2.orderid = o.id
group by c."name";

-- Найти количество дочерних элементов первого уровня вложенности для категорий номенклатуры
select ct.title, count(ct2.id) from categorytree ct
left join categorytree ct2 on ct2.parentid = ct.id
--where ct.parentid is null
group by ct.title;

-- Написать текст запроса для отчета (view) «Топ-5 самых покупаемых товаров за последний месяц» (по количеству штук в заказах).
-- В отчете должны быть: Наименование товара, Категория 1-го уровня, Общее количество проданных штук.

CREATE OR REPLACE VIEW top5_products_last_month AS
WITH category_level1 AS (
    SELECT
        ct.id,
        COALESCE(ctp.id, ct.id) AS level1_id,
        COALESCE(ctp.title, ct.title) AS level1_name
    FROM categoryTree ct
    LEFT JOIN categoryTree ctp ON ct.parentId = ctp.id
)
SELECT
    n.title AS product_name,
    cl1.level1_name AS category_level1,
    SUM(orn.quantity) AS total_sold
FROM orderNomenclatures orn
JOIN orders o ON o.id = orn.orderid 
JOIN nomenclature n ON n.id = orn.nomenclatureid 
JOIN category_level1 cl1 ON cl1.id = n.categoryid 
WHERE o."orderDate" >= NOW() - INTERVAL '1 month'
GROUP BY n.title, cl1.level1_name
ORDER BY total_sold DESC
LIMIT 5;

-- Оптимизация
-- 1. Добавить индексы, например, по orderDate
-- 2. Избавиться от WITH (например хранить level1_name в таблице nomenclature, обновляя при необходимости)
-- 3. Исользовать materialized view вместо view, обновлять там данные раз в месяц (например, с помощью CRON)
-- 4. Использовать агрегированные таблицы, в которых будет хранится кол-во заказанных продуктов в день/неделю