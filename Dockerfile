# Use the official Python image as the base image
FROM python:3.9-slim

# Menggunakan variabel lingkungan sebagai build argument
ARG DB_NAME
ARG DB_USER
ARG DB_PASSWORD
ARG DB_HOST
ARG DB_PORT

# Set nilai variabel lingkungan dalam lingkungan Docker
ENV DB_NAME=$DB_NAME
ENV DB_USER=$DB_USER
ENV DB_PASSWORD=$DB_PASSWORD
ENV DB_HOST=$DB_HOST
ENV DB_PORT=$DB_PORT

# Set the working directory in the container
WORKDIR /docker-app

# Copy the requirements file and install dependencies
COPY requirements.txt .
RUN pip install --upgrade pip && pip install -r requirements.txt

# Copy the rest of the application code
COPY . .

# Expose port 8000 to the outside world
EXPOSE 8000

# Run database migrations and start the application with Gunicorn
CMD ["sh", "-c", "python manage.py migrate && gunicorn app.nani.wsgi --bind 0.0.0.0:8000"]