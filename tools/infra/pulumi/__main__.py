"""Pulumi entrypoint stub.

This module defines your infrastructure as code using Pulumi.  Replace the
contents with actual resource definitions.  See https://www.pulumi.com/docs/ for
details.
"""
import pulumi

def main():
    pulumi.export("message", pulumi.Output.secret("Pulumi infrastructure stub"))  # type: ignore

if __name__ == "__main__":
    main()
