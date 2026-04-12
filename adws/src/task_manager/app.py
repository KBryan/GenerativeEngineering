"""FastAPI application for the Task Manager API."""

from fastapi import FastAPI, HTTPException
from fastapi.responses import JSONResponse

from .database import (
    create_task as db_create_task,
    delete_task as db_delete_task,
    get_task as db_get_task,
    list_tasks as db_list_tasks,
    reset as db_reset,
    update_task as db_update_task,
)
from .models import TaskCreate, TaskResponse, TaskUpdate

app = FastAPI(
    title="Task Manager API",
    description="A minimal REST API for managing tasks.",
    version="0.1.0",
)


# ── CRUD Endpoints ──


@app.post("/tasks", response_model=TaskResponse, status_code=201)
def api_create_task(task_create: TaskCreate):
    """Create a new task."""
    try:
        return db_create_task(task_create)
    except ValueError as exc:
        return JSONResponse(status_code=422, content={"detail": str(exc)})


@app.get("/tasks", response_model=list[TaskResponse])
def api_list_tasks():
    """List all tasks."""
    return db_list_tasks()


@app.get("/tasks/{task_id}", response_model=TaskResponse)
def api_get_task(task_id: str):
    """Get a specific task by ID."""
    task = db_get_task(task_id)
    if task is None:
        raise HTTPException(status_code=404, detail=f"Task {task_id} not found")
    return task


@app.put("/tasks/{task_id}", response_model=TaskResponse)
def api_update_task(task_id: str, task_update: TaskUpdate):
    """Update an existing task."""
    try:
        updated = db_update_task(task_id, task_update)
    except ValueError as exc:
        return JSONResponse(status_code=422, content={"detail": str(exc)})
    if updated is None:
        raise HTTPException(status_code=404, detail=f"Task {task_id} not found")
    return updated


@app.delete("/tasks/{task_id}", status_code=204)
def api_delete_task(task_id: str):
    """Delete a task by ID."""
    deleted = db_delete_task(task_id)
    if not deleted:
        raise HTTPException(status_code=404, detail=f"Task {task_id} not found")
    return None


# ── Test utilities ──


@app.post("/_test/reset", status_code=204)
def test_reset():
    """Reset the in-memory database. For testing only."""
    db_reset()
    return None
