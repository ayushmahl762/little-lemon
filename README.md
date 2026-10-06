# Little Lemon Booking System

Capstone project: MySQL database, Python client, stored procedures and Tableau analysis.

## Structure
- `sql/little_lemon_schema.sql` - schema, sample data and the five stored procedures
- `python/little_lemon_client.py` - connects with mysql-connector and calls the procedures
- `model/` - the Workbench `.mwb` model
- `tableau/` - the Tableau workbook with all worksheets and dashboards
- `screenshots/` - PNG screenshots (ER diagram, procedure output, charts)

## Data model
Customers place Bookings, and Staff handle them. Each Booking can have Orders. An Order refers to a Menu, and Menus contain MenuItems through MenuContents. OrderDeliveryStatus tracks delivery for each Order. Deleting a Booking cascades to its Orders, which keeps CancelBooking() simple.

## Stored procedures
| Procedure | Purpose |
|---|---|
| GetMaxQuantity() | Returns the largest quantity in any order |
| ManageBooking(date, table) | Reports whether a table is free on a date |
| UpdateBooking(booking_id, date) | Changes a booking's date |
| AddBooking(id, customer_id, date, table) | Inserts a booking, and rolls back if the table is taken |
| CancelBooking(booking_id) | Deletes a booking |

## Run
1. Execute the SQL file in MySQL Workbench.
2. `export DB_PASSWORD=...` then `python python/little_lemon_client.py`.
