use anyhow::anyhow;
use chrono::Utc;
use deadpool_redis::redis::cmd;
use sqlx::{QueryBuilder, Row};

use crate::{
    AppState
};
use crate::handler::domains::<@ data.name @>::{
    <@ data.capitalize_name @>, <@ data.capitalize_name @>QueryOption, <@ data.plural_name @>QueryOption,
};

pub struct <@ data.capitalize_name @>Loader(AppState);

impl <@ data.capitalize_name @>Loader {
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

    /// Get the total number of <@ data.plural_lower_name @> based on the given query options.
    ///
    /// The query options allow filtering by id etc...
    ///
    /// If the query options are not provided, the total number of agents will be returned.
    ///
    /// The result is an i64 representing the total number of agents.
    ///
    /// Errors are logged and the function returns 0 if an error occurs.
    pub async fn total(&self, option: &<@ data.plural_name @>QueryOption) -> i64 {
        let Ok(mut conn) = self.0.db_pools.slave().acquire().await else {
            return 0;
        };

        let mut builder =
            QueryBuilder::new("SELECT COUNT(*) as count FROM <@ data.plural_lower_name @> WHERE deleted_at IS NULL ");

        if let Some(id) = option.id {
            builder.push(" AND id = ").push_bind(id);
        }

        let query = builder.build_query_scalar();
        query.fetch_one(&mut *conn).await.unwrap_or_default()
    }

    /// Retrieves a list of <@ data.plural_lower_name @> from the database.
    ///
    /// This asynchronous function returns a vector of `<@ data.capitalize_name @>` objects representing the
    /// list of <@ data.plural_lower_name @> from the `<@ data.plural_lower_name @>` table where `deleted_at` is `NULL`.
    /// If the query fails, an error message is logged and an error is returned.
    ///
    /// # Arguments
    ///
    /// * `limit` - The maximum number of <@ data.plural_lower_name @> to return.
    /// * `offset` - The number of <@ data.plural_lower_name @> to skip before returning the result.
    /// * `option` - The parameters to filter the <@ data.plural_lower_name @> by.
    ///
    /// # Returns
    ///
    /// A `Result` containing the list of <@ data.plural_lower_name @> if the query is successful, or an error
    /// containing the description of the error if the query fails.
    pub async fn lists(
        &self,
        limit: i64,
        offset: i64,
        option: &<@ data.plural_name @>QueryOption,
    ) -> Result<Vec<<@ data.capitalize_name @>>, anyhow::Error> {
        let mut conn = self.0.db_pools.master().acquire().await?;

        let mut builder =
            QueryBuilder::new("SELECT * FROM <@ data.plural_lower_name @> WHERE deleted_at IS NULL ");

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
                log::error!("fetch <@ data.plural_lower_name @> by <@ data.plural_name @>QueryOption err: {err}");
                return Err(anyhow!("fetch <@ data.plural_lower_name @> by <@ data.plural_name @>QueryOption err"));
            }
        };

        let mut result = vec![];
        for row in rows {
            let item = <@ data.capitalize_name @> {
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

    /// Retrieves an <@ data.name @> by id or user id from the database.
    ///
    /// This asynchronous function returns an `<@ data.capitalize_name @>` object representing the agent
    /// by `id` or other field from the `<@ data.plural_lower_name @>` table where `deleted_at` is `NULL`.
    /// If the query fails, an error message is logged and the error is returned.
    ///
    /// # Arguments
    ///
    /// * `option` - The option to filter the <@ data.name @> by.
    ///
    /// # Returns
    ///
    /// A `Result` containing the <@ data.name @> if the query is successful, or an error
    /// containing the description of the error if the query fails.
    pub async fn first_by(&self, option: &<@ data.capitalize_name @>QueryOption) -> Result<<@ data.capitalize_name @>, anyhow::Error> {
        let mut rdb = self.0.rdb_pool.get().await?;

        let key = match &option {
            <@ data.capitalize_name @>QueryOption::Id(id) => format!("{}:{}", "<@ data.plural_lower_name @>", id),
        };
        let value: Option<String> = cmd("GET")
            .arg(&key)
            .query_async(&mut rdb)
            .await
            .unwrap_or(None);

        if let Some(values) = value
            .as_deref()
            .and_then(|bytes| serde_json::from_str::<<@ data.capitalize_name @>>(bytes).ok())
        {
            return Ok(values);
        }

        let mut conn = self.0.db_pools.slave().acquire().await?;

        let mut builder =
            QueryBuilder::new("SELECT * FROM <@ data.plural_lower_name @> WHERE deleted_at IS NULL ");

        match option {
            <@ data.capitalize_name @>QueryOption::Id(id) => {
                builder.push(" AND id = ").push_bind(id);
            }
        }

        builder.push(" LIMIT 1");
        let query = builder.build();

        let result = match query.fetch_one(&mut *conn).await {
            Ok(row) => <@ data.capitalize_name @> {
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

    /// Stores a new <@ data.name @> in the database.
    ///
    /// This asynchronous function stores a new <@ data.name @> in the `<@ data.plural_lower_name @>` table.
    /// If the query fails, an error message is logged and the error is returned.
    ///
    /// # Arguments
    ///
    /// * `data` - The <@ data.name @> to store.
    ///
    /// # Returns
    ///
    /// A `Result` containing the id of the newly stored <@ data.name @> if the query is successful,
    /// or an error containing the description of the error if the query fails.
    pub async fn store(&self, data: &<@ data.capitalize_name @>) -> Result<u64, anyhow::Error> {
        let mut conn = self.0.db_pools.master().acquire().await?;

        let last_insert_id = match sqlx::query!(
            r#"
                INSERT INTO
                    <@ data.plural_lower_name @> (
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

    /// Updates an <@ data.name @> in the database.
    ///
    /// This asynchronous function updates an <@ data.name @> in the `<@ data.plural_lower_name @>` table.
    /// If the query fails, an error message is logged and the error is returned.
    ///
    /// # Arguments
    ///
    /// * `data` - The <@ data.name @> data to update, including the `id` of the <@ data.name @>.
    ///
    /// # Returns
    ///
    /// A `Result` containing `()` if the query is successful, or an error containing
    /// the description of the error if the query fails or no rows are affected.
    pub async fn update(&self, data: &<@ data.capitalize_name @>) -> Result<(), anyhow::Error> {
        let mut conn = self.0.db_pools.master().acquire().await?;

        if let Err(err) = sqlx::query!(
            r#"
                UPDATE
                    <@ data.plural_lower_name @>
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

            log::error!("update <@ data.name @> err: {err}");
            return Err(anyhow!("update <@ data.name @> err: {err}"));
        };

        // clear cache from redis
        self.purge_data_cache(data).await?;

        Ok(())
    }

    /// Marks an <@ data.name @> as deleted in the database by setting its `deleted_at` timestamp.
    ///
    /// This asynchronous function updates the `deleted_at` field of the <@ data.name @> with the specified `id`
    /// in the `<@ data.plural_lower_name @>` table. If the query fails or no rows are affected, an error message is logged and the error is returned.
    ///
    /// # Arguments
    ///
    /// * `id` - The id of the <@ data.name @> to mark as deleted.
    ///
    /// # Returns
    ///
    /// A `Result` containing `()` if the query is successful, or an error containing
    /// the description of the error if the query fails or no rows are affected.
    pub async fn delete(&self, data: &<@ data.capitalize_name @>) -> Result<(), anyhow::Error> {
        let mut conn = self.0.db_pools.master().acquire().await?;

        let now = Utc::now().naive_utc();
        if let Err(err) = sqlx::query!(
            r#"
                UPDATE <@ data.plural_lower_name @> SET deleted_at = ? WHERE id = ? AND deleted_at IS NULL
            "#,
            now,
            data.id
        )
        .execute(&mut *conn)
        .await
        {
            log::error!("delete <@ data.name @> err: {err}");
            return Err(anyhow!("delete <@ data.name @> failed {err}"));
        };

        // clear cache from redis
        self.purge_data_cache(data).await?;

        Ok(())
    }

    /// Clears the cache of a <@ data.name @> in Redis.
    ///
    /// This asynchronous function deletes the cache of a <@ data.name @> in Redis. It ensures that the global role is always up-to-date.
    ///
    /// # Arguments
    ///
    /// * `id` - The id of the <@ data.name @> to clear the cache for.
    ///
    /// # Returns
    ///
    /// A `Result` containing `()` if the query is successful, or an error containing
    /// the description of the error if the query fails or no rows are affected.
    async fn purge_data_cache(&self, data: &<@ data.capitalize_name @>) -> Result<(), anyhow::Error> {
        let keys_to_delete: Vec<String> = vec![
            format!("{}:{}", "<@ data.plural_lower_name @>", data.id),
        ];

        let mut rdb = self.0.rdb_pool.get().await?;
        cmd("DEL")
            .arg(&keys_to_delete)
            .query_async::<()>(&mut rdb)
            .await?;

        Ok(())
    }
}
