use anyhow::anyhow;

use crate::{
    AppState
};

use crate::handler::domains::account::{
    Account, AccountLoader, AccountQueryOneOption, AccountQueryInput, AccountQueryOption,
};

pub struct AccountLoader(pub AppState);

impl AccountLoader {
    pub fn new(state: AppState) -> Self {
        Self(state)
    }

    pub async fn total(&self, option: &AccountQueryOption) -> Result<i64, anyhow::Error> {
        todo("implement");
    }

    pub async fn lists(
        &self,
        limit: i64,
        offset: i64,
        option: &AccountQueryOption,
    ) -> Result<Vec<Account>, anyhow::Error> {
        todo("implement");
    }

    pub async fn first_by(&self, id: u64) -> Result<Account, anyhow::Error> {
        todo("implement");
    }

    pub async fn store(&self, data: &Account) -> Result<u64, anyhow::Error> {
        todo("implement");
    }

    pub async fn update(&self, data: &Account) -> Result<(), anyhow::Error> {
        todo("implement");
    }

    pub async fn delete(&self, data: &Account) -> Result<(), anyhow::Error> {
        todo("implement");
    }
}