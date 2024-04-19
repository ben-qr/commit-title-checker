Check commit titles in a PR against a regex match.

Inspiration taken from https://github.com/13rac1/block-fixup-merge-action.

To implement, create a workflow in your repo and add the following:

```yaml
name: Commit check
on: [pull_request]

jobs:
  commit-check:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v3
      - name: Check PR Commits
        uses: ben-qr/commit-title-checker@main
        with:
          regexPattern: '^feat:$'
```
