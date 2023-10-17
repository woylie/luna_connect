# Luna Connect

A shabby CLI tool for shoving tasks from services into Lunatask.

```bash
git clone https://github.com/woylie/luna_connect
cd luna_connect
mix install
```

Copy the default configuration to a local folder:

```bash
mkdir -p ~/.config/luna_connect
cp ./config.yml ~/.config/luna_connect
```

Adjust the configuration to your needs.

You can override the default config folder by setting the
`LUNA_CONNECT_CONFIG_PATH` environment variable.

## Other mix aliases

- `mix setup`
- `mix build`

## Usage

Import Github issues assigned to `@me`:

```bash
luco gh
```

## Why Elixir?

Because it's what I know.

## Contributions

On the off-chance you find this tool in any way useful and feel the inexplicable
urge to improve it, PRs are begrudgingly welcomed.
