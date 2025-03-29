# Use the official Python image  
FROM python:3.8-slim  

# Set working directory and copy app files    
COPY app/app.py .  

# Install Flask  
RUN pip install flask  

# Expose port 5000  
EXPOSE 5000  

# Run the Flask app  
CMD ["python", "app.py"]
