use std::{collections::HashMap, sync::Arc};

use async_graphql::dataloader::Loader;

use crate::handler::domains::<@ data.name @>::{
    <@ data.capitalize_name @>, <@ data.capitalize_name @>Loader, <@ data.capitalize_name @>QueryOneOption, <@ data.plural_name @>QueryInput, <@ data.plural_name @>QueryOption
};

impl Loader<u64> for <@ data.capitalize_name @>Loader {
    type Value = <@ data.capitalize_name @>;
    type Error = Arc<sqlx::Error>;

    async fn load(&self, keys: &[u64]) -> Result<HashMap<u64, Self::Value>, Self::Error> {
        let option = <@ data.capitalize_name @>QueryOneOption::Id(keys[0]);
        let data = match self.first_by(&option).await {
            Ok(data) => data,
            Err(e) => {
                log::error!("Failed to load <@ data.name @>: {}", e);
                return Err(Arc::new(sqlx::Error::RowNotFound));
            }
        };

        let mut items = HashMap::new();
        items.insert(data.id, data);

        Ok(items)
    }
}
