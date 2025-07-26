from abc import ABC, abstractmethod
from typing import List

from ..aggregates.product import Product


class ProductRepository(ABC):
    """Port for retrieving products.

    The domain layer defines its own abstract contracts (ports).  Concrete
    implementations live in the infrastructure layer.  Keeping this interface
    in the domain prevents the domain from depending on any particular
    technology.
    """

    @abstractmethod
    async def list_products(self) -> List[Product]:
        """Return a list of all products."""
        raise NotImplementedError