from dataclasses import dataclass


@dataclass
class Product:
    """Example domain entity for the ``core`` context.

    In a real application you would define your own entities and value objects
    here.  Entities encapsulate business state and behaviour.
    """

    id: int
    name: str
    price: float