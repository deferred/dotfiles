---
name: tdd
description: >
  Use when the user asks to implement functionality using TDD, or says "test first",
  "red green refactor", or "write the test first".
---

# TDD (Test-Driven Development)

## The Red-Green-Refactor cycle

Repeat the cycle below for each small piece of behavior.
Never skip ahead; complete one cycle before starting the next.

### 1. Red — write one failing test

- Write a single test that describes the next behavior you need.
- If the function under test does not exist yet,
  create a minimal stub that does nothing (e.g., `pass` in Python, empty body in Go).
- Run the test suite. Confirm the new test **fails** with the expected error
  (e.g., `AssertionError`, not a syntax or import error).
- If the test passes immediately, it tests nothing new. Rethink it.

### 2. Green — make it pass with minimal code

- Write the **simplest** code that makes the failing test pass.
- Do not add logic for future tests. Solve only the current failure.
- Run the full test suite. All tests (old and new) must pass.
- If an old test breaks, fix the production code, not the old test.

### 3. Refactor — clean up while green

- Improve names, remove duplication, simplify structure.
- Change both production code and test code.
- Run the full test suite after every change. Stay green.
- Stop refactoring when the code is clear and all tests pass.

## Choosing the next test

- Start with the simplest case (e.g., empty input, zero, nil).
- Progress to typical cases, then edge cases and error paths.
- Each test should drive one new piece of production logic.
- If the next test requires a large code change, pick a smaller test first.

## Key principles

- One test at a time. Do not batch multiple tests before making them pass.
- Keep tests small. Prefer a single assertion per test.
  Multiple asserts are fine only when they verify the same logical behavior.
- Test behavior, not implementation.
  Avoid asserting on internal state, private methods, or call counts.
- Do not modify existing passing tests unless the public contract changed.

## Common mistakes to avoid

- Writing production code before a failing test exists.
- Writing a test that cannot fail (e.g., testing a stub you just wrote).
- Making the test pass by hardcoding the expected value.
  Generalize the code so unwritten tests would also pass.
- Skipping the refactor step. Messy code accumulates fast without it.
- Over-mocking. Mock only external boundaries (network, disk, clock).
  Keep tests realistic by using real objects when possible.
