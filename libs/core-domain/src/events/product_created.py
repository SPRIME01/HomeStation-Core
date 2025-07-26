from dataclasses import dataclass

from ..aggregates.product import Product


@dataclass
class ProductCreated:
    """Domain event signalling that a new product has been created."""

    product: Product