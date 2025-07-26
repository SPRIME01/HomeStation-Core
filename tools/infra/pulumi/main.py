"""Compatibility stub for Pulumi.

Pulumi automatically looks for __main__.py.  This file simply imports the
__main__ module so that you can run `pulumi up` without specifying python
package names.
"""
from . import __main__
