"""In-memory database for the Task Manager API.

Uses a plain Python dictionary for simplicity.
All data is lost when the process restarts.
"""

from datetime import datetime, timezone
from typing import Optional

from .models import TaskCreate, TaskResponse, TaskUpdate

# In-memory store: {task_id: TaskResponse}
_tasks: dict[str, TaskResponse] = {}

# Auto-incrementing ID counter
_next_id: int = 1

VALID_PRIORITIES = {"low", "medium", "high"}


def reset() -> None:
    """Clear the database. Useful for testing."""
    global _tasks, _next_id
    _tasks = {}
    _next_id = 1


def list_tasks() -> list[TaskResponse]:
    """Return all tasks."""
    return list(_tasks.values())


def get_task(task_id: str) -> Optional[TaskResponse]:
    """Return a task by ID, or None if not found."""
    return _tasks.get(task_id)


def create_task(task_create: TaskCreate) -> TaskResponse:
    """Create a new task and return it."""
    global _next_id

    if task_create.priority not in VALID_PRIORITIES:
        raise ValueError(
            f"Invalid priority: {task_create.priority!r}. "
            f"Must be one of {VALID_PRIORITIES}."
        )

    now = datetime.now(timezone.utc)
    task = TaskResponse(
        id=str(_next_id),
        title=task_create.title,
        description=task_create.description,
        priority=task_create.priority,
        completed=False,
        created_at=now,
        updated_at=now,
    )
    _tasks[task.id] = task
    _next_id += 1
    return task


def update_task(task_id: str, task_update: TaskUpdate) -> Optional[TaskResponse]:
    """Update a task by ID. Returns the updated task, or None if not found."""
    task = _tasks.get(task_id)
    if task is None:
        return None

    update_data = task_update.model_dump(exclude_unset=True)

    if "priority" in update_data and update_data["priority"] not in VALID_PRIORITIES:
        raise ValueError(
            f"Invalid priority: {update_data['priority']!r}. "
            f"Must be one of {VALID_PRIORITIES}."
        )

    now = datetime.now(timezone.utc)
    updated_task = task.model_copy(update={**update_data, "updated_at": now})
    _tasks[task_id] = updated_task
    return updated_task


def delete_task(task_id: str) -> bool:
    """Delete a task by ID. Returns True if deleted, False if not found."""
    if task_id in _tasks:
        del _tasks[task_id]
        return True
    return False
