import urllib.request
import urllib.parse
import json
import time
import random
from config import API_BASE_URL

def post_order(order_no):
    url = f"{API_BASE_URL}/orders"
    headers = {
        'Content-Type': 'application/json',
    }
    data = json.dumps({"order_no": order_no}).encode('utf-8')
    req = urllib.request.Request(url, data=data, headers=headers, method='POST')
    
    with urllib.request.urlopen(req) as response:
        response_body = response.read()
        print(f"Order {order_no} posted successfully: {response_body}")

def schedule_random_post_order():
    while True:
        # Generate a random order number
        order_no = str(random.randint(10000000, 99999999))
        try:
            post_order(order_no)
        except urllib.error.HTTPError as e:
            print(f"HTTPError for order {order_no}: {e.code} - {e.reason}")
        except urllib.error.URLError as e:
            print(f"URLError for order {order_no}: {e.reason}")
        time.sleep(5)

if __name__ == "__main__":
    print("Starting worker...")
    schedule_random_post_order()





