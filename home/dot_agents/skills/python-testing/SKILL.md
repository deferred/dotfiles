---
name: python-testing
description: >
  Use whenever working with Python test files, or when asked about pytest.
---

# Python Testing

Before writing tests, read `references/anatomy-of-test.rst` and `references/fixtures.rst`.
Apply the patterns described in those documents when writing tests.

- Use `pytest` library instead of `unittest` from standard library
- Use small, focused test functions instead of classes
- Keep each test radically small, ideally with a single `assert`
- Write multiple, focused tests to cover different scenarios and edge cases
- Do not change existing tests to catch regressions unless absolutely necessary
  because the function under test changed
- Do not use comments like `# Arrange`, `# Act`, `# Assert`
