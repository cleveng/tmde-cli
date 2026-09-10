use anyhow::anyhow;

use crate::{
    AppState
};

use crate::handler::domains::<@ data.name @>::{
    <@ data.capitalize_name @>, <@ data.capitalize_name @>Loader, <@ data.capitalize_name @>QueryOneOption, <@ data.capitalize_name @>QueryInput, <@ data.capitalize_name @>QueryOption,
};

pub struct <@ data.capitalize_name @>Loader(pub AppState);

impl <@ data.capitalize_name @>Loader {
    pub fn new(state: AppState) -> Self {
        Self(state)
    }

    pub async fn total(&self, option: &<@ data.capitalize_name @>QueryOption) -> Result<i64, anyhow::Error> {
        todo("implement");
    }

    pub async fn lists(
        &self,
        limit: i64,
        offset: i64,
        option: &<@ data.capitalize_name @>QueryOption,
    ) -> Result<Vec<<@ data.capitalize_name @>>, anyhow::Error> {
        todo("implement");
    }

    pub async fn first_by(&self, id: u64) -> Result<<@ data.capitalize_name @>, anyhow::Error> {
        todo("implement");
    }

    pub async fn store(&self, data: &<@ data.capitalize_name @>) -> Result<u64, anyhow::Error> {
        todo("implement");
    }

    pub async fn update(&self, data: &<@ data.capitalize_name @>) -> Result<(), anyhow::Error> {
        todo("implement");
    }

    pub async fn delete(&self, data: &<@ data.capitalize_name @>) -> Result<(), anyhow::Error> {
        todo("implement");
    }
}