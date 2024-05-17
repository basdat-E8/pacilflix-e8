# Use the official Python image as the base image
FROM python:3.9-slim

# Menggunakan variabel lingkungan sebagai build argument
ARG DATABASE_NAME
ARG DATABASE_USER
ARG DATABASE_PASSWORD
ARG DATABASE_HOST
ARG DATABASE_PORT

# Set nilai variabel lingkungan dalam lingkungan Docker
ENV DATABASE_NAME=$DATABASE_NAME
ENV DATABASE_USER=$DATABASE_USER
ENV DATABASE_PASSWORD=$DATABASE_PASSWORD
ENV DATABASE_HOST=$DATABASE_HOST
ENV DATABASE_PORT=$DATABASE_PORT

# Set the working directory in the container
WORKDIR /docker-app

# Copy the requirements file into the container at /docker-app
COPY requirements.txt /docker-app/

# Install any dependencies specified in requirements.txt
RUN pip install --upgrade pip && pip install -r requirements.txt

# Copy the current directory contents into the container at /docker-app
COPY . /docker-app/

# Expose port 8000 to the outside world
EXPOSE 8000

# Run migrate DB
RUN python manage.py migrate

# Jalankan Gunicorn
CMD ["gunicorn", "app.nani.wsgi", "--bind", "0.0.0.0:8000"]