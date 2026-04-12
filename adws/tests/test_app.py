"""Integration tests for the Task Manager API endpoints."""

import pytest
from fastapi.testclient import TestClient

from src.task_manager.app import app
from src.task_manager.database import reset as db_reset

client = TestClient(app)


@pytest.fixture(autouse=True)
def _clean_db():
    """Reset the database before every test."""
    db_reset()
    yield
    db_reset()


def test_create_task():
    """POST /tasks creates a task and returns 201."""
    response = client.post(
        "/tasks",
        json={"title": "Write tests", "priority": "high"},
    )
    assert response.status_code == 201
    data = response.json()
    assert data["title"] == "Write tests"
    assert data["priority"] == "high"
    assert data["completed"] is False
    assert "id" in data
    assert "created_at" in data


def test_list_tasks():
    """GET /tasks returns all tasks."""
    client.post("/tasks", json={"title": "Task A"})
    client.post("/tasks", json={"title": "Task B"})
    response = client.get("/tasks")
    assert response.status_code == 200
    assert len(response.json()) == 2


def test_get_task():
    """GET /tasks/{id} returns a specific task."""
    create_resp = client.post("/tasks", json={"title": "Find me"})
    task_id = create_resp.json()["id"]
    response = client.get(f"/tasks/{task_id}")
    assert response.status_code == 200
    assert response.json()["title"] == "Find me"


def test_get_task_not_found():
    """GET /tasks/{id} returns 404 for missing tasks."""
    response = client.get("/tasks/999")
    assert response.status_code == 404


def test_update_task():
    """PUT /tasks/{id} updates a task."""
    create_resp = client.post("/tasks", json={"title": "Original"})
    task_id = create_resp.json()["id"]
    response = client.put(
        f"/tasks/{task_id}",
        json={"title": "Updated", "completed": True},
    )
    assert response.status_code == 200
    assert response.json()["title"] == "Updated"
    assert response.json()["completed"] is True
    assert response.json()["updated_at"] != create_resp.json()["created_at"]


def test_delete_task():
    """DELETE /tasks/{id} removes a task and returns 204."""
    create_resp = client.post("/tasks", json={"title": "Delete me"})
    task_id = create_resp.json()["id"]
    response = client.delete(f"/tasks/{task_id}")
    assert response.status_code == 204
    # Verify it is gone
    response = client.get(f"/tasks/{task_id}")
    assert response.status_code == 404


def test_create_task_validation_error():
    """POST /tasks with empty title returns 422."""
    response = client.post("/tasks", json={"title": ""})
    assert response.status_code == 422
