# Skill: GitHub automation (gh + Copilot)

## gh auth

```bash
gh auth status
```

## Typical PR review flow

```bash
gh pr view OWNER/REPO#123
gh pr diff OWNER/REPO#123
```

## Repo hygiene

- Use issue/PR templates in `.github/`.
- Keep CI minimal but always running typecheck/build.
