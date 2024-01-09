ALTER SESSION SET "_oracle_script" = TRUE;

CREATE OR REPLACE DIRECTORY DIR AS 'D:\image';

GRANT READ ON DIRECTORY DIR TO SYS;

CREATE TABLE PURCHASE (
    ID_BUY INT PRIMARY KEY,
    ID_User INT,
    ID_PRODUCT INT,
    QUANTITY INT,
    SUM INT,
    DATE_BUY DATE,
    FOREIGN KEY (ID_PRODUCT) REFERENCES PRODUCT(ID_PRODUCT) ON DELETE CASCADE
);

CREATE TABLE PRODUCT (
    ID_PRODUCT INT PRIMARY KEY,
    TYPE_OF_CHOCOLATE NUMBER(10),
    ID_TYPE_OF_CHOCOLATE NUMBER(10),
    BRAND_CODE NUMBER(10),
    MANUFACTURERS_CODE NUMBER(10),
    WEIGHT VARCHAR2(255),
    PRICE NUMBER(10),
    FOTO BLOB,
    STRUCTURE VARCHAR2(255)
);

ALTER TABLE PRODUCT;

ALTER TABLE PRODUCT
ADD CONSTRAINT FK_MARK_PRODUCT
FOREIGN KEY (BRAND_CODE) REFERENCES MARK(BRAND_CODE);

ALTER TABLE PRODUCT
ADD CONSTRAINT FK_PRODUCER_PRODUCT
FOREIGN KEY (MANUFACTURERS_CODE) REFERENCES PRODUCER(MANUFACTURERS_CODE);

ALTER TABLE PRODUCT
ADD CONSTRAINT FK_PRODUCT_TASTE_CHOCOLATE
FOREIGN KEY (ID_TYPE_OF_CHOCOLATE)
REFERENCES TASTE_CHOCOLATE(ID_TYPE_OF_CHOCOLATE);

CREATE TABLE PURCHASE_PRODUCT (
    ID_BUY INT,
    ID_PRODUCT INT,
    PRIMARY KEY (ID_BUY, ID_PRODUCT),
    FOREIGN KEY (ID_BUY) REFERENCES PURCHASE(ID_BUY) ON DELETE CASCADE,
    FOREIGN KEY (ID_PRODUCT) REFERENCES PRODUCT(ID_PRODUCT) ON DELETE CASCADE
);

CREATE TABLE Users (
    ID_User INT PRIMARY KEY,
    LOGIN VARCHAR2(255),
    PASSWORD VARCHAR2(255)
);

CREATE TABLE ORDERS (
    ID_PRODUCT INT,
    ID_User INT,
    QUANTITY INT,
    SUM INT,
    DATE_BUY DATE
);

CREATE TABLE Basket_Product (
    ID_Basket INT,
    ID_PRODUCT INT,
    CONSTRAINT FK_Basket_Product_Basket
        FOREIGN KEY (ID_Basket)
        REFERENCES Basket(ID_Basket),
    CONSTRAINT FK_Basket_Product_Product
        FOREIGN KEY (ID_PRODUCT)
        REFERENCES PRODUCT(ID_PRODUCT),
    CONSTRAINT PK_Basket_Product
        PRIMARY KEY (ID_Basket, ID_PRODUCT)
);

CREATE TABLE MARK (
    BRAND_CODE INT,
    BRAND_NAME VARCHAR2(255),
    PRIMARY KEY (BRAND_CODE)
);

CREATE TABLE PRODUCER (
    MANUFACTURERS_CODE INT,
    MANUFACTURERS_NAME VARCHAR2(255),
    PRIMARY KEY (MANUFACTURERS_CODE)
);

CREATE TABLE TASTE_CHOCOLATE (
    ID_TYPE_OF_CHOCOLATE INT,
    THE_NAME_THE_TASTE_OF_CHOCOLATE VARCHAR2(255),
    PRIMARY KEY (ID_TYPE_OF_CHOCOLATE)
);