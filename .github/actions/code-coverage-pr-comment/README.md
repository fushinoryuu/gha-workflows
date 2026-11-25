# code-coverage-pr-comment

- Allows the user to post a comment with the current code coverage on their PR.
- Inputs:
  - coverage-report-path - Path to the code coverage report file.
  - test-framework - The test framework used in the calling repo. Valid values are vitest, pytest, and jest.

## Usage

To use this action, you first have to run your tests and make sure that they output a `coverage-summary.json` file.

Vitest/Jest example:

```yaml
name: example-workflow-name

on: workflow_dispatch

jobs:
  example-job:
    runs-on: ubuntu-latest
    steps:
      - run: npm test -- --coverage

      - name: Comment on the PR with the coverage report
        uses: fushinoryuu/gha-workflows/.github/actions/code-coverage-pr-comment@main
        with:
          coverage-report-path: ./coverage/coverage-summary.json
          test-framework: vitest
```

Pytest example:

```yaml
name: example-workflow-name

on: workflow_dispatch

jobs:
  example-job:
    runs-on: ubuntu-latest
    steps:
      - run: pytest --cov=src --cov-branch --cov-report=json:coverage.json

      - name: Comment on the PR with the coverage report
        uses: fushinoryuu/gha-workflows/.github/actions/code-coverage-pr-comment@main
        with:
          coverage-report-path: ./coverage.json
          test-framework: pytest
```

For pytest, the report must be the JSON report from `coverage.py` (`--cov-report=json`), not a `coverage-summary.json`. The `--cov-branch` flag is needed for the branches row; without it that row shows `n/a`. The functions row needs `coverage.py` 7.6 or newer; with an older version it shows `n/a`.
