use std::str::FromStr;

use crate::generator::GenerateTarget;

#[derive(Debug, Clone, PartialEq, Eq)]
pub enum FileType {
    Tsx,
    Rs,
    Svelte,
}

impl FromStr for FileType {
    type Err = String;

    fn from_str(value: &str) -> Result<Self, Self::Err> {
        match value {
            "tsx" | ".tsx" => Ok(Self::Tsx),
            "rs" | ".rs" => Ok(Self::Rs),
            "svelte" | ".svelte" => Ok(Self::Svelte),
            _ => Err(format!(
                "not support: {value}, support: ts, rs, svelte, .ts, .rs, .svelte"
            )),
        }
    }
}

impl FileType {
    pub fn filename(&self) -> &'static str {
        match self {
            Self::Tsx => "tsx",
            Self::Rs => "rs",
            Self::Svelte => "svelte",
        }
    }

    pub fn extension(&self) -> &'static str {
        match self {
            Self::Tsx => "tsx",
            Self::Rs => "rs",
            Self::Svelte => "svelte",
        }
    }

    pub fn template_paths(&self, target: Option<&GenerateTarget>) -> Vec<&'static str> {
        match self {
            Self::Tsx => vec![
                "typescript/index.tpl",
                "typescript/components/tsx-action-dialog.tpl",
                "typescript/components/tsx-dialogs.tpl",
                "typescript/components/tsx-mutate-dialog.tpl",
                "typescript/components/tsx-primary-button.tpl",
                "typescript/components/tsx-provider.tpl",
                "typescript/components/tsx-table.tpl",
            ],

            Self::Rs => match target.unwrap_or(&GenerateTarget::Ent) {
                GenerateTarget::Ent => vec![
                    "rust/ent/entity.tpl",
                    "rust/ent/loader.tpl",
                    "rust/ent/mod.tpl",
                    "rust/ent/repository.tpl",
                ],

                GenerateTarget::Gql => vec![
                    "rust/gql/mod.tpl",
                    "rust/gql/query.tpl",
                    "rust/gql/mutation.tpl",
                ],
            },

            Self::Svelte => vec![
                "svelte/+page.tpl",
                "svelte/+layout.tpl",
                "svelte/components/svelte-action-dialog.tpl",
                "svelte/components/svelte-dialogs.tpl",
                "svelte/components/svelte-mutate-dialog.tpl",
                "svelte/components/svelte-primary-button.tpl",
                "svelte/components/svelte-provider.tpl",
                "svelte/components/svelte-table.tpl",
            ],
        }
    }
}
