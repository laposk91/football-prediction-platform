FROM python:3.10-slim

# Set the working directory inside the container
WORKDIR /app

# Install poetry for dependency management
RUN pip install poetry

# Copy only the dependency files to leverage Docker layer caching
COPY poetry.lock pyproject.toml /app/

# Install project dependencies
RUN poetry config virtualenvs.create false && poetry install --no-root  --without dev

# Copy the rest of the application source code
COPY . /app/

# Command to run the application
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000", "--reload"]
