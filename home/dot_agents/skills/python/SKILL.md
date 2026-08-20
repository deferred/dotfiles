---
name: python
description: >
  Use this skill whenever working with Python files.
---

# Python

- Do not use system Python for running custom code, use `uv` to create virtual environment and use it instead
- Use `aiohttp` library to make HTTP calls
- Make calls to APIs concurrently whenever possible to save time
- Always deserialize responses of API calls to `@dataclass(frozen=True)`
- Use `yarl` library to manipulate URLs
- Always write type hints
- When usng try..except, avoid having bare Exception
- Prefer EAPF instead of LBYL
- Prefer raise instead of sys.exit

## Testing

- Use `pytest` library instead of `unittest` from standard library
- Do Arrange and Cleanup in `@pytest.fixture`, not in the test itself
- Use small, focused test functions instead of classes
- Write multiple, focused tests to cover different scenarios and edge cases, but implement them one at a time following the TDD cycle
- Do not change existing tests to catch regressions unless absolutely necessary because the function under test changed
- Do not use comments like `# Arrange`, `# Act`, `# Assert`
- To implement new functionality, follow the TDD loop:
  1. Write a new test case that replicates the problem or desired functionality. If the function under test doesn't exist, create a placeholder that does nothing (e.g., with a `pass` statement)
  2. Run tests to ensure that the new test fails as expected (usually with an `AssertionError`)
  3. Implement the simplest possible code to make the test pass
  4. Run tests again to confirm that all tests now pass
  5. Refactor the code for clarity and efficiency, ensuring that all tests continue to pass
