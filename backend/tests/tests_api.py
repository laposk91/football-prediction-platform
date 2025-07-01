from fastapi.testclient import TestClient
from main import app

client = TestClient(app)

def test_read_root():
    response = client.get("/")
    assert response.status_code == 200
    assert response.json() == {"message": "Football Prediction API - V1"}

def test_system_health():
    """
    Note: This test runs outside the full docker-compose stack,
    so we expect redis to be 'disconnected'. The pipeline test
    will run against the live services.
    """
    response = client.get("/api/admin/system-health")
    assert response.status_code == 200
    json_response = response.json()
    assert json_response["api_status"] == "ok"
    assert "cache_status" in json_response
