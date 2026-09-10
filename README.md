# tmde-cli

tmde-cli 是一款基于 rust 编写的命令行工具，主要快速实现 `tsx`, `rs`, `svelte` 三种文件类型的文件生成，适用于前端、后端 rust graphql 开发。

模板文件内容可以在 `./tpl` 目录下查看，文件类型可在 `./src/generator/file_type.rs` 中查看。

## 根据文件类型生成文件

支持 `tsx`, `rs`, `svelte` 三种文件类型，具体用法如下:

- 完整命令

```bash
tmde gen --type=tsx --name=accounts
```

type 参数支持类型

| type   | 描述        | 完整命令示例                             | 短命令示例                 |
| ------ | ----------- | ---------------------------------------- | -------------------------- |
| tsx    | tsx 文件    | `tmde gen --type=tsx --name=accounts`    | `tmde gen tsx accounts`    |
| rs     | rust 文件   | `tmde gen --type=rs --name=accounts`     | `tmde gen rs accounts`     |
| svelte | svelte 文件 | `tmde gen --type=svelte --name=accounts` | `tmde gen svelte accounts` |

## rs 文件生成支持 ent 和 gql

```bash
$ tmde gen rs accounts gql
#Generated file: accounts/mod.rs
#Generated file: accounts/query.rs
#Generated file: accounts/mutation.rs
```

## force 参数

```bash
$ tmde gen rs accounts gql
#Directory already exists: accounts
#Use --force to overwrite existing files.

$ tmde gen rs accounts gql -f
#Generated file: accounts/mod.rs
#Generated file: accounts/query.rs
#Generated file: accounts/mutation.rs
```
