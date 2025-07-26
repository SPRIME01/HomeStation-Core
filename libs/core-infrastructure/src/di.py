"""
Dependency injection registration for the ``core`` context.

In a full implementation you would register your port implementations here
and expose provider functions for FastAPI's ``Depends``.  The example
below provides a simple provider that instantiates the in‑memory repository
each time it is called.
"""

from .adapters.in_memory_product_repository import InMemoryProductRepository


def get_product_repository() -> InMemoryProductRepository:
    """Return a new instance of ``InMemoryProductRepository``.

    FastAPI will call this function each time it needs a ``ProductRepository``.
    In a real application you could manage a singleton or attach a database
    session here.
    """
    return InMemoryProductRepository()