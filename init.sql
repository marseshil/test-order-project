create table IF NOT EXISTS categoryTree (
	ID SERIAL PRIMARY KEY,
	title varchar(2000) not null,
	parentId int4 null,
	CONSTRAINT categoryTree_id_fkey FOREIGN KEY (parentId) REFERENCES categoryTree(id)
);
--drop table categoryTree;

create table IF NOT EXISTS nomenclature (
	ID SERIAL PRIMARY KEY,
	title varchar(2000) not null,
	quantity int not null default 0,
	price NUMERIC(10, 2) null,
	categoryId int4 not null,
	CONSTRAINT nomenclature_categoryId_fkey FOREIGN KEY (categoryId) REFERENCES categoryTree(id)
);
--drop table nomenclature;

create table IF NOT EXISTS clients (
	ID SERIAL PRIMARY KEY,
	"name" varchar(1000) not null,
	adress text null
);
--drop table clients;

create table IF NOT EXISTS orders (
	ID SERIAL PRIMARY KEY,
	clientId int4 not null,
	orderDate TIMESTAMP NOT NULL DEFAULT NOW()
	CONSTRAINT orders_clientId_fkey FOREIGN KEY (clientId) REFERENCES clients(id)
);
--drop table orders;

create table IF NOT EXISTS orderNomenclatures (
	ID SERIAL PRIMARY KEY,
	orderId int4 not null,
	nomenclatureId int4 not null,
	quantity int null default 0,
	price NUMERIC(10, 2) null,
	CONSTRAINT orderNomenclatures_orderId_fkey FOREIGN KEY (orderId) REFERENCES orders(id),
	CONSTRAINT orderNomenclatures_nomenclatureId_fkey FOREIGN KEY (nomenclatureId) REFERENCES nomenclature(id)
);
--drop table orderNomenclatures;


-- ЗАПОЛНЕНИЕ ТАБЛИЦ ТЕСТОВЫМИ ДАННЫМИ

-- Очистить таблицы
-- TRUNCATE TABLE ordernomenclatures, orders, clients, nomenclature, categorytree RESTART IDENTITY CASCADE;

--Категории
INSERT INTO categorytree (title, parentid)
VALUES
('Электроника', NULL),
('Бытовая техника', NULL),
('Смартфоны', 1),
('Ноутбуки', 1),
('Холодильники', 2),
('Стиральные машины', 2);

-- Номенклатура (товары)
INSERT INTO nomenclature (title, quantity, price, categoryid)
VALUES
('iPhone 15', 10, 1200.00, 3),
('Samsung Galaxy S24', 15, 1100.00, 3),
('MacBook Air M3', 5, 1800.00, 4),
('Dell XPS 13', 8, 1600.00, 4),
('LG NoFrost', 4, 900.00, 5),
('Bosch CoolMax', 3, 950.00, 5),
('Samsung EcoWash', 6, 700.00, 6),
('LG TurboWash', 5, 750.00, 6);

-- Клиенты
INSERT INTO clients (name, adress)
VALUES
('ООО ТехноМаркет', 'г. Москва, ул. Ленина, д. 10'),
('ИП Смирнов А.А.', 'г. Санкт-Петербург, пр. Невский, д. 25'),
('ЗАО ЭлектроСеть', 'г. Казань, ул. Баумана, д. 5');

-- Заказы
INSERT INTO orders (clientid, "orderDate")
VALUES
(1, '2025-10-20'),  -- заказ для ТехноМаркет
(2, '2025-10-22');  -- заказ для ИП Смирнов

-- Состав заказов
-- Заказ 1 (id=1)
INSERT INTO ordernomenclatures (orderid, nomenclatureid, quantity, price)
VALUES
(1, 1, 2, 1200.00),
(1, 3, 1, 1800.00),
(1, 5, 1, 900.00);

-- Заказ 2 (id=2)
INSERT INTO ordernomenclatures (orderid, nomenclatureid, quantity, price)
VALUES
(2, 2, 1, 1100.00),
(2, 7, 1, 700.00),
(2, 8, 1, 750.00);