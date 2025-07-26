"""
Tests for the ``GetProductsService`` placeholder.
"""

import pytest

from ..src.services.get_products_service import GetProductsService


class DummyRepository:
    async def list_products(self) -> list[dict]:
        return [
            {"id": 1, "name": "Example", "price": 0.0},
            {"id": 2, "name": "Another", "price": 1.0},
        ]


@pytest.mark.asyncio
async def test_service_returns_repository_values() -> None:
    repo = DummyRepository()
    service = GetProductsService(repo)
    products = await service.execute()
    # In the placeholder implementation this will return an empty list
    # because GetProductsService.execute returns [] by default.  Adjust
    # this assertion when you implement the service properly.
    assert products == []