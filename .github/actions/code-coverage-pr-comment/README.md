# code-coverage-pr-comment

- Allows the user to post a comment with the current code coverage on their PR.
- Inputs:
  - coverage-report-path - Path to the code coverage report file.

## Usage

To use this action, you first have to run your tests and make sure that they output a `coverage-summary.json` file.

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
```
