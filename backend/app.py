from fastapi import FastAPI
import os
from contextlib import asynccontextmanager
import logging
import redis.asyncio as redis

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# This is a dictionary that will hold our "connections"
# In a real app, this would be more robust (e.g., connection pools)
lifespan_data = {}

@asynccontextmanager
async def lifespan(app: FastAPI):
    # On startup
    logger.info("Application starting up...")
    redis_url = os.getenv("REDIS_URL", "redis://localhost:6379")
    try:
        lifespan_data["redis_pool"] = redis.from_url(redis_url, encoding="utf8", decode_responses=True)
        # Ping Redis to check the connection
        await lifespan_data["redis_pool"].ping()
        logger.info("Successfully connected to Redis.")
    except Exception as e:
        logger.error(f"Could not connect to Redis: {e}")
        lifespan_data["redis_pool"] = None

    yield # The application runs here

    # On shutdown
    logger.info("Application shutting down...")
    if lifespan_data["redis_pool"]:
        await lifespan_data["redis_pool"].close()
        logger.info("Redis connection closed.")


app = FastAPI(lifespan=lifespan)

@app.get("/")
def read_root():
    return {"message": "Football Prediction API - V1"}

@app.get("/api/admin/system-health")
async def system_health():
    # Check Redis connection
    redis_status = "disconnected"
    if lifespan_data.get("redis_pool"):
        try:
            await lifespan_data["redis_pool"].ping()
            redis_status = "connected"
        except Exception:
            redis_status = "connection_error"

    # In the future, we will also check the database connection here
    db_status = "not_implemented"

    return {
        "api_status": "ok",
        "database_status": db_status,
        "cache_status": redis_status,
    }