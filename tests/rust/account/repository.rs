use anyhow::anyhow;
use chrono::Utc;
use deadpool_redis::redis::cmd;
use sqlx::{QueryBuilder, Row};

use crate::{
    AppState
};
use crate::handler::domains::account::{
    Account, AccountQueryOption, AccountsQueryOption,
};

pub struct AccountLoader(AppState);

impl AccountLoader {
    /// Creates a new `AgentLoader` instance with the provided `state`.
    ///
    /// # Arguments
    ///
    /// * `state` - An instance of `AppState` representing the application state.
    ///
    /// # Returns
    ///
    /// An instance of `AgentLoader` with the provided `state`.
    pub fn new(state: AppState) -> Self {
        Self(state)
    }

    /// Get the total number of accounts based on the given query options.
    ///
    /// The query options allow filtering by id etc...
    ///
    /// If the query options are not provided, the total number of agents will be returned.
    ///
    /// The result is an i64 representing the total number of agents.
    ///
    /// Errors are logged and the function returns 0 if an error occurs.
    pub async fn total(&self, option: &AccountsQueryOption) -> i64 {
        let Ok(mut conn) = self.0.db_pools.slave().acquire().await else {
            return 0;
        };

        let mut builder =
            QueryBuilder::new("SELECT COUNT(*) as count FROM accounts WHERE deleted_at IS NULL ");

        if let Some(id) = option.id {
            builder.push(" AND id = ").push_bind(id);
        }

        let query = builder.build_query_scalar();
        query.fetch_one(&mut *conn).await.unwrap_or_default()
    }

    /// Retrieves a list of accounts from the database.
    ///
    /// This asynchronous function returns a vector of `Account` objects representing the
    /// list of accounts from the `accounts` table where `deleted_at` is `NULL`.
    /// If the query fails, an error message is logged and an error is returned.
    ///
    /// # Arguments
    ///
    /// * `limit` - The maximum number of accounts to return.
    /// * `offset` - The number of accounts to skip before returning the result.
    /// * `option` - The parameters to filter the accounts by.
    ///
    /// # Returns
    ///
    /// A `Result` containing the list of accounts if the query is successful, or an error
    /// containing the description of the error if the query fails.
    pub async fn lists(
        &self,
        limit: i64,
        offset: i64,
        option: &AccountsQueryOption,
    ) -> Result<Vec<Account>, anyhow::Error> {
        let mut conn = self.0.db_pools.master().acquire().await?;

        let mut builder =
            QueryBuilder::new("SELECT * FROM accounts WHERE deleted_at IS NULL ");

        if let Some(id) = option.id {
            builder.push(" AND id = ").push_bind(id);
        }

        builder
            .push(" ORDER BY a.id DESC LIMIT ")
            .push_bind(limit)
            .push(" OFFSET ")
            .push_bind(offset);

        let query = builder.build();
        let rows: Vec<sqlx::mysql::MySqlRow> = match query.fetch_all(&mut *conn).await {
            Ok(rows) => rows,
            Err(err) => {
                log::error!("fetch accounts by AccountsQueryOption err: {err}");
                return Err(anyhow!("fetch accounts by AccountsQueryOption err"));
            }
        };

        let mut result = vec![];
        for row in rows {
            let item = Account {
                created_at: None,
                updated_at: None,
                deleted_at: None,
                id: row.try_get::<u64, _>("id")?,
                name: row.try_get::<String, _>("name")?,
            };

            result.push(item);
        }

        Ok(result)
    }

    /// Retrieves an account by id or user id from the database.
    ///
    /// This asynchronous function returns an `Account` object representing the agent
    /// by `id` or other field from the `accounts` table where `deleted_at` is `NULL`.
    /// If the query fails, an error message is logged and the error is returned.
    ///
    /// # Arguments
    ///
    /// * `option` - The option to filter the account by.
    ///
    /// # Returns
    ///
    /// A `Result` containing the account if the query is successful, or an error
    /// containing the description of the error if the query fails.
    pub async fn first_by(&self, option: &AccountQueryOption) -> Result<Account, anyhow::Error> {
        let mut rdb = self.0.rdb_pool.get().await?;

        let key = match &option {
            AccountQueryOption::Id(id) => format!("{}:{}", "accounts", id),
        };
        let value: Option<String> = cmd("GET")
            .arg(&key)
            .query_async(&mut rdb)
            .await
            .unwrap_or(None);

        if let Some(values) = value
            .as_deref()
            .and_then(|bytes| serde_json::from_str::<Account>(bytes).ok())
        {
            return Ok(values);
        }

        let mut conn = self.0.db_pools.slave().acquire().await?;

        let mut builder =
            QueryBuilder::new("SELECT * FROM accounts WHERE deleted_at IS NULL ");

        match option {
            AccountQueryOption::Id(id) => {
                builder.push(" AND id = ").push_bind(id);
            }
        }

        builder.push(" LIMIT 1");
        let query = builder.build();

        let result = match query.fetch_one(&mut *conn).await {
            Ok(row) => Account {
                created_at: None,
                updated_at: None,
                deleted_at: None,
                id: row.try_get::<u64, _>("id")?,
                name: row.try_get::<String, _>("name")?,
            },
            Err(err) => {
                log::error!("fetch agent by id err: {err}");
                return Err(anyhow!("fetch agent by id err"));
            }
        };

        // 写入缓存
        cmd("SETEX")
            .arg(&key)
            .arg(1500)
            .arg(serde_json::to_string(&result).unwrap())
            .query_async::<()>(&mut rdb)
            .await?;

        Ok(result)
    }

    /// Stores a new account in the database.
    ///
    /// This asynchronous function stores a new account in the `accounts` table.
    /// If the query fails, an error message is logged and the error is returned.
    ///
    /// # Arguments
    ///
    /// * `data` - The account to store.
    ///
    /// # Returns
    ///
    /// A `Result` containing the id of the newly stored account if the query is successful,
    /// or an error containing the description of the error if the query fails.
    pub async fn store(&self, data: &Account) -> Result<u64, anyhow::Error> {
        let mut conn = self.0.db_pools.master().acquire().await?;

        let last_insert_id = match sqlx::query!(
            r#"
                INSERT INTO
                    accounts (
                        name
                    )
                VALUES
                    (?)
            "#,
            data.name,
        )
        .execute(&mut *conn)
        .await
        {
            Ok(value) => value.last_insert_id(),
            Err(err) => {
                log::error!("execute store agent err: {err}");
                return Err(anyhow!("execute store agent err: {err}"));
            }
        };

        Ok(last_insert_id)
    }

    /// Updates an account in the database.
    ///
    /// This asynchronous function updates an account in the `accounts` table.
    /// If the query fails, an error message is logged and the error is returned.
    ///
    /// # Arguments
    ///
    /// * `data` - The account data to update, including the `id` of the account.
    ///
    /// # Returns
    ///
    /// A `Result` containing `()` if the query is successful, or an error containing
    /// the description of the error if the query fails or no rows are affected.
    pub async fn update(&self, data: &Account) -> Result<(), anyhow::Error> {
        let mut conn = self.0.db_pools.master().acquire().await?;

        if let Err(err) = sqlx::query!(
            r#"
                UPDATE
                    accounts
                SET
                    name = ?
                WHERE
                    id = ?
                    AND deleted_at IS NULL
            "#,
            data.name,
            data.id
        )
        .execute(&mut *conn)
        .await
        {

            log::error!("update account err: {err}");
            return Err(anyhow!("update account err: {err}"));
        };

        // clear cache from redis
        self.purge_data_cache(data).await?;

        Ok(())
    }

    /// Marks an account as deleted in the database by setting its `deleted_at` timestamp.
    ///
    /// This asynchronous function updates the `deleted_at` field of the account with the specified `id`
    /// in the `accounts` table. If the query fails or no rows are affected, an error message is logged and the error is returned.
    ///
    /// # Arguments
    ///
    /// * `id` - The id of the account to mark as deleted.
    ///
    /// # Returns
    ///
    /// A `Result` containing `()` if the query is successful, or an error containing
    /// the description of the error if the query fails or no rows are affected.
    pub async fn delete(&self, data: &Account) -> Result<(), anyhow::Error> {
        let mut conn = self.0.db_pools.master().acquire().await?;

        let now = Utc::now().naive_utc();
        if let Err(err) = sqlx::query!(
            r#"
                UPDATE accounts SET deleted_at = ? WHERE id = ? AND deleted_at IS NULL
            "#,
            now,
            data.id
        )
        .execute(&mut *conn)
        .await
        {
            log::error!("delete account err: {err}");
            return Err(anyhow!("delete account failed {err}"));
        };

        // clear cache from redis
        self.purge_data_cache(data).await?;

        Ok(())
    }

    /// Clears the cache of a account in Redis.
    ///
    /// This asynchronous function deletes the cache of a account in Redis. It ensures that the global role is always up-to-date.
    ///
    /// # Arguments
    ///
    /// * `id` - The id of the account to clear the cache for.
    ///
    /// # Returns
    ///
    /// A `Result` containing `()` if the query is successful, or an error containing
    /// the description of the error if the query fails or no rows are affected.
    async fn purge_data_cache(&self, data: &Account) -> Result<(), anyhow::Error> {
        let keys_to_delete: Vec<String> = vec![
            format!("{}:{}", "accounts", data.id),
        ];

        let mut rdb = self.0.rdb_pool.get().await?;
        cmd("DEL")
            .arg(&keys_to_delete)
            .query_async::<()>(&mut rdb)
            .await?;

        Ok(())
    }
}
