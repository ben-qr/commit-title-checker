#!/bin/bash
set -eo pipefail

PR_REF="${GITHUB_REF%/merge}/head"
BASE_REF="${GITHUB_BASE_REF}"
regexPattern="${1}"
echo "regexPattern: ${regexPattern}"
echo "Current ref: ${PR_REF}"
echo "Base ref: ${BASE_REF}"
echo "PR_REF: ${PR_REF}"

if [[ "$PR_REF" != "refs/pull/"* ]]; then
  echo "This check works only with pull_request events"
  exit 1
fi

# Using git directly because the $GITHUB_EVENT_PATH file only shows commits in
# most recent push.
/usr/bin/git -c protocol.version=2 fetch --no-tags --prune --progress --no-recurse-submodules --depth=1 origin "${BASE_REF}:__ci_base"
/usr/bin/git -c protocol.version=2 fetch --no-tags --prune --progress --no-recurse-submodules --shallow-exclude="${BASE_REF}" origin "${PR_REF}:__ci_pr"
# Get the list before the "|| true" to fail the script when the git cmd fails.
COMMIT_LIST=`/usr/bin/git log --pretty=format:%s __ci_base..__ci_pr`
echo "Commit list: $COMMIT_LIST"

COMMIT_COUNT=`echo "$COMMIT_LIST" | wc -l || true`
FIXUP_COUNT=`echo "$COMMIT_LIST" | grep -E "$regexPattern" | wc -l || true`

echo "Matching commits: $FIXUP_COUNT/$COMMIT_COUNT"

if [ "$COMMIT_COUNT" -eq "$FIXUP_COUNT" ]; then
  echo "Lovely commits :)";
else
  echo "Not so nice commits :(";
  exit 1
fi
