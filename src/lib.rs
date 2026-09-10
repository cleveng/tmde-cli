use clap::Parser;

pub mod cli;
pub mod generator;
pub mod template;

use crate::cli::{Cli, Commands};
use crate::generator::{FileType, generate_file};

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let cli = Cli::parse();
    match cli.command {
        // cargo run -- gen --type=tsx --name=accounts
        // cargo run -- gen tsx accounts ent
        // cargo run -- gen rs accounts ent | gql // 是否支持尾巴参数
        Commands::Gen {
            file_type,
            name,
            type_arg,
            name_arg,
            target_arg,
            force,
        } => {
            let file_type = type_arg
                .or(file_type)
                .expect("missing file type, e.g.: tsx");

            let name = name_arg.or(name).expect("missing name, e.g.: accounts");

            // 只有 Rs 支持 target
            if target_arg.is_some() && file_type != FileType::Rs {
                return Err(format!("file type `{file_type:?}` does not support target").into());
            }

            generate_file(&file_type, &name, target_arg, force)?;
        }
    }

    Ok(())
}
