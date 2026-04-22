# Contributing

This kit exists to make Claude Code approachable for non coders and powerful for everyone else. Contributions that move it toward either goal are very welcome.

## What is easy and helpful to contribute

### Share a filled-in `CLAUDE.md`

If you set up a project with this kit and it worked for you, your `CLAUDE.md` is probably gold for someone else starting the same kind of project.

1. Copy it into `examples/<project-type>/CLAUDE.md` (for example `examples/shopify-theme/CLAUDE.md`).
2. Strip anything personal: your name, company, email, phone, API keys, internal URLs, client names, paths that include `/Users/yourname/`.
3. Add a short `README.md` next to it that explains what kind of project it is for in two or three lines.
4. Open a PR with the title `examples: add <project-type>` and a one line description.

A good example folder has: a `CLAUDE.md`, a `README.md`, and nothing else. No source code, no screenshots of real apps, no secrets.

### Fix a broken setup step

If the install script or one of the setup commands in `README.md` did not work on your machine, open an issue using the **Setup help** template. If you found the fix yourself, PR it.

### Improve a hook

All hooks live in `hooks/`. Each one should be:

- Self contained (stdlib only, no `pip install`).
- Fail closed on error: exit 0 and let Claude continue, never crash the session.
- Documented in `hooks/README.md` and `hooks/SAFETY.md`.

If you add a hook, update both docs in the same PR.

### Translate a guide

Hebrew is already in `README.he.md`. If you want to add another language, copy `README.md` to `README.<lang>.md` and link from the top of the English README. Translate the docs, not the code or filenames.

## What to avoid

- **No names, emails, phone numbers, real client names, or real company names** in any contribution. Use `example.com`, `you@example.com`, `Your Company`.
- **No API keys or secrets**, even expired ones. CI will reject PRs that contain them.
- **No screenshots of real apps with real data.** Blur or synthesize.
- **No new frameworks or heavy runtimes** unless they replace something. The install script should stay small.
- **No opinions stated as rules.** If a rule is new, explain why in the PR.

## PR checklist

- [ ] Branch is a feature branch (`feat/...`, `fix/...`, `docs/...`). No pushes to `main`.
- [ ] No personal data. (grep your diff for your own name and email before you push.)
- [ ] `install.sh` still runs clean on a fresh `~` directory.
- [ ] New examples include a `CLAUDE.md` + `README.md` pair.
- [ ] New hooks are documented in `hooks/README.md` and `hooks/SAFETY.md`.

## Code of conduct

Be kind. Assume the other person is a beginner. If someone is clearly new, explain the concept before the syntax.

## License

By contributing you agree that your contribution is released under the same MIT license as the rest of the project.
