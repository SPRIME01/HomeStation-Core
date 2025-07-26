"""
In‑memory implementation of the ``ProductRepository`` port.

This example repository returns a static list of products.  When you build
your real application you could implement this repository using a database
backend such as Postgres or call an external service.
"""

from typing import List

try:
    # Attempt to import the domain model.  The hyphenated package name is
    # invalid, so this import will fail at runtime unless you normalise the
    # import path or adjust PYTHONPATH.  It is kept here as a hint for when
    # you wire things up properly.
    from ....core-domain.src.aggregates.product import Product
    from ....core-domain.src.ports.product_repository import ProductRepository
except Exception:  # pragma: no cover
    Product = object  # type: ignore
    class ProductRepository:  # type: ignore
        async def list_products(self) -> List[object]: ...


class InMemoryProductRepository(ProductRepository):  # type: ignore[misc]
    """A simple in‑memory repository for demonstration purposes."""

    def __init__(self) -> None:
        # Prepopulate with example products
        self._products: List[Product] = []  # type: ignore

    async def list_products(self) -> List[Product]:  # type: ignore
        return list(self._products)