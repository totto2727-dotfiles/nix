# Nix configuration maintenance

Preserve the existing configuration, package placement, flake locks, and Just recipes during this migration.
Change paths only where repository separation requires it.
Do not add fallback package selection or repair unrelated evaluation or build failures.
Do not add standalone task scripts or replace Just with Nix apps.
CI runs on push and checks formatting only, without package builds, system builds, or activation.

Before every dependency update or system upgrade, read [the update inventory](share/packages/README.md) and check all entries.
Follow the package-specific steps for independently pinned versions and hashes.
Keep the inventory current when an independently pinned package changes.
