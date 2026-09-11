use futures_util::StreamExt;
use indicatif::{ProgressBar, ProgressStyle};
use reqwest::Client;
use semver::Version;
use serde::Deserialize;
use std::process::Command;
use tokio::io::AsyncWriteExt;

#[derive(Debug, Deserialize)]
struct GithubRelease {
    tag_name: String,
    assets: Vec<GithubAsset>,
}

#[derive(Debug, Deserialize)]
struct GithubAsset {
    name: String,
    browser_download_url: String,
}

fn github_repository() -> Result<&'static str, Box<dyn std::error::Error>> {
    let repository = env!("CARGO_PKG_REPOSITORY");

    let repository = repository
        .trim_end_matches('/')
        .trim_start_matches("https://")
        .trim_start_matches("http://");

    let repository = repository
        .strip_prefix("github.com/")
        .ok_or("Cargo repository is not a GitHub repository")?;

    Ok(repository)
}

pub async fn run() -> Result<(), Box<dyn std::error::Error>> {
    let current_version = env!("CARGO_PKG_VERSION");

    println!("Current version: v{}", current_version);
    let client = Client::builder().user_agent("tmde-cli").build()?;

    let repository = github_repository()?;

    let url = format!(
        "https://api.github.com/repos/{}/releases/latest",
        repository
    );

    println!("Checking latest release...");

    let release: GithubRelease = client
        .get(url)
        .send()
        .await?
        .error_for_status()?
        .json()
        .await?;

    let latest_version = release
        .tag_name
        .strip_prefix('v')
        .unwrap_or(&release.tag_name);

    let current = Version::parse(current_version)?;
    let latest = Version::parse(latest_version)?;

    if latest <= current {
        println!("Already up to date.");
        return Ok(());
    }

    println!("New version available: v{} → v{}", current, latest);

    let asset = release.assets.first().ok_or("No release asset found")?;

    let filename = &asset.name;
    let download_url = &asset.browser_download_url;

    println!("Downloading: {download_url}");

    let path = std::env::temp_dir().join(filename);

    println!("Downloading: {}", filename);

    download_file(&client, download_url, &path).await?;

    println!("Downloaded: {}", path.display());

    Ok(())
}

async fn download_file(
    client: &reqwest::Client,
    url: &str,
    path: &std::path::Path,
) -> Result<(), Box<dyn std::error::Error>> {
    let response = client.get(url).send().await?.error_for_status()?;

    let total_size = response.content_length().unwrap_or(0);

    let pb = ProgressBar::new(total_size);

    pb.set_style(
        ProgressStyle::with_template(
            "{spinner:.green} [{elapsed_precise}] \
            [{wide_bar:.cyan/blue}] {bytes}/{total_bytes} \
            ({percent}%) {bytes_per_sec} ETA {eta}",
        )?
        .progress_chars("=>-"),
    );

    let mut stream = response.bytes_stream();

    let mut file = tokio::fs::File::create(path).await?;

    while let Some(chunk) = stream.next().await {
        let chunk = chunk?;

        file.write_all(&chunk).await?;

        pb.inc(chunk.len() as u64);
    }

    file.flush().await?;

    pb.finish_with_message("Downloaded");

    open_tmp_dir()?;

    Ok(())
}

fn open_tmp_dir() -> Result<(), Box<dyn std::error::Error>> {
    Command::new("xdg-open").arg(std::env::temp_dir()).spawn()?;

    Ok(())
}
