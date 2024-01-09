select * from PRODUCT;
select * from Users;
set timing on;
set timing off;
select * from MARK;
select * from PRODUCER;
select * from PURCHASE_PRODUCT;
select * from PURCHASE;
select * from TASTE_CHOCOLATE;
select * from ORDERS;

insert into MARK values ( 1, 'PODOBED');
insert into Basket values (1,1);
insert into Users values (1,'user','123');
insert into PRODUCER values ( 1, 'VLAD');
insert into TASTE_CHOCOLATE values ( 1, 'MILK');

drop table PURCHASE;
drop table PRODUCT;
drop table PURCHASE_PRODUCT;
drop table Basket;
drop table ORDERS;
drop table Basket_Product;
drop table MARK;
drop table PRODUCER;
drop table TASTE_CHOCOLATE;
drop table Users;

-- Пример вызова процедуры для добавления записи:
EXEC AddMark(2, 'Brand');
-- Пример вызова процедуры для удаления записи:
EXEC DeleteMark('d');

CREATE INDEX ICenerateMark ON MARK(BRAND_CODE);
CREATE INDEX IICenerateMark ON MARK(BRAND_NAME);

CREATE OR REPLACE PROCEDURE CenerateMark

AS
    v_Brand_code INT;
    v_Brand_name VARCHAR2(255);
BEGIN
    FOR i in 1..100000 LOOP
    v_Brand_code := i;
    v_Brand_name := DBMS_RANDOM.STRING('A',50);
    
    INSERT INTO MARK (BRAND_CODE,BRAND_NAME)
    VALUES (v_Brand_code,v_Brand_name);
    END LOOP;
    COMMIT;
END CenerateMark;

select max (BRAND_CODE) from MARK;

exec CenerateMark;
