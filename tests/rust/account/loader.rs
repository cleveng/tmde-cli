use std::{collections::HashMap, sync::Arc};

use async_graphql::dataloader::Loader;

use crate::handler::domains::account::{
    Account, AccountLoader, AccountQueryOneOption, AccountsQueryInput, AccountsQueryOption
};

impl Loader<u64> for AccountLoader {
    type Value = Account;
    type Error = Arc<sqlx::Error>;

    async fn load(&self, keys: &[u64]) -> Result<HashMap<u64, Self::Value>, Self::Error> {
        let option = AccountQueryOneOption::Id(keys[0]);
        let data = match self.first_by(&option).await {
            Ok(data) => data,
            Err(e) => {
                log::error!("Failed to load account: {}", e);
                return Err(Arc::new(sqlx::Error::RowNotFound));
            }
        };

        let mut items = HashMap::new();
        items.insert(data.id, data);

        Ok(items)
    }
}
