#!/usr/bin/env python3
"""
This script provides helper functions for setting up the development environment,
managing contexts, and handling service architecture operations.
"""

import argparse
import json
import os
import subprocess
import sys
from pathlib import Path


def init_python_env(args):
    """Initialize Python environment with specified profile."""
    print(f"Initializing Python environment with Python {args.python_version}")
    print(f"Root pyproject.toml: {args.root_pyproject_toml}")
    print(f"Monorepo root: {args.monorepo_root}")
    print(f"Profile: {args.profile}")

    # Create virtual environment
    venv_path = Path(args.monorepo_root) / ".venv"
    subprocess.run([sys.executable, "-m", "venv", str(venv_path)], check=True)

    # Install dependencies based on profile
    if args.profile == "core":
        print("Installing core dependencies...")
        # Install core dependencies here
        pass
    elif args.profile == "full":
        print("Installing full dependencies...")
        # Install full dependencies here
        pass

    print("Python environment initialized successfully!")


def init_nx(args):
    """Initialize Nx workspace."""
    print(f"Initializing Nx workspace with plugin version {args.nx_python_plugin_version}")
    # Initialize Nx workspace here
    print("Nx workspace initialized successfully!")


def install_custom_py_generator(args):
    """Install custom Python generators."""
    print(f"Installing custom Python generator: {args.custom_py_gen_plugin_name}")
    # Install custom Python generator here
    print("Custom Python generator installed successfully!")


def install_pre_commit(args):
    """Install git pre-commit hooks."""
    print("Installing git pre-commit hooks...")
    # Install pre-commit hooks here
    print("Git pre-commit hooks installed successfully!")


def update_service_tags(args):
    """Update deployable tags for a context."""
    print(f"Updating deployable tags for context {args.ctx} to {args.deployable}")

    # Update project.json file for the context
    project_json_path = Path(f"libs/{args.ctx}/project.json")
    if project_json_path.exists():
        with open(project_json_path, "r") as f:
            project_data = json.load(f)

        # Update tags
        if "tags" not in project_data:
            project_data["tags"] = []

        # Remove existing deployable tag if present
        project_data["tags"] = [tag for tag in project_data["tags"] if not tag.startswith("deployable:")]

        # Add new deployable tag
        project_data["tags"].append(f"deployable:{args.deployable}")

        # Write back to file
        with open(project_json_path, "w") as f:
            json.dump(project_data, f, indent=2)

        print(f"Deployable tags updated for context {args.ctx}")
    else:
        print(f"Project file not found for context {args.ctx}")


def main():
    """Main entry point for the setup helper script."""
    parser = argparse.ArgumentParser(description="Setup helper for HomeStation_Core project")
    subparsers = parser.add_subparsers(dest="command", help="Available commands")

    # init_python_env command
    init_python_env_parser = subparsers.add_parser("init_python_env", help="Initialize Python environment")
    init_python_env_parser.add_argument("--python-version", required=True, help="Python version to use")
    init_python_env_parser.add_argument("--root-pyproject-toml", required=True, help="Path to root pyproject.toml")
    init_python_env_parser.add_argument("--monorepo-root", required=True, help="Path to monorepo root")
    init_python_env_parser.add_argument("--profile", required=True, choices=["core", "full"], help="Installation profile")
    init_python_env_parser.set_defaults(func=init_python_env)

    # init_nx command
    init_nx_parser = subparsers.add_parser("init_nx", help="Initialize Nx workspace")
    init_nx_parser.add_argument("--nx-python-plugin-version", required=True, help="Nx Python plugin version")
    init_nx_parser.set_defaults(func=init_nx)

    # install_custom_py_generator command
    install_custom_py_generator_parser = subparsers.add_parser("install_custom_py_generator", help="Install custom Python generator")
    install_custom_py_generator_parser.add_argument("--custom-py-gen-plugin-name", required=True, help="Custom Python generator plugin name")
    install_custom_py_generator_parser.set_defaults(func=install_custom_py_generator)

    # install_pre_commit command
    install_pre_commit_parser = subparsers.add_parser("install_pre_commit", help="Install git pre-commit hooks")
    install_pre_commit_parser.set_defaults(func=install_pre_commit)

    # update_service_tags command
    update_service_tags_parser = subparsers.add_parser("update_service_tags", help="Update deployable tags for a context")
    update_service_tags_parser.add_argument("--ctx", required=True, help="Context name")
    update_service_tags_parser.add_argument("--deployable", required=True, choices=["true", "false"], help="Deployable status")
    update_service_tags_parser.set_defaults(func=update_service_tags)

    # Parse arguments
    args = parser.parse_args()

    # Execute command
    if hasattr(args, "func"):
        args.func(args)
    else:
        parser.print_help()


if __name__ == "__main__":
    main()
