FROM python:3.10-slim

WORKDIR /app

# copiar dependencias primero (mejor cache)
COPY requirements.txt requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# copiar el resto del proyecto
COPY . .

EXPOSE 5000

CMD ["python", "start.py"]