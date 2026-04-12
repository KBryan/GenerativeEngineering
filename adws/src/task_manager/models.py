"""Pydantic models for the Task Manager API."""

from datetime import datetime
from typing import Optional

from pydantic import BaseModel, Field


class TaskCreate(BaseModel):
    """Schema for creating a new task."""

    title: str = Field(..., min_length=1, max_length=200, description="Task title")
    description: Optional[str] = Field(
        default=None, max_length=2000, description="Optional task description"
    )
    priority: str = Field(
        default="medium",
        description="Task priority: low, medium, or high",
    )


class TaskUpdate(BaseModel):
    """Schema for partially updating an existing task."""

    title: Optional[str] = Field(default=None, min_length=1, max_length=200)
    description: Optional[str] = Field(default=None, max_length=2000)
    priority: Optional[str] = Field(default=None)
    completed: Optional[bool] = Field(default=None)


class TaskResponse(BaseModel):
    """Schema for returning a task in API responses."""

    id: str
    title: str
    description: Optional[str] = None
    priority: str = "medium"
    completed: bool = False
    created_at: datetime
    updated_at: datetime
