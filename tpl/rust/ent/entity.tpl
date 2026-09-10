use async_graphql::{InputObject, SimpleObject};
use chrono::{DateTime, Utc};

use serde::{Deserialize, Serialize};
use sqlx::FromRow;

#[derive(Debug, Serialize, Deserialize, Clone, FromRow)]
pub struct <@ data.capitalize_name @> {
    pub created_at: Option<DateTime<Utc>>,
    pub updated_at: Option<DateTime<Utc>>,
    pub deleted_at: Option<DateTime<Utc>>,
    pub id: u64,
}

impl <@ data.capitalize_name @> {
    pub fn to_object(&self) -> <@ data.capitalize_name @>Object {
        <@ data.capitalize_name @>Object {
            id: self.id,
        }
    }
}

#[derive(Debug, InputObject)]
#[graphql(rename_fields = "snake_case")]
pub struct <@ data.capitalize_name @>Input {
    pub name: Option<String>,
}

#[derive(Debug, SimpleObject)]
#[graphql(rename_fields = "snake_case")]
pub struct <@ data.capitalize_name @>Object {
    pub id: u64,
    pub name: String,
}

#[derive(Debug, Serialize, Deserialize, Default, Clone)]
pub enum <@ data.capitalize_name @>QueryOneOption {
    Id(u64),
}

#[derive(Debug, InputObject)]
#[graphql(rename_fields = "snake_case")]
pub struct <@ data.plural_name @>QueryInput {
    pub id: Option<u64>,           // 用户id
}

#[derive(Debug, Serialize, Deserialize, Default, Clone)]
pub struct <@ data.plural_name @>QueryOption {
    pub id: Option<u64>,           // 用户id
}