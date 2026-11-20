# cache-docker-image

- Allows the user to cache a docker image.
- Inputs:
  - cache-key - Key to use when checking cache or saving the image.
  - full-image-name - The full name of the docker image you wish to use. Ex: `mysql:8.0`

## Usage

```yaml
name: example-workflow-name

on: workflow_dispatch

jobs:
    example-job:
    runs-on: ubuntu-latest
    steps:
        - name: Restore MySQL Image
          uses:  fushinoryuu/gha-workflows/.github/actions/cache-docker-image@main
          with:
            cache-key: mysql8
            full-image-name: mysql:8.0
```
