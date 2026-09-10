use heck::ToUpperCamelCase;
use pluralizer::pluralize;
use std::fs;
use std::path::Path;
use tera::Context;

use crate::{
    generator::{FileType, GenerateTarget, Tmde},
    template::{TEMPLATE_DIR, build_tera},
};

pub fn generate_file(
    file_type: &FileType,
    name: &str,
    target_arg: Option<GenerateTarget>,
    force: bool,
) -> Result<(), anyhow::Error> {
    let output_dir = Path::new(name);

    // 目录已经存在，并且没有指定 --force
    if output_dir.exists() && !force {
        println!("Directory already exists: {}", output_dir.display());
        println!("Use --force to overwrite existing files.");

        return Ok(());
    }

    let tmde = Tmde::new(name);

    // 1.0 创建文件夹
    let from_name = file_type.filename();
    let extension = file_type.extension();

    let tera = build_tera()?;
    let template_paths = file_type.template_paths(target_arg.as_ref());

    // 2.0 读取文件模板并创建文件
    for template_name in template_paths {
        // 检查内置模板是否存在
        if TEMPLATE_DIR.get_file(&template_name).is_none() {
            println!("internal template: {template_name} not found");
            continue;
        }

        let template_path = Path::new(template_name);

        // 模板所在目录
        let relative_path = Path::new(template_name)
            .components()
            .skip(1)
            .collect::<std::path::PathBuf>();

        let relative_dir = if file_type == &FileType::Rs {
            Path::new("")
        } else {
            relative_path.parent().unwrap_or(Path::new(""))
        };

        // 模板文件名
        let filename = template_path
            .file_stem()
            .unwrap()
            .to_string_lossy()
            .replace(from_name, name);

        // 最终输出目录：
        // {dir}/{name}/{模板目录}
        let output_dir = Path::new(name).join(relative_dir);

        // 自动创建目录
        fs::create_dir_all(&output_dir).unwrap();

        // 开始封装模板数据
        let capitalize_name = name.to_upper_camel_case(); // 首字母大写
        let plural_name = pluralize(&capitalize_name, 2, false); // 首字母大写且复数

        let mut context = Context::new();
        context.insert("data", &tmde);
        context.insert("plural_name", &plural_name);
        context.insert("capitalize_name", &capitalize_name);

        let content = match tera.render(&template_name, &context) {
            Ok(v) => v,
            Err(err) => {
                println!("Failed to render {} template: {}", &template_name, err);
                continue;
            }
        };

        let output_path = output_dir.join(format!("{}.{}", filename, extension));

        fs::write(&output_path, content).unwrap();
        println!("Generated file: {}", output_path.display());
    }

    Ok(())
}
