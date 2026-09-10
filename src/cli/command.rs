use clap::{Parser, Subcommand};

use crate::generator::{FileType, GenerateTarget};

#[derive(Parser)]
#[command(name = "commands")]
#[command(about = "A CLI tool with multiple command sets", version = "0.0.1")]
pub struct Cli {
    #[command(subcommand)]
    pub command: Commands,
}

#[derive(Subcommand)]
pub enum Commands {
    Gen {
        /// 简写：tmde gen tsx accounts
        #[arg(value_parser)]
        file_type: Option<FileType>,

        /// 简写：tmde gen tsx accounts
        name: Option<String>,

        /// 仅 Rs 支持，例如：ent 或 gql，最多一个
        #[arg(value_parser)]
        target_arg: Option<GenerateTarget>,

        /// 完整：tmde gen --type tsx
        #[arg(long = "type", value_parser)]
        type_arg: Option<FileType>,

        /// 完整：tmde gen --name accounts
        #[arg(long = "name")]
        name_arg: Option<String>,

        /// 覆盖已存在的文件
        #[arg(short = 'f', long = "force", default_value_t = false)]
        force: bool,
    },
}
