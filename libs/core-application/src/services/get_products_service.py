"""
Example use case for the ``core`` context.

This module defines a ``GetProductsService`` which demonstrates how you
might structure an application service in the hexagonal architecture.  The
actual domain types and repository are not imported here because the
project uses hyphenated package names which are not valid Python module
identifiers.  When you generate real contexts with the Nx plugin the
generator will normalise names for you.

Replace the body of this service with your real business logic.  You can
import the domain entities and ports using dynamic import or by adjusting
the PYTHONPATH to include your ``libs`` directory.
"""

from __future__ import annotations
from typing import List, Any


class GetProductsService:
    """Use case for retrieving all products.

    The service would normally accept a domain port implementation in its
    initializer.  In this placeholder implementation the dependencies are
    ignored.
    """

    def __init__(self, product_repository: Any) -> None:
        self._product_repository = product_repository

    async def execute(self) -> List[Any]:
        """Return all products from the repository.

        This dummy implementation returns an empty list.  Replace with a
        call to your repository once you've normalised import paths.
        """
        return []