
FROM python:3.12-slim-trixie

WORKDIR /app

RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN useradd --create-home --uid 10001 appuser \
    && chown -R appuser:appuser /app

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY app ./app

USER 10001

EXPOSE 8080

CMD ["python", "app/app.py"]