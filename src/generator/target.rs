use clap::ValueEnum;

#[derive(Debug, Clone, ValueEnum)]
pub enum GenerateTarget {
    Ent,
    Gql,
}

impl GenerateTarget {
    pub fn template_dir(&self) -> &'static str {
        match self {
            Self::Ent => "ent",
            Self::Gql => "gql",
        }
    }
}
