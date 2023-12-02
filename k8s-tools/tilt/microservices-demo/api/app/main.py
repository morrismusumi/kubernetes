from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import psycopg2
from config import DB_HOST, DB_PORT, DB_USER, DB_PASS

app = FastAPI()

class Order(BaseModel):
    order_no: str

# Function to establish a connection to PostgreSQL
def connect_to_postgres():
    # Connection parameters - update these with your details
    conn_params = {
        'dbname': 'postgres',
        'user': DB_USER,
        'password': DB_PASS,
        'host': DB_HOST,
        'port': DB_PORT
    }
    # Establishing the connection
    conn = psycopg2.connect(**conn_params)
    
    # Creating a cursor object using the connection
    cursor = conn.cursor()
    
    # SQL statement for creating the database and table if not exists
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS orders (
            id SERIAL PRIMARY KEY,
            order_no TEXT NOT NULL
        );
    """)
    
    # Committing the SQL command
    conn.commit()
    
    return conn, cursor

def save_order_to_db(order_no):
    try:
        conn, cursor = connect_to_postgres()
        insert_sql = "INSERT INTO orders (order_no) VALUES (%s);"
        cursor.execute(insert_sql, (order_no,))
        conn.commit()
        cursor.close()
        conn.close()
        
        print(f"INFO:     Order: {order_no} saved successfully!")
        
    except (Exception, psycopg2.DatabaseError) as error:
        print(f"Error: {error}")
    finally:
        if conn is not None:
            conn.close()

# Define your POST endpoint to receive plain text
@app.get("/")
async def home():
    return "Welcome to the microserivces-demo API!!"

# Define your POST endpoint to receive plain text
@app.post("/orders")
async def receive_text(order: Order):
    save_order_to_db(order.order_no)
    return {"status": "success", "message": f"Order: {order.order_no} created!"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)