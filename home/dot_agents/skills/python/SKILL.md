---
name: python
description: >
  Use whenever working with Python files.
---

# Python

- Do not use system Python. Use `uv run` to execute code — it manages
  virtual environments automatically. For standalone scripts, declare
  dependencies inline with PEP 723 metadata:

  ```python
  # /// script
  # requires-python = ">=3.12"
  # dependencies = ["aiohttp", "yarl"]
  # ///
  ```

  For one-off runs without modifying the file, use `uv run --with <pkg> script.py`
- Use `aiohttp` library to make HTTP calls
- Make calls to APIs concurrently whenever possible to save time
- Always deserialize API responses into typed objects (e.g., `@dataclass(frozen=True)` or Pydantic models)
- Use `yarl` library to manipulate URLs
- Always write type hints
- When using try..except, avoid having bare Exception
- Prefer EAPF instead of LBYL
- Prefer raise instead of sys.exit
