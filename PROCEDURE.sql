CREATE OR REPLACE PROCEDURE MovePurchaseToOrders (
    p_user_id IN INT
)
IS
BEGIN
    -- ��������� ������ �� PURCHASE � ORDERS
    INSERT INTO ORDERS (ID_PRODUCT, ID_User, QUANTITY, SUM, DATE_BUY)
    SELECT ID_PRODUCT, ID_User, QUANTITY, SUM, DATE_BUY
    FROM PURCHASE
    WHERE ID_User = p_user_id;

    -- ������� ������ � ��������� ID_User �� PURCHASE
    DELETE FROM PURCHASE WHERE ID_User = p_user_id;

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        -- ��������� ������
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
    -- ������� ������ �� ������� PURCHASE ��������� � �������������
    DELETE FROM PURCHASE WHERE ID_User = p_user_id;

    -- ������� ������������ �� ������� Users
    DELETE FROM Users WHERE ID_User = p_user_id;

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        -- ��������� ������
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
CREATE OR REPLACE PROCEDURE AddPurchase (  ---���������� PURCHASE
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

CREATE OR REPLACE PROCEDURE DeletePurchase ( --- �������� PURCHASE
    p_id_buy IN INT
)
IS
BEGIN
    DELETE FROM PURCHASE WHERE ID_BUY = p_id_buy;
    COMMIT;
END DeletePurchase;

CREATE OR REPLACE PROCEDURE UpdatePurchase ( --��������� PURCHASE
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

    -- ������� ������ � ID_BUY = 1
    --UpdatePurchase(1, 3, 2, 8, 80, TO_DATE('2023-12-19', 'YYYY-MM-DD'));

    -- ������ ������ � ID_BUY = 2
    --DeletePurchase(4);
END;

--------------------------------------------------------------------------------
-- ��������� ��� ���������� ������ � ������� PURCHASE_PRODUCT
CREATE OR REPLACE PROCEDURE AddPurchaseProduct (
    p_id_buy IN INT,
    p_id_product IN INT,
    p_quantity IN INT,
    p_sum IN INT,
    p_date_buy IN DATE
)
IS
BEGIN
    -- �������� �� ������������� �����
    IF p_id_buy <= 0 OR p_id_product <= 0 OR p_quantity <= 0 OR p_sum <= 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'ERROR: All parameters must be positive numbers');
    END IF;

    -- �������� �� ���������� ����
    IF p_date_buy > SYSDATE THEN
        RAISE_APPLICATION_ERROR(-20002, 'ERROR: Date cannot be in the future');
    END IF;

    -- ��������� ������ � ������� PURCHASE
    INSERT INTO PURCHASE (ID_BUY, ID_PRODUCT, QUANTITY, SUM, DATE_BUY)
    VALUES (p_id_buy, p_id_product, p_quantity, p_sum, p_date_buy);

    -- ��������� ������ � ������� PURCHASE_PRODUCT
    INSERT INTO PURCHASE_PRODUCT (ID_BUY, ID_PRODUCT)
    VALUES (p_id_buy, p_id_product);

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        -- ��������� ������
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLCODE || ' - ' || SQLERRM);
        ROLLBACK;
END AddPurchaseProduct;

-- ��������� ��� �������� ������ �� ������� PURCHASE_PRODUCT
CREATE OR REPLACE PROCEDURE DeletePurchaseProduct (
    p_id_buy IN INT,
    p_id_product IN INT
)
IS
    v_count INT;
BEGIN
    -- �������� �� ������������� �����
    IF p_id_buy <= 0 OR p_id_product <= 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'ERROR: Parameters must be positive integers');
    END IF;

    -- �������� �� ������������� ������
    SELECT COUNT(*)
    INTO v_count
    FROM PURCHASE_PRODUCT
    WHERE ID_BUY = p_id_buy AND ID_PRODUCT = p_id_product;

    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'ERROR: Purchase product not found');
    END IF;

    -- ������� ������ �� ������� PURCHASE_PRODUCT
    DELETE FROM PURCHASE_PRODUCT
    WHERE ID_BUY = p_id_buy AND ID_PRODUCT = p_id_product;

    -- ������� ������ �� ������� PURCHASE
    DELETE FROM PURCHASE
    WHERE ID_BUY = p_id_buy AND ID_PRODUCT = p_id_product;

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        -- ��������� ������
        DBMS_OUTPUT.PUT_LINE('Error: || ' || SQLCODE || ' - ' || SQLERRM);
        ROLLBACK;
END DeletePurchaseProduct;

-- ��������� ��� ��������� ������ � ������� PURCHASE_PRODUCT
CREATE OR REPLACE PROCEDURE UpdatePurchaseProductQuantityAndSum (
    p_id_buy IN INT,
    p_id_product IN INT,
    p_quantity IN INT,
    p_sum IN INT
)
IS
    v_count INT;
BEGIN
    -- �������� �� ������������� �����
    IF p_id_buy <= 0 OR p_id_product <= 0 OR p_quantity <= 0 OR p_sum <= 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'ERROR: Parameters must be positive integers');
    END IF;

    -- �������� �� ������������� ������
    SELECT COUNT(*)
    INTO v_count
    FROM PURCHASE_PRODUCT
    WHERE ID_BUY = p_id_buy AND ID_PRODUCT = p_id_product;

    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'ERROR: Purchase product not found');
    END IF;

    -- ��������� ������ � ������� PURCHASE
    UPDATE PURCHASE
    SET QUANTITY = p_quantity, SUM = p_sum
    WHERE ID_BUY = p_id_buy AND ID_PRODUCT = p_id_product;

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        -- ��������� ������
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLCODE || ' - ' || SQLERRM);
        ROLLBACK;
END UpdatePurchaseProductQuantityAndSum;

-- ������ ������ ��������� ��� ���������� ������:
EXEC AddPurchaseProduct(2, 1, 5, 100, TO_DATE('2023-12-12', 'YYYY-MM-DD'));

-- ������ ������ ��������� ��� �������� ������:
EXEC DeletePurchaseProduct(1, 1);

-- ������ ������ ��������� ��� ��������� ������:
EXEC UpdatePurchaseProductQuantityAndSum(1, 1, 7, 150);
--------------------------------------------------------------------------------
-- ��������� ��� ���������� ������ � ������� PRODUCT
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
    p_id_user IN INT  -- ����� �������� ��� ID_User
)
IS
    v_Blob BLOB;
    v_File BFILE;
    v_id_buy INT;
    v_id_product INT;
BEGIN
    -- ��������� ���� � ������������
    v_File := BFILENAME('DIR', p_foto);
    DBMS_LOB.fileopen(v_File, DBMS_LOB.file_readonly);
    
    -- ������� BLOB � �������� ������ �� BFILE
    DBMS_LOB.createtemporary(v_Blob, TRUE);
    DBMS_LOB.loadfromfile(v_Blob, v_File, DBMS_LOB.getLength(v_File));
    
    -- ��������� BFILE
    DBMS_LOB.fileclose(v_File);

    -- ��������� ������ � ������� PRODUCT
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

    -- �������� ID_PRODUCT
    SELECT ID_PRODUCT INTO v_id_product FROM PRODUCT WHERE ID_PRODUCT = p_id_product;

    -- ��������� ������ � ������� PURCHASE
    INSERT INTO PURCHASE (
        ID_BUY,
        ID_USER,  -- ����� ������� ��� ID_User
        ID_PRODUCT,
        QUANTITY,
        SUM,
        DATE_BUY
    ) VALUES (
        p_id_product,
        p_id_user,  -- �������� ID_User, ���������� � �������� ���������
        p_id_product,
        p_quantity,
        p_sum,
        p_date_buy
    );

    -- ��������� ������ � ������� PURCHASE_PRODUCT
    INSERT INTO PURCHASE_PRODUCT (
        ID_BUY,
        ID_PRODUCT
    ) VALUES (
        p_id_product,
        p_id_product
    );

    -- ��������� ���������
    COMMIT;

    -- ����������� ��������� ������� BLOB
    DBMS_LOB.freetemporary(v_Blob);
END AddProduct;


-- ��������� ��� �������� ������ �� ������� PRODUCT
CREATE OR REPLACE PROCEDURE DeleteProduct (
    p_id_product IN VARCHAR2
)
IS
    n_id_product INT;
BEGIN
    -- ������� �������������� ������ � �����
    BEGIN
        n_id_product := TO_NUMBER(p_id_product);
    EXCEPTION
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20004, 'ID �������� ������ ���� ������');
            RETURN;
    END;

    IF n_id_product <= 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'ID �������� ������ ���� ������������� ������');
    ELSIF MOD(n_id_product, 1) <> 0 THEN
        RAISE_APPLICATION_ERROR(-20003, 'ID �������� ������ ���� ����� ������');
    ELSE
        -- ������� �������, ��� ��������� ������ � PURCHASE_PRODUCT � PURCHASE ����� ������� ��������
        DELETE FROM PRODUCT WHERE ID_PRODUCT = n_id_product;
        COMMIT;
    END IF;
EXCEPTION
    -- ������������ ��������, ����� �� ������ ������� � ��������� ID
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('������� � ��������� ID �� ������');
    WHEN OTHERS THEN
        -- ������������ ������ ������
        DBMS_OUTPUT.PUT_LINE('��������� ������: ' || SQLERRM);
END DeleteProduct;

-- ��������� ��� ��������� ������ � ������� PRODUCT
CREATE OR REPLACE PROCEDURE UpdateProductPriceAndFoto (
    p_id_product IN INT,
    p_price IN NUMBER,
    p_foto IN VARCHAR2
)
IS
    v_Blob BLOB;
    v_File BFILE;
BEGIN
    -- �������� �� ������������� �����
    IF p_id_product <= 0 OR p_price <= 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'ERROR: Product ID and price must be positive integers');
    END IF;

    -- �������� �� ������������� �����
    BEGIN
        v_File := BFILENAME('DIR', p_foto);
        DBMS_LOB.fileopen(v_File, DBMS_LOB.file_readonly);
        DBMS_LOB.fileclose(v_File);
    EXCEPTION
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20002, 'ERROR: File not found');
    END;

    -- ��������� BFILE ��� ������
    v_File := BFILENAME('DIR', p_foto);
    DBMS_LOB.fileopen(v_File, DBMS_LOB.file_readonly);
    
    -- ������� BLOB � �������� ������ �� BFILE
    DBMS_LOB.createtemporary(v_Blob, TRUE);
    DBMS_LOB.loadfromfile(v_Blob, v_File, DBMS_LOB.getLength(v_File));
    
    -- ��������� BFILE
    DBMS_LOB.fileclose(v_File);

    -- ��������� ������ � ������� PRODUCT
    UPDATE PRODUCT 
    SET PRICE = p_price, FOTO = v_Blob
    WHERE ID_PRODUCT = p_id_product;

    -- ��������� ������ � ������� PURCHASE
    UPDATE PURCHASE 
    SET PRICE = p_price
    WHERE ID_PRODUCT = p_id_product;

    -- ��������� ������ � ������� PURCHASE_PRODUCT
    UPDATE PURCHASE_PRODUCT 
    SET PRICE = p_price
    WHERE ID_PRODUCT = p_id_product;

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        -- ��������� ������
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLCODE || ' - ' || SQLERRM);
        ROLLBACK;
END UpdateProductPriceAndFoto;

--������ ������ ��������� ��� ���������� ������:
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
--������ ������ ��������� ��� �������� ������:
EXEC DeleteProduct(1);
--������ ������ ��������� ��� ��������� ������:
EXEC UpdateProductPriceAndFoto(2, 8, 'new_chocolate.jpg');
--------------------------------------------------------------------------------
-- ��������� ��� ���������� ������ � ������� MARK
CREATE OR REPLACE PROCEDURE AddMark (
    p_brand_code IN INT,
    p_brand_name IN VARCHAR2
)
IS
    brand_code_exists INT;
BEGIN
    -- ���������, ���������� �� ��� ������
    SELECT COUNT(*) INTO brand_code_exists FROM MARK WHERE BRAND_CODE = p_brand_code;

    IF p_brand_code <= 0 THEN
        RAISE_APPLICATION_ERROR(-20005, '��� ������ ������ ���� ������������� ������');
    ELSIF brand_code_exists > 0 THEN
        RAISE_APPLICATION_ERROR(-20007, '����� � ��������� ����� ��� ����������');
    END IF;

    FOR i IN 1..LENGTH(p_brand_name) LOOP
        IF ASCII(SUBSTR(p_brand_name, i, 1)) BETWEEN 48 AND 57 THEN
            RAISE_APPLICATION_ERROR(-20006, '�������� ������ �� ����� ��������� �����');
        END IF;
    END LOOP;

    INSERT INTO MARK (BRAND_CODE, BRAND_NAME)
    VALUES (p_brand_code, p_brand_name);

    -- ��������� ������ � ������� PRODUCT
    INSERT INTO PRODUCT (BRAND_CODE)
    VALUES (p_brand_code);

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        -- ������������ ������ ������
        DBMS_OUTPUT.PUT_LINE('��������� ������: ' || SQLERRM);
END AddMark;


-- ��������� ��� �������� ������ �� ������� MARK
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
            RAISE_APPLICATION_ERROR(-20004, 'ID �������� ������ ���� ������');
            RETURN;
    END;

    IF n_id_product <= 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'ID �������� ������ ���� ������������� ������');
    ELSIF MOD(n_id_product, 1) <> 0 THEN
        RAISE_APPLICATION_ERROR(-20003, 'ID �������� ������ ���� ����� ������');
        -- ������� ������ �� ������� PRODUCT
        DELETE FROM PRODUCT WHERE BRAND_CODE = p_brand_code;

        -- ������� ������ �� ������� MARK
        DELETE FROM MARK WHERE BRAND_CODE = p_brand_code;

        COMMIT;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        -- ������������ ������ ������
        DBMS_OUTPUT.PUT_LINE('��������� ������: ' || SQLERRM);
END DeleteMark;

-- ��������� ��� ��������� ������ � ������� MARK
CREATE OR REPLACE PROCEDURE UpdateMarkName (
    p_brand_code IN INT,
    p_brand_name IN VARCHAR2
)
IS
    v_brand_name_check NUMBER; -- ������� ���������� ��� �������� ��������� ��������

BEGIN
    -- �������� �� ������������� �������� ������� ���������
    IF p_brand_code <= 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'ERROR: Brand code must be a positive integer');
    END IF;

    -- �������� �� ��, ��� ������ �������� �� �������� ������
    BEGIN
        -- ������� ������������� ������ � �����
        SELECT TO_NUMBER(p_brand_name) INTO v_brand_name_check FROM DUAL;
        RAISE_APPLICATION_ERROR(-20002, 'ERROR: Brand name must be a non-numeric string');
    EXCEPTION
        WHEN VALUE_ERROR THEN
        NULL; -- ���������� ����������, ���� �������� �� �������� ������
    END;

    -- ��������� ������ � ������� MARK
    UPDATE MARK
    SET BRAND_NAME = p_brand_name
    WHERE BRAND_CODE = p_brand_code;

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        -- ��������� ������
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLCODE || ' - ' || SQLERRM);
        ROLLBACK;
END UpdateMarkName;

-- ������ ������ ��������� ��� ���������� ������:
EXEC AddMark(1, 'Vonka');

-- ������ ������ ��������� ��� �������� ������:
EXEC DeleteMark(3);

-- ������ ������ ��������� ��� ��������� ������:
EXEC UpdateMarkName(3, 'S');
--------------------------------------------------------------------------------
-- ��������� ��� ���������� ������ � ������� PRODUCER
CREATE SEQUENCE PRODUCT_SEQ START WITH 1 INCREMENT BY 1;

CREATE OR REPLACE PROCEDURE AddProducer (
    p_manufacturers_code IN INT,
    p_manufacturers_name IN VARCHAR2
)
IS
    v_seq_val NUMBER; -- ���������� ��� �������� �������� �� ������������������

BEGIN
    -- �������� �� ������������� �������� ������� ���������
    IF p_manufacturers_code <= 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'ERROR: Manufacturers code must be a positive integer');
    END IF;

    -- �������� �� ��, ��� ������ �������� �������� ���������� �������
    BEGIN
        -- ������� ������������� ������ � �����
        v_seq_val := TO_NUMBER(p_manufacturers_name);
        RAISE_APPLICATION_ERROR(-20002, 'ERROR: Manufacturers name must be a non-numeric string');
    EXCEPTION
        WHEN VALUE_ERROR THEN
            NULL; -- ���������� ����������, ���� �������� �������� ���������� �������
    END;

    -- ��������� ������ � ������� PRODUCER
    BEGIN
        INSERT INTO PRODUCER (MANUFACTURERS_CODE, MANUFACTURERS_NAME)
        VALUES (p_manufacturers_code, p_manufacturers_name);
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            RAISE_APPLICATION_ERROR(-20003, 'ERROR: Manufacturers code already exists');
    END;

    -- �������� �������� �� ������������������ PRODUCT_SEQ
    SELECT PRODUCT_SEQ.NEXTVAL INTO v_seq_val FROM DUAL;

    -- ��������� ������ � ������� PRODUCT
    INSERT INTO PRODUCT (ID_PRODUCT, MANUFACTURERS_CODE)
    VALUES (v_seq_val, p_manufacturers_code);

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        -- ��������� ������
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLCODE || ' - ' || SQLERRM);
        ROLLBACK;
END AddProducer;

-- ��������� ��� �������� ������ �� ������� PRODUCER
CREATE OR REPLACE PROCEDURE DeleteProducer (
    p_manufacturers_code IN INT
)
IS
    v_exists NUMBER; -- ���������� ��� �������� ������� ������
BEGIN
    -- �������� �� ������������� �������� ���������
    IF p_manufacturers_code <= 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'ERROR: Manufacturers code must be a positive integer');
    END IF;
    
    -- �������� �� ������������� ��������
    SELECT COUNT(*) INTO v_exists FROM PRODUCER WHERE MANUFACTURERS_CODE = p_manufacturers_code;
    IF v_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'ERROR: Manufacturers code does not exist');
    END IF;

    -- ������� ������ �� ������� PRODUCT
    DELETE FROM PRODUCT WHERE MANUFACTURERS_CODE = p_manufacturers_code;

    -- ������� ������ �� ������� PRODUCER
    DELETE FROM PRODUCER WHERE MANUFACTURERS_CODE = p_manufacturers_code;

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        -- ��������� ������
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLCODE || ' - ' || SQLERRM);
        ROLLBACK;
END DeleteProducer;

-- ��������� ��� ��������� ������ � ������� PRODUCER
CREATE OR REPLACE PROCEDURE UpdateProducerName
( 
    p_manufacturers_code IN INT, 
    p_manufacturers_name IN VARCHAR2
) 
IS 
    l_exists
NUMBER;
BEGIN -- �������� �� ������������� �������� ������� ���������
    IF p_manufacturers_code <= 0 THEN RAISE_APPLICATION_ERROR(-20001, 'ERROR: Manufacturers code must be a positive integer');
END IF;
-- �������� �� ��, ��� ������ �������� �������� ���������� �������
BEGIN
    -- ������� ������������� ������ � �����
    l_exists := TO_NUMBER(p_manufacturers_name);
    RAISE_APPLICATION_ERROR(-20002, 'ERROR: Manufacturers name must be a non-numeric string');
EXCEPTION
    WHEN VALUE_ERROR THEN
        NULL; -- ���������� ����������, ���� �������� �������� ���������� �������
END;
-- �������� �� ������������� ��������
SELECT COUNT(*) INTO l_exists
FROM PRODUCER
WHERE MANUFACTURERS_CODE = p_manufacturers_code;

IF l_exists = 0 THEN
    RAISE_APPLICATION_ERROR(-20003, 'ERROR: Manufacturers code does not exist');
END IF;

-- ��������� ������ � ������� PRODUCER
UPDATE PRODUCER
SET MANUFACTURERS_NAME = p_manufacturers_name
WHERE MANUFACTURERS_CODE = p_manufacturers_code;

COMMIT;
EXCEPTION WHEN OTHERS THEN -- ��������� ������ DBMS_OUTPUT.PUT_LINE('Error: ' || SQLCODE || ' - ' || SQLERRM);
ROLLBACK;
END UpdateProducerName;

-- ������ ������ ��������� ��� ���������� ������:
EXEC AddProducer(1, 'Producer');

-- ������ ������ ��������� ��� �������� ������:
EXEC DeleteProducer(2);

-- ������ ������ ��������� ��� ��������� ������:
EXEC UpdateProducerName(2, 'd');
--------------------------------------------------------------------------------
-- ��������� ��� ���������� ������ � ������� TASTE_CHOCOLATE
CREATE OR REPLACE PROCEDURE AddChocolateTaste (
    p_id_product IN INT,
    p_id_type_of_chocolate IN INT,
    p_the_name_the_taste_of_chocolate IN VARCHAR2
)
IS
BEGIN
    INSERT INTO TASTE_CHOCOLATE (ID_TYPE_OF_CHOCOLATE, THE_NAME_THE_TASTE_OF_CHOCOLATE)
    VALUES (p_id_type_of_chocolate, p_the_name_the_taste_of_chocolate);

    -- ��������� ������ � ������� PRODUCT
    INSERT INTO PRODUCT (ID_PRODUCT, ID_TYPE_OF_CHOCOLATE)
    VALUES (p_id_product, p_id_type_of_chocolate);

    COMMIT;
END AddChocolateTaste;

-- ��������� ��� �������� ������ �� ������� TASTE_CHOCOLATE
CREATE OR REPLACE PROCEDURE DeleteChocolateTaste (
    p_id_type_of_chocolate IN INT
)
IS
BEGIN
    -- ������� ������ �� ������� PRODUCT
    DELETE FROM PRODUCT WHERE ID_TYPE_OF_CHOCOLATE = p_id_type_of_chocolate;

    -- ������� ������ �� ������� TASTE_CHOCOLATE
    DELETE FROM TASTE_CHOCOLATE
    WHERE ID_TYPE_OF_CHOCOLATE = p_id_type_of_chocolate;

    COMMIT;
END DeleteChocolateTaste;

-- ��������� ��� ��������� ������ � ������� TASTE_CHOCOLATE
CREATE OR REPLACE PROCEDURE UpdateChocolateTasteName (
    p_id_type_of_chocolate IN INT,
    p_the_name_the_taste_of_chocolate IN VARCHAR2
)
IS
BEGIN
    -- ��������� ������ � ������� TASTE_CHOCOLATE
    UPDATE TASTE_CHOCOLATE
    SET THE_NAME_THE_TASTE_OF_CHOCOLATE = p_the_name_the_taste_of_chocolate
    WHERE ID_TYPE_OF_CHOCOLATE = p_id_type_of_chocolate;

    COMMIT;
END UpdateChocolateTasteName;

-- ������ ������ ��������� ��� ���������� ������:
EXEC AddChocolateTaste(2,2,'Sweet');

-- ������ ������ ��������� ��� �������� ������:
EXEC DeleteChocolateTaste(1);

-- ������ ������ ��������� ��� ��������� ������:
EXEC UpdateChocolateTasteName(1, 'Extra Sweet');
--------------------------------------------------------------------------------
-- ��������� ��� ���������� ������ � ������� "�������" (Busket)
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
-- ��������� ��� �������� ������ �� ������� "�������" (Busket)
CREATE OR REPLACE PROCEDURE RemoveFromBusket (
    p_id_user IN INT,
    p_id_product IN INT
)
IS
BEGIN
    DELETE FROM Busket WHERE ID_User = p_id_user AND ID_PRODUCT = p_id_product;
    COMMIT;
END RemoveFromBusket;
-- ��������� ��� ��������� ������ � ������� "�������" (Busket)
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
--������ ������ ��������� ��� ���������� ������:
EXEC AddToBusket(1, 1, 1, 1, 1001, 5001, '100g', 5, 'chocolate.jpg', 'Cocoa, Sugar, Milk');
--������ ������ ��������� ��� �������� ������:
EXEC RemoveFromBusket(1, 1);
--������ ������ ��������� ��� ��������� ������:
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
    -- ������� ������ ������
    DELETE FROM Basket_Product
    WHERE ID_Basket = p_old_ID_Basket AND ID_PRODUCT = p_old_ID_PRODUCT;

    -- ��������� ����� ������
    INSERT INTO Basket_Product (ID_Basket, ID_PRODUCT)
    VALUES (p_new_ID_Basket, p_new_ID_PRODUCT);

    COMMIT;
END;

-- ���������� ������
EXEC AddToBasketProduct(1, 100);

-- �������� ������
EXEC RemoveFromBasketProduct(1, 100);

-- ��������� ������ (�������� � ����������)
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
    -- �������� ������� ������� ����������
    SELECT COUNT(*)
    INTO v_column_count
    FROM USER_TAB_COLUMNS
    WHERE TABLE_NAME = 'PRODUCT' AND COLUMN_NAME = UPPER(p_sort_column);

    IF v_column_count = 0 THEN
        DBMS_OUTPUT.PUT_LINE('��������� ������� ��� ���������� �� ����������.');
        RETURN;
    END IF;

    -- ������������ SQL ��� ����������
    v_sql_statement := 'SELECT * FROM PRODUCT ORDER BY ' || p_sort_column;

    -- ��������� ������ ��� ������������� SQL
    OPEN v_cursor FOR v_sql_statement;

    -- ������������ ���������� �������
    LOOP
        FETCH v_cursor INTO v_rec;
        EXIT WHEN v_cursor%NOTFOUND;

        -- ������� ���������� �� �����
        DBMS_OUTPUT.PUT_LINE(
            v_rec.ID_PRODUCT || ', ' || v_rec.TYPE_OF_CHOCOLATE || ', ' || v_rec.ID_TYPE_OF_CHOCOLATE || ', ' ||
            v_rec.BRAND_CODE || ', ' || v_rec.MANUFACTURERS_CODE || ', ' || v_rec.WEIGHT || ', ' ||
            v_rec.PRICE || ', ' || TO_CHAR(v_rec.FOTO) || ', ' || v_rec.STRUCTURE
        );
    END LOOP;

    -- ��������� ������
    CLOSE v_cursor;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('������: ' || SQLERRM);
END SortAndDisplayProducts;

BEGIN
    SortAndDisplayProducts('PRICE');
END;

-- ���

BEGIN
    SortAndDisplayProducts('WEIGHT');
END;

--------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE SearchProduct (
    p_search_term VARCHAR2
)
IS
    v_found BOOLEAN := FALSE;  -- ���������� ��� ������������ ���������� ������
BEGIN
    FOR rec IN (SELECT * FROM PRODUCT WHERE UPPER(STRUCTURE) LIKE '%' || UPPER(p_search_term) || '%') 
    LOOP
        DBMS_OUTPUT.PUT_LINE(
            rec.ID_PRODUCT || ', ' || rec.TYPE_OF_CHOCOLATE || ', ' || rec.ID_TYPE_OF_CHOCOLATE || ', ' || 
            rec.BRAND_CODE || ', ' || rec.MANUFACTURERS_CODE || ', ' || rec.WEIGHT || ', ' || 
            rec.PRICE || ', ' || TO_CHAR(rec.FOTO) || ', ' || rec.STRUCTURE
        );
        
        v_found := TRUE;  -- ������������� ����, ��� ����� ��� ������
    END LOOP;

    -- ���� �� ������ ������ �� ���� �������, ���������� ���������� NO_DATA_FOUND
    IF v_found = FALSE THEN
        RAISE NO_DATA_FOUND;
    END IF;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('��� ������, ���������������� �������� ������.');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('������: ' || SQLERRM);
END SearchProduct;

BEGIN
    SearchProduct('Ingredients');
END;