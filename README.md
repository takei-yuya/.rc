# .rc

## Set your submodules or remove submodules

```bash
git submodule set-url sources/30_public <your-repo>
git submodule set-url sources/50_private <your-repo>
git submodule set-url sources/70_work <your-repo>
```

```bash
git rm -r sources/30_public
git rm -r sources/50_private
git rm -r sources/70_work
```

## Init submodules

```bash
git submodule update --init
```

## Setup

```bash
./setup.sh
```

