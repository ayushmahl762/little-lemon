"""Connects to LittleLemonDB and exercises the booking stored procedures.

Install: pip install mysql-connector-python
Set DB_PASSWORD as an environment variable before running.
"""
import os
import mysql.connector


def connect():
    return mysql.connector.connect(
        host=os.getenv("DB_HOST", "localhost"),
        user=os.getenv("DB_USER", "root"),
        password="@ayush2447",
        database="LittleLemonDB",
    )


def call(cursor, name, args=()):
    cursor.callproc(name, args)
    for result in cursor.stored_results():
        for row in result.fetchall():
            print(f"{name}{args} -> {row}")


def main():
    conn = connect()
    cursor = conn.cursor()
    try:
        cursor.execute("SHOW TABLES")
        print("Tables:", [t[0] for t in cursor.fetchall()])

        call(cursor, "GetMaxQuantity")
        call(cursor, "ManageBooking", ("2026-10-10", 5))
        call(cursor, "AddBooking", (10, 1, "2026-10-20", 4))
        call(cursor, "AddBooking", (11, 2, "2026-10-20", 4))  # same table, rejected
        call(cursor, "UpdateBooking", (10, "2026-10-21"))
        call(cursor, "CancelBooking", (10,))
        conn.commit()
    finally:
        cursor.close()
        conn.close()


if __name__ == "__main__":
    main()
