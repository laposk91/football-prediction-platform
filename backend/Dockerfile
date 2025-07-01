
FROM python:3.10-slim

WORKDIR /app

RUN pip install poetry

COPY poetry.lock pyproject.toml /app/

RUN poetry config virtualenvs.create false && poetry install --no-root --without dev

COPY . /app/


CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000", "--reload"]
