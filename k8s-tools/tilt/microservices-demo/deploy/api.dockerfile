FROM python:3.10
ADD api/app/requirements.txt /app/
WORKDIR /app
RUN pip install --no-cache-dir --upgrade -r requirements.txt
ADD api/app/* /app/
CMD ["/usr/local/bin/python", "-u", "main.py"]
