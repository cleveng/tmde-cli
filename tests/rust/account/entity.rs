use async_graphql::{InputObject, SimpleObject};
use chrono::{DateTime, Utc};

use serde::{Deserialize, Serialize};
use sqlx::FromRow;

#[derive(Debug, Serialize, Deserialize, Clone, FromRow)]
pub struct Account {
    pub created_at: Option<DateTime<Utc>>,
    pub updated_at: Option<DateTime<Utc>>,
    pub deleted_at: Option<DateTime<Utc>>,
    pub id: u64,
}

impl Account {
    pub fn to_object(&self) -> AccountObject {
        AccountObject {
            id: self.id,
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

#[derive(Debug, Serialize, Deserialize, Default, Clone)]
pub enum AccountQueryOneOption {
    Id(u64),
}

#[derive(Debug, InputObject)]
#[graphql(rename_fields = "snake_case")]
pub struct AccountsQueryInput {
    pub id: Option<u64>,           // 用户id
}

#[derive(Debug, Serialize, Deserialize, Default, Clone)]
pub struct AccountsQueryOption {
    pub id: Option<u64>,           // 用户id
}