FROM python:3.10-alpine
ADD worker/app/requirements.txt /app/
WORKDIR /app
RUN pip install --no-cache-dir --upgrade -r requirements.txt
ADD worker/app/* /app/
CMD ["/usr/local/bin/python", "-u", "main.py"]
