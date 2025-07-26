"""
Application layer for the ``core`` context.

The application layer orchestrates domain logic by implementing use cases and
services.  It depends on the domain’s abstract ports and orchestrates
infrastructure via dependency injection.  No database or framework code
should live here.
"""