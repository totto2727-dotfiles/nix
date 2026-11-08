default:
    @just --list --list-submodules

opencode:
    # post-installの関係上2回実行する必要がある
    bun add -g --trust @code-yeongyu/comment-checker
    bun add -g --trust @code-yeongyu/comment-checker
