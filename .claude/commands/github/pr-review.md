---
description: Review a PR using gh and provide actionable feedback
allowed-tools: Bash
argument-hint: <owner/repo#PR>
---

You are helping review a pull request.

1) Use gh to fetch the PR details, files, and diff.
2) Summarize intent.
3) Call out correctness, tests, DX, security.
4) Propose concrete patches.

Commands:
!`gh --version`
!`gh pr view $ARGUMENTS --json title,body,author,baseRefName,headRefName,commits,files`
!`gh pr diff $ARGUMENTS`
