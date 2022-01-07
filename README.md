# Commit

A Bash helper to create consistent commit messages. Just use one command and let the helper help you to create the commits.

### Usage

There are several ways you can use this. You can [https://commit.sil.mt/assets/commit.sh download](download) the script, or just create a shortcut in your `.bashr` or `.zshrc` to use the script with a single command and always use the latests version.

#### Install

Add the following to your `~/.bashrc` or `~/.zshrc` and now you can just use `sil:commit` or whatever you want to call it.

```bash
function sil:commit {
    bash <(curl -s https://commit.sil.mt/assets/commit.sh)
}
```

### Similar projects

- (Create Component)[https://create-component.sil.mt]
