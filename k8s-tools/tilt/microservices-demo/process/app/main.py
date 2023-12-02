import psycopg2
import time
from config import DB_HOST, DB_PORT, DB_USER, DB_PASS

# Database connection parameters
db_params = {
    'dbname': 'postgres',
    'user': DB_USER,
    'password': DB_PASS,
    'host': DB_HOST,
    'port': DB_PORT
}

def connect_to_postgres(params):
    # Try to establish a connection to the database
    try:
        conn = psycopg2.connect(**params)
        return conn
    except psycopg2.Error as e:
        print(f"Error connecting to PostgreSQL database: {e}")
        return None

def fetch_orders(conn):
    # Create a cursor object
    with conn.cursor() as cursor:
        # Execute the SQL command
        cursor.execute("SELECT * FROM orders ORDER BY id DESC LIMIT 3;")
        
        # Fetch all the records
        records = cursor.fetchall()
        print(records[-3:])


def main(db_params):
    # Connect to the PostgreSQL database
    conn = connect_to_postgres(db_params)
    
    if conn is not None:
        print("Connected to DB!")
        try:
            while True:
                print("Fetching last 3 orders from the database...")
                fetch_orders(conn)
                # Wait for 5 seconds before fetching the next set of records
                time.sleep(5)
        except KeyboardInterrupt:
            print("Program terminated by user.")
        finally:
            # Close the database connection
            conn.close()


if __name__ == "__main__":
    main(db_params)



