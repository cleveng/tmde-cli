use async_graphql::{InputObject, SimpleObject};
use chrono::{DateTime, Utc};

use serde::{Deserialize, Serialize};
use sqlx::FromRow;

// #[derive(Debug, InputObject)]
// #[graphql(rename_fields = "snake_case")]
// pub struct PageInput {
//     pub per_page: Option<i64>,
//     pub current_page: Option<i64>,
// }
use crate::handler::domains::{PageInput};

#[derive(Debug, Serialize, Deserialize, Clone, FromRow)]
pub struct Account {
    pub created_at: Option<DateTime<Utc>>,
    pub updated_at: Option<DateTime<Utc>>,
    pub deleted_at: Option<DateTime<Utc>>,
    pub id: u64,
    pub name: String,
}

impl Account {
    pub fn to_object(&self) -> AccountObject {
        AccountObject {
            id: self.id,
            name: self.name.clone(),
        }
    }
}

#[derive(Debug, InputObject)]
#[graphql(rename_fields = "snake_case")]
pub struct AccountInput {
    pub name: Option<String>,
}

#[derive(Debug, SimpleObject)]
#[graphql(rename_fields = "snake_case")]
pub struct AccountObject {
    pub id: u64,
    pub name: String,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
pub enum AccountQueryOption {
    Id(u64),
}

#[derive(Debug, InputObject)]
#[graphql(rename_fields = "snake_case")]
pub struct AccountsQueryInput {
    #[graphql(flatten)]
    pub page: PageInput,
    pub id: Option<u64>,           // 用户id
}

#[derive(Debug, Serialize, Deserialize, Default, Clone)]
pub struct AccountsQueryOption {
    pub id: Option<u64>,           // 用户id
}
