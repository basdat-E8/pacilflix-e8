from collections import namedtuple
import psycopg2
from psycopg2 import Error
from psycopg2.extras import RealDictCursor
import os
import environ

try:
    connection = psycopg2.connect(user=os.getenv("DB_USERNAME"),
                                password=os.getenv("DB_PASSWORD"),
                                host=os.getenv("DB_HOST"),
                                port=os.getenv("DB_PORT"),
                                database=os.getenv("DB_NAME"))

    # Create a cursor to perform database operations
    connection.autocommit = True
    cursor = connection.cursor()
except (Exception, Error) as error:
    print("Error while connecting to PostgreSQL: ", error)


def map_cursor(cursor):
    """Return all rows from a cursor as a namedtuple"""
    description = cursor.description
    named_tuple_result = namedtuple("Result", [col[0] for col in description])
    return [dict(row) for row in cursor.fetchall()]


def query(query_str: str, parameter: tuple = tuple()):
    result = []
    with connection.cursor(cursor_factory=RealDictCursor) as cursor:
        # cursor.execute("SET search_path TO pacilflix")
        cursor.execute("SET search_path TO PUBLIC")
        try:
            cursor.execute(query_str, parameter)
            # Handling SELECT queries
            if query_str.strip().upper().startswith("SELECT"):
                result = map_cursor(cursor)
            else:
                # Returns modified row count
                result = cursor.rowcount
                connection.commit()
        except Exception as e:
            result = e

    return result


def get_db_connection():
    db_name = os.environ.get("DB_NAME")
    db_user = os.environ.get("DB_USERNAME")
    db_password = os.environ.get("DB_PASSWORD")
    db_host = os.environ.get("DB_HOST")
    db_port = os.environ.get("DB_PORT")

    connection = psycopg2.connect(
        dbname=db_name,
        user=db_user,
        password=db_password,
        host=db_host,
        port=db_port
    )

    return connection
