"""Unit tests for Pydantic models."""

from datetime import datetime, timezone

from src.task_manager.models import TaskCreate, TaskResponse, TaskUpdate


def test_task_create_defaults():
    """TaskCreate sets default priority to medium and description to None."""
    task = TaskCreate(title="Test task")
    assert task.title == "Test task"
    assert task.description is None
    assert task.priority == "medium"


def test_task_create_with_all_fields():
    """TaskCreate accepts all fields."""
    task = TaskCreate(
        title="Full task",
        description="A detailed description",
        priority="high",
    )
    assert task.title == "Full task"
    assert task.description == "A detailed description"
    assert task.priority == "high"


def test_task_update_partial():
    """TaskUpdate allows partial updates — all fields optional."""
    update = TaskUpdate(title="New title")
    data = update.model_dump(exclude_unset=True)
    assert data == {"title": "New title"}
    assert "description" not in data
    assert "priority" not in data
    assert "completed" not in data


def test_task_update_empty():
    """TaskUpdate with no fields set produces empty exclude_unset dict."""
    update = TaskUpdate()
    data = update.model_dump(exclude_unset=True)
    assert data == {}


def test_task_response_serialization():
    """TaskResponse serializes to JSON-compatible dict."""
    now = datetime.now(timezone.utc)
    task = TaskResponse(
        id="1",
        title="Serialize me",
        description="Testing serialization",
        priority="low",
        completed=False,
        created_at=now,
        updated_at=now,
    )
    data = task.model_dump()
    assert data["id"] == "1"
    assert data["title"] == "Serialize me"
    assert data["priority"] == "low"
    assert isinstance(data["created_at"], datetime)


def test_task_response_optional_fields():
    """TaskResponse fills defaults for optional fields."""
    now = datetime.now(timezone.utc)
    task = TaskResponse(
        id="2",
        title="Minimal",
        created_at=now,
        updated_at=now,
    )
    assert task.description is None
    assert task.priority == "medium"
    assert task.completed is False
