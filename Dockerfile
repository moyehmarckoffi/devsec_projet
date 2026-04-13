# Image officielle Python légère
FROM python:3.10-slim

# Correction du format ENV (key=value)
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app

# Correction de la ligne RUN (bien vérifier que 'apt-get clean' est complet)
RUN apt-get update && \
    apt-get install -y --no-install-recommends gcc libmariadb-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Installation des dépendances Python
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copie du code
COPY . .

# Port exposé
EXPOSE 5000

# Lancement
CMD ["python", "app.py"]
