-- Little Lemon booking system: schema, sample data, stored procedures
DROP SCHEMA IF EXISTS LittleLemonDB;
CREATE SCHEMA LittleLemonDB;
USE LittleLemonDB;

CREATE TABLE Customers (
    CustomerID    INT AUTO_INCREMENT PRIMARY KEY,
    FullName      VARCHAR(100) NOT NULL,
    ContactNumber VARCHAR(20),
    Email         VARCHAR(100)
);

CREATE TABLE Staff (
    StaffID       INT AUTO_INCREMENT PRIMARY KEY,
    FullName      VARCHAR(100) NOT NULL,
    Role          VARCHAR(50) NOT NULL,
    ContactNumber VARCHAR(20)
);

CREATE TABLE Bookings (
    BookingID    INT AUTO_INCREMENT PRIMARY KEY,
    BookingDate  DATE NOT NULL,
    TableNumber  INT NOT NULL,
    CustomerID   INT NOT NULL,
    StaffID      INT,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    FOREIGN KEY (StaffID)    REFERENCES Staff(StaffID)
);

CREATE TABLE Menus (
    MenuID  INT AUTO_INCREMENT PRIMARY KEY,
    Cuisine VARCHAR(50) NOT NULL
);

CREATE TABLE MenuItems (
    MenuItemID INT AUTO_INCREMENT PRIMARY KEY,
    ItemName   VARCHAR(100) NOT NULL,
    ItemType   VARCHAR(30) NOT NULL,  -- Starter, Main, Dessert, Drink
    Price      DECIMAL(8,2) NOT NULL
);

CREATE TABLE MenuContents (
    MenuID     INT NOT NULL,
    MenuItemID INT NOT NULL,
    PRIMARY KEY (MenuID, MenuItemID),
    FOREIGN KEY (MenuID)     REFERENCES Menus(MenuID),
    FOREIGN KEY (MenuItemID) REFERENCES MenuItems(MenuItemID)
);

CREATE TABLE Orders (
    OrderID    INT AUTO_INCREMENT PRIMARY KEY,
    BookingID  INT NOT NULL,
    MenuID     INT NOT NULL,
    Quantity   INT NOT NULL,
    TotalCost  DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (BookingID) REFERENCES Bookings(BookingID) ON DELETE CASCADE,
    FOREIGN KEY (MenuID)    REFERENCES Menus(MenuID)
);

CREATE TABLE OrderDeliveryStatus (
    OrderID      INT PRIMARY KEY,
    DeliveryDate DATE,
    Status       VARCHAR(30) NOT NULL,
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID) ON DELETE CASCADE
);

-- Sample data for testing
INSERT INTO Customers (FullName, ContactNumber, Email) VALUES
 ('Anna Iversen','555-0101','anna@example.com'),
 ('Joakim Iversen','555-0102','joakim@example.com'),
 ('Vanessa McCarthy','555-0103','vanessa@example.com'),
 ('Marcos Romero','555-0104','marcos@example.com');

INSERT INTO Staff (FullName, Role, ContactNumber) VALUES
 ('Mario Gollini','Manager','555-0201'),
 ('Adrian Gollini','Assistant Manager','555-0202'),
 ('Giorgos Dioudis','Head Chef','555-0203');

INSERT INTO Bookings (BookingDate, TableNumber, CustomerID, StaffID) VALUES
 ('2026-10-10',5,1,1),
 ('2026-10-12',3,2,1),
 ('2026-10-11',2,3,2),
 ('2026-10-13',2,4,2);

INSERT INTO Menus (Cuisine) VALUES ('Italian'),('Greek'),('Turkish');

INSERT INTO MenuItems (ItemName, ItemType, Price) VALUES
 ('Olives','Starter',5.00),('Flatbread','Starter',5.00),
 ('Minestrone','Starter',8.00),('Pizza','Main',12.00),
 ('Greek salad','Main',10.00),('Kabasa','Main',17.00),
 ('Ice cream','Dessert',6.00),('Baklava','Dessert',7.00);

INSERT INTO MenuContents VALUES
 (1,1),(1,3),(1,4),(1,7),(2,2),(2,5),(2,8),(3,2),(3,6),(3,8);

INSERT INTO Orders (BookingID, MenuID, Quantity, TotalCost) VALUES
 (1,1,2,86.00),(2,2,1,37.00),(3,2,1,37.00),(4,3,3,150.00);

INSERT INTO OrderDeliveryStatus VALUES
 (1,'2026-10-10','Delivered'),(2,'2026-10-12','Delivered'),
 (3,'2026-10-11','Delivered'),(4,NULL,'Pending');

-- Stored procedures
DELIMITER //

-- 1. Largest quantity in a single order
CREATE PROCEDURE GetMaxQuantity()
BEGIN
    SELECT MAX(Quantity) AS `Max Quantity in Order` FROM Orders;
END //

-- 2. Check whether a table is free on a date
CREATE PROCEDURE ManageBooking(IN in_date DATE, IN in_table INT)
BEGIN
    DECLARE booked INT DEFAULT 0;
    SELECT COUNT(*) INTO booked
    FROM Bookings
    WHERE BookingDate = in_date AND TableNumber = in_table;

    IF booked > 0 THEN
        SELECT CONCAT('Table ', in_table, ' is already booked on ', in_date) AS `Booking status`;
    ELSE
        SELECT CONCAT('Table ', in_table, ' is available on ', in_date) AS `Booking status`;
    END IF;
END //

-- 3. Move an existing booking to a new date
CREATE PROCEDURE UpdateBooking(IN in_booking_id INT, IN in_date DATE)
BEGIN
    UPDATE Bookings SET BookingDate = in_date WHERE BookingID = in_booking_id;
    SELECT CONCAT('Booking ', in_booking_id, ' updated') AS Confirmation;
END //

-- 4. Add a booking, refusing a double-booked table
CREATE PROCEDURE AddBooking(
    IN in_booking_id INT, IN in_customer_id INT,
    IN in_date DATE, IN in_table INT)
BEGIN
    DECLARE booked INT DEFAULT 0;
    START TRANSACTION;
    SELECT COUNT(*) INTO booked
    FROM Bookings
    WHERE BookingDate = in_date AND TableNumber = in_table;

    IF booked > 0 THEN
        ROLLBACK;
        SELECT CONCAT('Table ', in_table, ' is already booked - booking cancelled') AS `Booking status`;
    ELSE
        INSERT INTO Bookings (BookingID, BookingDate, TableNumber, CustomerID)
        VALUES (in_booking_id, in_date, in_table, in_customer_id);
        COMMIT;
        SELECT 'New booking added' AS `Booking status`;
    END IF;
END //

-- 5. Cancel a booking (its orders are removed by ON DELETE CASCADE)
CREATE PROCEDURE CancelBooking(IN in_booking_id INT)
BEGIN
    DELETE FROM Bookings WHERE BookingID = in_booking_id;
    SELECT CONCAT('Booking ', in_booking_id, ' cancelled') AS Confirmation;
END //

DELIMITER ;
