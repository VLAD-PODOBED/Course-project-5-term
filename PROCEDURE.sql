CREATE OR REPLACE PROCEDURE MovePurchaseToOrders (
    p_user_id IN INT
)
IS
BEGIN
    -- Вставляем данные из PURCHASE в ORDERS
    INSERT INTO ORDERS (ID_PRODUCT, ID_User, QUANTITY, SUM, DATE_BUY)
    SELECT ID_PRODUCT, ID_User, QUANTITY, SUM, DATE_BUY
    FROM PURCHASE
    WHERE ID_User = p_user_id;

    -- Удаляем строки с указанным ID_User из PURCHASE
    DELETE FROM PURCHASE WHERE ID_User = p_user_id;

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        -- Обработка ошибок
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLCODE || ' - ' || SQLERRM);
        ROLLBACK;
END MovePurchaseToOrders;

exec MovePurchaseToOrders(1);
--------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE CascadeDeleteUser (
    p_user_id IN INT
)
IS
BEGIN
    -- Удаляем записи из таблицы PURCHASE связанные с пользователем
    DELETE FROM PURCHASE WHERE ID_User = p_user_id;

    -- Удаляем пользователя из таблицы Users
    DELETE FROM Users WHERE ID_User = p_user_id;

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        -- Обработка ошибок
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLCODE || ' - ' || SQLERRM);
        ROLLBACK;
END CascadeDeleteUser;

exec CascadeDeleteUser (1);
--------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE AddUser (
    p_id_user IN INT,
    p_login IN VARCHAR2,
    p_password IN VARCHAR2
)
IS
BEGIN
    INSERT INTO Users (ID_User, LOGIN, PASSWORD)
    VALUES (p_id_user, p_login, p_password);
    COMMIT;
END AddUser;

EXEC AddUser(1, 'User2', 123 );
--------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE DeleteUser (
    p_id_user IN INT
)
IS
BEGIN
    DELETE FROM Users WHERE ID_User = p_id_user;
    COMMIT;
END DeleteUser;
-------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE UpdatePassword (
    p_id_user IN INT,
    p_new_password IN VARCHAR2
)
IS
BEGIN
    UPDATE Users SET PASSWORD = p_new_password WHERE ID_User = p_id_user;
    COMMIT;
END UpdatePassword;
--------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE AddPurchase (  ---добавление PURCHASE
    p_id_buy IN INT,
    p_id_user IN INT,
    p_id_product IN INT,
    p_quantity IN INT,
    p_sum IN INT,
    p_date_buy IN DATE
)
IS
BEGIN
    INSERT INTO PURCHASE (ID_BUY, ID_User, ID_PRODUCT, QUANTITY, SUM, DATE_BUY)
    VALUES (p_id_buy, p_id_user, p_id_product, p_quantity, p_sum, p_date_buy);
    COMMIT;
END AddPurchase;

CREATE OR REPLACE PROCEDURE DeletePurchase ( --- удаление PURCHASE
    p_id_buy IN INT
)
IS
BEGIN
    DELETE FROM PURCHASE WHERE ID_BUY = p_id_buy;
    COMMIT;
END DeletePurchase;

CREATE OR REPLACE PROCEDURE UpdatePurchase ( --изменение PURCHASE
    p_id_buy IN INT,
    p_id_user IN INT,
    p_id_product IN INT,
    p_quantity IN INT,
    p_sum IN INT,
    p_date_buy IN DATE
)
IS
BEGIN
    UPDATE PURCHASE 
    SET ID_User = p_id_user, 
        ID_PRODUCT = p_id_product, 
        QUANTITY = p_quantity, 
        SUM = p_sum, 
        DATE_BUY = p_date_buy 
    WHERE ID_BUY = p_id_buy;
    COMMIT;
END UpdatePurchase;

BEGIN
    AddPurchase(7, 1, 1, 10, 100, TO_DATE('2023-12-20', 'YYYY-MM-DD'));
    --AddPurchase(2, 2, 1, 5, 50, TO_DATE('2023-12-20', 'YYYY-MM-DD'));

    -- Обновим запись с ID_BUY = 1
    --UpdatePurchase(1, 3, 2, 8, 80, TO_DATE('2023-12-19', 'YYYY-MM-DD'));

    -- Удалим запись с ID_BUY = 2
    --DeletePurchase(4);
END;

--------------------------------------------------------------------------------
-- Процедура для добавления данных в таблицу PURCHASE_PRODUCT
CREATE OR REPLACE PROCEDURE AddPurchaseProduct (
    p_id_buy IN INT,
    p_id_product IN INT,
    p_quantity IN INT,
    p_sum IN INT,
    p_date_buy IN DATE
)
IS
BEGIN
    -- Проверки на положительные числа
    IF p_id_buy <= 0 OR p_id_product <= 0 OR p_quantity <= 0 OR p_sum <= 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'ERROR: All parameters must be positive numbers');
    END IF;

    -- Проверка на корректную дату
    IF p_date_buy > SYSDATE THEN
        RAISE_APPLICATION_ERROR(-20002, 'ERROR: Date cannot be in the future');
    END IF;

    -- Добавляем запись в таблицу PURCHASE
    INSERT INTO PURCHASE (ID_BUY, ID_PRODUCT, QUANTITY, SUM, DATE_BUY)
    VALUES (p_id_buy, p_id_product, p_quantity, p_sum, p_date_buy);

    -- Добавляем запись в таблицу PURCHASE_PRODUCT
    INSERT INTO PURCHASE_PRODUCT (ID_BUY, ID_PRODUCT)
    VALUES (p_id_buy, p_id_product);

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        -- Обработка ошибок
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLCODE || ' - ' || SQLERRM);
        ROLLBACK;
END AddPurchaseProduct;

-- Процедура для удаления данных из таблицы PURCHASE_PRODUCT
CREATE OR REPLACE PROCEDURE DeletePurchaseProduct (
    p_id_buy IN INT,
    p_id_product IN INT
)
IS
    v_count INT;
BEGIN
    -- Проверка на положительные числа
    IF p_id_buy <= 0 OR p_id_product <= 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'ERROR: Parameters must be positive integers');
    END IF;

    -- Проверка на существование записи
    SELECT COUNT(*)
    INTO v_count
    FROM PURCHASE_PRODUCT
    WHERE ID_BUY = p_id_buy AND ID_PRODUCT = p_id_product;

    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'ERROR: Purchase product not found');
    END IF;

    -- Удаляем запись из таблицы PURCHASE_PRODUCT
    DELETE FROM PURCHASE_PRODUCT
    WHERE ID_BUY = p_id_buy AND ID_PRODUCT = p_id_product;

    -- Удаляем запись из таблицы PURCHASE
    DELETE FROM PURCHASE
    WHERE ID_BUY = p_id_buy AND ID_PRODUCT = p_id_product;

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        -- Обработка ошибок
        DBMS_OUTPUT.PUT_LINE('Error: || ' || SQLCODE || ' - ' || SQLERRM);
        ROLLBACK;
END DeletePurchaseProduct;

-- Процедура для изменения данных в таблице PURCHASE_PRODUCT
CREATE OR REPLACE PROCEDURE UpdatePurchaseProductQuantityAndSum (
    p_id_buy IN INT,
    p_id_product IN INT,
    p_quantity IN INT,
    p_sum IN INT
)
IS
    v_count INT;
BEGIN
    -- Проверка на положительные числа
    IF p_id_buy <= 0 OR p_id_product <= 0 OR p_quantity <= 0 OR p_sum <= 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'ERROR: Parameters must be positive integers');
    END IF;

    -- Проверка на существование записи
    SELECT COUNT(*)
    INTO v_count
    FROM PURCHASE_PRODUCT
    WHERE ID_BUY = p_id_buy AND ID_PRODUCT = p_id_product;

    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'ERROR: Purchase product not found');
    END IF;

    -- Обновляем запись в таблице PURCHASE
    UPDATE PURCHASE
    SET QUANTITY = p_quantity, SUM = p_sum
    WHERE ID_BUY = p_id_buy AND ID_PRODUCT = p_id_product;

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        -- Обработка ошибок
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLCODE || ' - ' || SQLERRM);
        ROLLBACK;
END UpdatePurchaseProductQuantityAndSum;

-- Пример вызова процедуры для добавления записи:
EXEC AddPurchaseProduct(2, 1, 5, 100, TO_DATE('2023-12-12', 'YYYY-MM-DD'));

-- Пример вызова процедуры для удаления записи:
EXEC DeletePurchaseProduct(1, 1);

-- Пример вызова процедуры для изменения записи:
EXEC UpdatePurchaseProductQuantityAndSum(1, 1, 7, 150);
--------------------------------------------------------------------------------
-- Процедура для добавления данных в таблицу PRODUCT
CREATE OR REPLACE PROCEDURE AddProduct (
    p_id_product IN INT,
    p_type_chocolate IN NUMBER,
    p_id_type_chocolate IN NUMBER,
    p_brand_code IN NUMBER,
    p_manufacturers_code IN NUMBER,
    p_weight IN VARCHAR2,
    p_price IN NUMBER,
    p_foto IN VARCHAR2,
    p_structure IN VARCHAR2,
    p_quantity IN INT,
    p_sum IN INT,
    p_date_buy IN DATE,
    p_id_user IN INT  -- Новый параметр для ID_User
)
IS
    v_Blob BLOB;
    v_File BFILE;
    v_id_buy INT;
    v_id_product INT;
BEGIN
    -- Открываем файл с изображением
    v_File := BFILENAME('DIR', p_foto);
    DBMS_LOB.fileopen(v_File, DBMS_LOB.file_readonly);
    
    -- Создаем BLOB и копируем данные из BFILE
    DBMS_LOB.createtemporary(v_Blob, TRUE);
    DBMS_LOB.loadfromfile(v_Blob, v_File, DBMS_LOB.getLength(v_File));
    
    -- Закрываем BFILE
    DBMS_LOB.fileclose(v_File);

    -- Вставляем данные в таблицу PRODUCT
    INSERT INTO PRODUCT (
        ID_PRODUCT,
        TYPE_OF_CHOCOLATE,
        ID_TYPE_OF_CHOCOLATE,
        BRAND_CODE,
        MANUFACTURERS_CODE,
        WEIGHT,
        PRICE,
        FOTO,
        STRUCTURE
    ) VALUES (
        p_id_product,
        p_type_chocolate,
        p_id_type_chocolate,
        p_brand_code,
        p_manufacturers_code,
        p_weight,
        p_price,
        v_Blob,
        p_structure
    );

    -- Получаем ID_PRODUCT
    SELECT ID_PRODUCT INTO v_id_product FROM PRODUCT WHERE ID_PRODUCT = p_id_product;

    -- Вставляем данные в таблицу PURCHASE
    INSERT INTO PURCHASE (
        ID_BUY,
        ID_USER,  -- Новый столбец для ID_User
        ID_PRODUCT,
        QUANTITY,
        SUM,
        DATE_BUY
    ) VALUES (
        p_id_product,
        p_id_user,  -- Значение ID_User, переданное в качестве параметра
        p_id_product,
        p_quantity,
        p_sum,
        p_date_buy
    );

    -- Вставляем данные в таблицу PURCHASE_PRODUCT
    INSERT INTO PURCHASE_PRODUCT (
        ID_BUY,
        ID_PRODUCT
    ) VALUES (
        p_id_product,
        p_id_product
    );

    -- Фиксируем изменения
    COMMIT;

    -- Освобождаем временные ресурсы BLOB
    DBMS_LOB.freetemporary(v_Blob);
END AddProduct;


-- Процедура для удаления данных из таблицы PRODUCT
CREATE OR REPLACE PROCEDURE DeleteProduct (
    p_id_product IN VARCHAR2
)
IS
    n_id_product INT;
BEGIN
    -- Пробуем конвертировать строку в число
    BEGIN
        n_id_product := TO_NUMBER(p_id_product);
    EXCEPTION
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20004, 'ID продукта должен быть числом');
            RETURN;
    END;

    IF n_id_product <= 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'ID продукта должен быть положительным числом');
    ELSIF MOD(n_id_product, 1) <> 0 THEN
        RAISE_APPLICATION_ERROR(-20003, 'ID продукта должен быть целым числом');
    ELSE
        -- Удаляем продукт, все связанные записи в PURCHASE_PRODUCT и PURCHASE будут удалены каскадно
        DELETE FROM PRODUCT WHERE ID_PRODUCT = n_id_product;
        COMMIT;
    END IF;
EXCEPTION
    -- Обрабатываем ситуацию, когда не найден продукт с указанным ID
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Продукт с указанным ID не найден');
    WHEN OTHERS THEN
        -- Обрабатываем другие ошибки
        DBMS_OUTPUT.PUT_LINE('Произошла ошибка: ' || SQLERRM);
END DeleteProduct;

-- Процедура для изменения данных в таблице PRODUCT
CREATE OR REPLACE PROCEDURE UpdateProductPriceAndFoto (
    p_id_product IN INT,
    p_price IN NUMBER,
    p_foto IN VARCHAR2
)
IS
    v_Blob BLOB;
    v_File BFILE;
BEGIN
    -- Проверка на положительные числа
    IF p_id_product <= 0 OR p_price <= 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'ERROR: Product ID and price must be positive integers');
    END IF;

    -- Проверка на существование файла
    BEGIN
        v_File := BFILENAME('DIR', p_foto);
        DBMS_LOB.fileopen(v_File, DBMS_LOB.file_readonly);
        DBMS_LOB.fileclose(v_File);
    EXCEPTION
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20002, 'ERROR: File not found');
    END;

    -- Открываем BFILE для чтения
    v_File := BFILENAME('DIR', p_foto);
    DBMS_LOB.fileopen(v_File, DBMS_LOB.file_readonly);
    
    -- Создаем BLOB и копируем данные из BFILE
    DBMS_LOB.createtemporary(v_Blob, TRUE);
    DBMS_LOB.loadfromfile(v_Blob, v_File, DBMS_LOB.getLength(v_File));
    
    -- Закрываем BFILE
    DBMS_LOB.fileclose(v_File);

    -- Обновляем запись в таблице PRODUCT
    UPDATE PRODUCT 
    SET PRICE = p_price, FOTO = v_Blob
    WHERE ID_PRODUCT = p_id_product;

    -- Обновляем записи в таблице PURCHASE
    UPDATE PURCHASE 
    SET PRICE = p_price
    WHERE ID_PRODUCT = p_id_product;

    -- Обновляем записи в таблице PURCHASE_PRODUCT
    UPDATE PURCHASE_PRODUCT 
    SET PRICE = p_price
    WHERE ID_PRODUCT = p_id_product;

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        -- Обработка ошибок
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLCODE || ' - ' || SQLERRM);
        ROLLBACK;
END UpdateProductPriceAndFoto;

--Пример вызова процедуры для добавления записи:
BEGIN
    AddProduct(
        p_id_product => 4,
        p_type_chocolate => 1,
        p_id_type_chocolate => 2,
        p_brand_code => 1,
        p_manufacturers_code => 1,
        p_weight => '19g',
        p_price => 100,
        p_foto => 'chocolate.jpg',
        p_structure => 'Ingredients',
        p_quantity => 5,
        p_sum => 55,
        p_date_buy => TO_DATE('2023-01-01', 'YYYY-MM-DD'),
        p_id_user => 1
    );
END;
--Пример вызова процедуры для удаления записи:
EXEC DeleteProduct(1);
--Пример вызова процедуры для изменения записи:
EXEC UpdateProductPriceAndFoto(2, 8, 'new_chocolate.jpg');
--------------------------------------------------------------------------------
-- Процедура для добавления данных в таблицу MARK
CREATE OR REPLACE PROCEDURE AddMark (
    p_brand_code IN INT,
    p_brand_name IN VARCHAR2
)
IS
    brand_code_exists INT;
BEGIN
    -- Проверяем, существует ли код бренда
    SELECT COUNT(*) INTO brand_code_exists FROM MARK WHERE BRAND_CODE = p_brand_code;

    IF p_brand_code <= 0 THEN
        RAISE_APPLICATION_ERROR(-20005, 'Код бренда должен быть положительным числом');
    ELSIF brand_code_exists > 0 THEN
        RAISE_APPLICATION_ERROR(-20007, 'Бренд с указанным кодом уже существует');
    END IF;

    FOR i IN 1..LENGTH(p_brand_name) LOOP
        IF ASCII(SUBSTR(p_brand_name, i, 1)) BETWEEN 48 AND 57 THEN
            RAISE_APPLICATION_ERROR(-20006, 'Название бренда не может содержать числа');
        END IF;
    END LOOP;

    INSERT INTO MARK (BRAND_CODE, BRAND_NAME)
    VALUES (p_brand_code, p_brand_name);

    -- Добавляем запись в таблицу PRODUCT
    INSERT INTO PRODUCT (BRAND_CODE)
    VALUES (p_brand_code);

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        -- Обрабатываем другие ошибки
        DBMS_OUTPUT.PUT_LINE('Произошла ошибка: ' || SQLERRM);
END AddMark;


-- Процедура для удаления данных из таблицы MARK
CREATE OR REPLACE PROCEDURE DeleteMark (
    p_brand_code IN NUMBER
)
IS
   n_id_product INT;
BEGIN
    BEGIN
        n_id_product := TO_NUMBER(p_brand_code);
    EXCEPTION
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20004, 'ID продукта должен быть числом');
            RETURN;
    END;

    IF n_id_product <= 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'ID продукта должен быть положительным числом');
    ELSIF MOD(n_id_product, 1) <> 0 THEN
        RAISE_APPLICATION_ERROR(-20003, 'ID продукта должен быть целым числом');
        -- Удаляем запись из таблицы PRODUCT
        DELETE FROM PRODUCT WHERE BRAND_CODE = p_brand_code;

        -- Удаляем запись из таблицы MARK
        DELETE FROM MARK WHERE BRAND_CODE = p_brand_code;

        COMMIT;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        -- Обрабатываем другие ошибки
        DBMS_OUTPUT.PUT_LINE('Произошла ошибка: ' || SQLERRM);
END DeleteMark;

-- Процедура для изменения данных в таблице MARK
CREATE OR REPLACE PROCEDURE UpdateMarkName (
    p_brand_code IN INT,
    p_brand_name IN VARCHAR2
)
IS
    v_brand_name_check NUMBER; -- Добавим переменную для проверки числового значения

BEGIN
    -- Проверка на положительное значение первого параметра
    IF p_brand_code <= 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'ERROR: Brand code must be a positive integer');
    END IF;

    -- Проверка на то, что второй параметр не является числом
    BEGIN
        -- Пробуем преобразовать строку в число
        SELECT TO_NUMBER(p_brand_name) INTO v_brand_name_check FROM DUAL;
        RAISE_APPLICATION_ERROR(-20002, 'ERROR: Brand name must be a non-numeric string');
    EXCEPTION
        WHEN VALUE_ERROR THEN
        NULL; -- Продолжаем выполнение, если значение не является числом
    END;

    -- Обновляем запись в таблице MARK
    UPDATE MARK
    SET BRAND_NAME = p_brand_name
    WHERE BRAND_CODE = p_brand_code;

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        -- Обработка ошибок
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLCODE || ' - ' || SQLERRM);
        ROLLBACK;
END UpdateMarkName;

-- Пример вызова процедуры для добавления записи:
EXEC AddMark(1, 'Vonka');

-- Пример вызова процедуры для удаления записи:
EXEC DeleteMark(3);

-- Пример вызова процедуры для изменения записи:
EXEC UpdateMarkName(3, 'S');
--------------------------------------------------------------------------------
-- Процедура для добавления данных в таблицу PRODUCER
CREATE SEQUENCE PRODUCT_SEQ START WITH 1 INCREMENT BY 1;

CREATE OR REPLACE PROCEDURE AddProducer (
    p_manufacturers_code IN INT,
    p_manufacturers_name IN VARCHAR2
)
IS
    v_seq_val NUMBER; -- переменная для хранения значения из последовательности

BEGIN
    -- Проверка на положительное значение первого параметра
    IF p_manufacturers_code <= 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'ERROR: Manufacturers code must be a positive integer');
    END IF;

    -- Проверка на то, что второй параметр является нечисловой строкой
    BEGIN
        -- Пробуем преобразовать строку в число
        v_seq_val := TO_NUMBER(p_manufacturers_name);
        RAISE_APPLICATION_ERROR(-20002, 'ERROR: Manufacturers name must be a non-numeric string');
    EXCEPTION
        WHEN VALUE_ERROR THEN
            NULL; -- Продолжаем выполнение, если значение является нечисловой строкой
    END;

    -- Добавляем запись в таблицу PRODUCER
    BEGIN
        INSERT INTO PRODUCER (MANUFACTURERS_CODE, MANUFACTURERS_NAME)
        VALUES (p_manufacturers_code, p_manufacturers_name);
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            RAISE_APPLICATION_ERROR(-20003, 'ERROR: Manufacturers code already exists');
    END;

    -- Получаем значение из последовательности PRODUCT_SEQ
    SELECT PRODUCT_SEQ.NEXTVAL INTO v_seq_val FROM DUAL;

    -- Добавляем запись в таблицу PRODUCT
    INSERT INTO PRODUCT (ID_PRODUCT, MANUFACTURERS_CODE)
    VALUES (v_seq_val, p_manufacturers_code);

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        -- Обработка ошибок
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLCODE || ' - ' || SQLERRM);
        ROLLBACK;
END AddProducer;

-- Процедура для удаления данных из таблицы PRODUCER
CREATE OR REPLACE PROCEDURE DeleteProducer (
    p_manufacturers_code IN INT
)
IS
    v_exists NUMBER; -- переменная для проверки наличия записи
BEGIN
    -- Проверка на положительное значение параметра
    IF p_manufacturers_code <= 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'ERROR: Manufacturers code must be a positive integer');
    END IF;
    
    -- Проверка на существование элемента
    SELECT COUNT(*) INTO v_exists FROM PRODUCER WHERE MANUFACTURERS_CODE = p_manufacturers_code;
    IF v_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'ERROR: Manufacturers code does not exist');
    END IF;

    -- Удаляем запись из таблицы PRODUCT
    DELETE FROM PRODUCT WHERE MANUFACTURERS_CODE = p_manufacturers_code;

    -- Удаляем запись из таблицы PRODUCER
    DELETE FROM PRODUCER WHERE MANUFACTURERS_CODE = p_manufacturers_code;

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        -- Обработка ошибок
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLCODE || ' - ' || SQLERRM);
        ROLLBACK;
END DeleteProducer;

-- Процедура для изменения данных в таблице PRODUCER
CREATE OR REPLACE PROCEDURE UpdateProducerName
( 
    p_manufacturers_code IN INT, 
    p_manufacturers_name IN VARCHAR2
) 
IS 
    l_exists
NUMBER;
BEGIN -- Проверка на положительное значение первого параметра
    IF p_manufacturers_code <= 0 THEN RAISE_APPLICATION_ERROR(-20001, 'ERROR: Manufacturers code must be a positive integer');
END IF;
-- Проверка на то, что второй параметр является нечисловой строкой
BEGIN
    -- Пробуем преобразовать строку в число
    l_exists := TO_NUMBER(p_manufacturers_name);
    RAISE_APPLICATION_ERROR(-20002, 'ERROR: Manufacturers name must be a non-numeric string');
EXCEPTION
    WHEN VALUE_ERROR THEN
        NULL; -- Продолжаем выполнение, если значение является нечисловой строкой
END;
-- Проверка на существование элемента
SELECT COUNT(*) INTO l_exists
FROM PRODUCER
WHERE MANUFACTURERS_CODE = p_manufacturers_code;

IF l_exists = 0 THEN
    RAISE_APPLICATION_ERROR(-20003, 'ERROR: Manufacturers code does not exist');
END IF;

-- Обновляем запись в таблице PRODUCER
UPDATE PRODUCER
SET MANUFACTURERS_NAME = p_manufacturers_name
WHERE MANUFACTURERS_CODE = p_manufacturers_code;

COMMIT;
EXCEPTION WHEN OTHERS THEN -- Обработка ошибок DBMS_OUTPUT.PUT_LINE('Error: ' || SQLCODE || ' - ' || SQLERRM);
ROLLBACK;
END UpdateProducerName;

-- Пример вызова процедуры для добавления записи:
EXEC AddProducer(1, 'Producer');

-- Пример вызова процедуры для удаления записи:
EXEC DeleteProducer(2);

-- Пример вызова процедуры для изменения записи:
EXEC UpdateProducerName(2, 'd');
--------------------------------------------------------------------------------
-- Процедура для добавления данных в таблицу TASTE_CHOCOLATE
CREATE OR REPLACE PROCEDURE AddChocolateTaste (
    p_id_product IN INT,
    p_id_type_of_chocolate IN INT,
    p_the_name_the_taste_of_chocolate IN VARCHAR2
)
IS
BEGIN
    INSERT INTO TASTE_CHOCOLATE (ID_TYPE_OF_CHOCOLATE, THE_NAME_THE_TASTE_OF_CHOCOLATE)
    VALUES (p_id_type_of_chocolate, p_the_name_the_taste_of_chocolate);

    -- Добавляем запись в таблицу PRODUCT
    INSERT INTO PRODUCT (ID_PRODUCT, ID_TYPE_OF_CHOCOLATE)
    VALUES (p_id_product, p_id_type_of_chocolate);

    COMMIT;
END AddChocolateTaste;

-- Процедура для удаления данных из таблицы TASTE_CHOCOLATE
CREATE OR REPLACE PROCEDURE DeleteChocolateTaste (
    p_id_type_of_chocolate IN INT
)
IS
BEGIN
    -- Удаляем запись из таблицы PRODUCT
    DELETE FROM PRODUCT WHERE ID_TYPE_OF_CHOCOLATE = p_id_type_of_chocolate;

    -- Удаляем запись из таблицы TASTE_CHOCOLATE
    DELETE FROM TASTE_CHOCOLATE
    WHERE ID_TYPE_OF_CHOCOLATE = p_id_type_of_chocolate;

    COMMIT;
END DeleteChocolateTaste;

-- Процедура для изменения данных в таблице TASTE_CHOCOLATE
CREATE OR REPLACE PROCEDURE UpdateChocolateTasteName (
    p_id_type_of_chocolate IN INT,
    p_the_name_the_taste_of_chocolate IN VARCHAR2
)
IS
BEGIN
    -- Обновляем запись в таблице TASTE_CHOCOLATE
    UPDATE TASTE_CHOCOLATE
    SET THE_NAME_THE_TASTE_OF_CHOCOLATE = p_the_name_the_taste_of_chocolate
    WHERE ID_TYPE_OF_CHOCOLATE = p_id_type_of_chocolate;

    COMMIT;
END UpdateChocolateTasteName;

-- Пример вызова процедуры для добавления записи:
EXEC AddChocolateTaste(2,2,'Sweet');

-- Пример вызова процедуры для удаления записи:
EXEC DeleteChocolateTaste(1);

-- Пример вызова процедуры для изменения записи:
EXEC UpdateChocolateTasteName(1, 'Extra Sweet');
--------------------------------------------------------------------------------
-- Процедура для добавления данных в таблицу "Корзина" (Busket)
CREATE OR REPLACE PROCEDURE AddToBusket (
    p_id_user IN INT,
    p_id_product IN INT,
    p_type_of_chocolate IN INT,
    p_id_type_of_chocolate IN INT,
    p_brand_code IN INT,
    p_manufacturers_code IN INT,
    p_weight IN VARCHAR2,
    p_price IN INT,
    p_foto IN VARCHAR2,
    p_structure IN VARCHAR2
)
IS
BEGIN
    INSERT INTO Busket (ID_User, ID_PRODUCT, TYPE_OF_CHOCOLATE, ID_TYPE_OF_CHOCOLATE, BRAND_CODE, MANUFACTURERS_CODE, WEIGHT, PRICE, FOTO, STRUCTURE)
    VALUES (p_id_user, p_id_product, p_type_of_chocolate, p_id_type_of_chocolate, p_brand_code, p_manufacturers_code, p_weight, p_price, p_foto, p_structure);
    COMMIT;
END AddToBusket;
-- Процедура для удаления данных из таблицы "Корзина" (Busket)
CREATE OR REPLACE PROCEDURE RemoveFromBusket (
    p_id_user IN INT,
    p_id_product IN INT
)
IS
BEGIN
    DELETE FROM Busket WHERE ID_User = p_id_user AND ID_PRODUCT = p_id_product;
    COMMIT;
END RemoveFromBusket;
-- Процедура для изменения данных в таблице "Корзина" (Busket)
CREATE OR REPLACE PROCEDURE UpdateBusketItemPrice (
    p_id_user IN INT,
    p_id_product IN INT,
    p_new_price IN INT
)
IS
BEGIN
    UPDATE Busket
    SET PRICE = p_new_price
    WHERE ID_User = p_id_user AND ID_PRODUCT = p_id_product;
    COMMIT;
END UpdateBusketItemPrice;
--Пример вызова процедуры для добавления записи:
EXEC AddToBusket(1, 1, 1, 1, 1001, 5001, '100g', 5, 'chocolate.jpg', 'Cocoa, Sugar, Milk');
--Пример вызова процедуры для удаления записи:
EXEC RemoveFromBusket(1, 1);
--Пример вызова процедуры для изменения записи:
EXEC UpdateBusketItemPrice(1, 1, 8);

--------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE AddToBasketProduct (
    p_ID_Basket INT,
    p_ID_PRODUCT INT
)
AS
BEGIN
    INSERT INTO Basket_Product (ID_Basket, ID_PRODUCT)
    VALUES (p_ID_Basket, p_ID_PRODUCT);
    COMMIT;
END;

CREATE OR REPLACE PROCEDURE RemoveFromBasketProduct (
    p_ID_Basket INT,
    p_ID_PRODUCT INT
)
AS
BEGIN
    DELETE FROM Basket_Product
    WHERE ID_Basket = p_ID_Basket AND ID_PRODUCT = p_ID_PRODUCT;
    COMMIT;
END;

CREATE OR REPLACE PROCEDURE UpdateBasketProduct (
    p_old_ID_Basket INT,
    p_old_ID_PRODUCT INT,
    p_new_ID_Basket INT,
    p_new_ID_PRODUCT INT
)
AS
BEGIN
    -- Удаляем старую запись
    DELETE FROM Basket_Product
    WHERE ID_Basket = p_old_ID_Basket AND ID_PRODUCT = p_old_ID_PRODUCT;

    -- Добавляем новую запись
    INSERT INTO Basket_Product (ID_Basket, ID_PRODUCT)
    VALUES (p_new_ID_Basket, p_new_ID_PRODUCT);

    COMMIT;
END;

-- Добавление записи
EXEC AddToBasketProduct(1, 100);

-- Удаление записи
EXEC RemoveFromBasketProduct(1, 100);

-- Изменение записи (удаление и добавление)
EXEC UpdateBasketProduct(1, 100, 2, 200);

--------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE SortAndDisplayProducts (
    p_sort_column VARCHAR2
)
IS
    v_column_count NUMBER;
    v_sql_statement VARCHAR2(4000);
    v_cursor SYS_REFCURSOR;
    v_rec PRODUCT%ROWTYPE;
BEGIN
    -- Проверка наличия колонки сортировки
    SELECT COUNT(*)
    INTO v_column_count
    FROM USER_TAB_COLUMNS
    WHERE TABLE_NAME = 'PRODUCT' AND COLUMN_NAME = UPPER(p_sort_column);

    IF v_column_count = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Указанной колонки для сортировки не существует.');
        RETURN;
    END IF;

    -- Динамический SQL для сортировки
    v_sql_statement := 'SELECT * FROM PRODUCT ORDER BY ' || p_sort_column;

    -- Открываем курсор для динамического SQL
    OPEN v_cursor FOR v_sql_statement;

    -- Обрабатываем результаты запроса
    LOOP
        FETCH v_cursor INTO v_rec;
        EXIT WHEN v_cursor%NOTFOUND;

        -- Выводим результаты на экран
        DBMS_OUTPUT.PUT_LINE(
            v_rec.ID_PRODUCT || ', ' || v_rec.TYPE_OF_CHOCOLATE || ', ' || v_rec.ID_TYPE_OF_CHOCOLATE || ', ' ||
            v_rec.BRAND_CODE || ', ' || v_rec.MANUFACTURERS_CODE || ', ' || v_rec.WEIGHT || ', ' ||
            v_rec.PRICE || ', ' || TO_CHAR(v_rec.FOTO) || ', ' || v_rec.STRUCTURE
        );
    END LOOP;

    -- Закрываем курсор
    CLOSE v_cursor;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Ошибка: ' || SQLERRM);
END SortAndDisplayProducts;

BEGIN
    SortAndDisplayProducts('PRICE');
END;

-- ИЛИ

BEGIN
    SortAndDisplayProducts('WEIGHT');
END;

--------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE SearchProduct (
    p_search_term VARCHAR2
)
IS
    v_found BOOLEAN := FALSE;  -- Переменная для отслеживания найденного товара
BEGIN
    FOR rec IN (SELECT * FROM PRODUCT WHERE UPPER(STRUCTURE) LIKE '%' || UPPER(p_search_term) || '%') 
    LOOP
        DBMS_OUTPUT.PUT_LINE(
            rec.ID_PRODUCT || ', ' || rec.TYPE_OF_CHOCOLATE || ', ' || rec.ID_TYPE_OF_CHOCOLATE || ', ' || 
            rec.BRAND_CODE || ', ' || rec.MANUFACTURERS_CODE || ', ' || rec.WEIGHT || ', ' || 
            rec.PRICE || ', ' || TO_CHAR(rec.FOTO) || ', ' || rec.STRUCTURE
        );
        
        v_found := TRUE;  -- Устанавливаем флаг, что товар был найден
    END LOOP;

    -- Если ни одного товара не было найдено, генерируем исключение NO_DATA_FOUND
    IF v_found = FALSE THEN
        RAISE NO_DATA_FOUND;
    END IF;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('Нет товара, соответствующего критерию поиска.');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Ошибка: ' || SQLERRM);
END SearchProduct;

BEGIN
    SearchProduct('Ingredients');
END;