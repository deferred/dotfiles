---
name: python-guide
description: >
  Use this skill whenever working with Python files.
---

# Python Guide

- Do not use system Python for running custom code, use `uv` to create virtual environment and use it instead
- Use `aiohttp` library to make HTTP calls
- Make calls to APIs concurrently whenever possible to save time
- Always deserialize responses of API calls to `@dataclass(frozen=True)`
- Use `yarl` library to manipulate URLs
- Always write type hints

## Testing
- Use `pytest` library instead of `unittest` from standard library
- Do Arrange and Cleanup in `@pytest.fixture`, not in the test itself
