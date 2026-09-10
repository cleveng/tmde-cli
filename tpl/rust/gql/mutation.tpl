
use crate::{
    AppState,
    handler::domains::{
        LoggedInUser,
        <@ data.name @>::{
            <@ data.capitalize_name @>, <@ data.capitalize_name @>Input, <@ data.capitalize_name @>Loader, <@ data.capitalize_name @>QueryOneOption,
        },
    }
};
use async_graphql::{Context, Error, Object};

#[derive(Default)]
pub struct <@ data.capitalize_name @>Mutation;

#[Object]
impl <@ data.capitalize_name @>Mutation {
    /// Creates a new <@ data.name @> with the provided parameters.
    ///
    /// The `app_secret` field is optional and defaults to `None` if not
    /// provided. The `callback_url` field is also optional and defaults to
    /// an empty string if not provided. The `platform_type` field is
    /// required and must be set to one of the supported values.
    ///
    /// # Arguments
    ///
    /// * `ctx` - The GraphQL context containing shared data, including the application state.
    /// * `input` - The input parameters for creating a new <@ data.name @>.
    ///
    /// # Returns
    ///
    /// Returns a `Result` containing a string with the value `"ok"` if the
    /// <@ data.name @> was created successfully, or an error if the operation fails.
    async fn create_<@ data.name @>(
        &self,
        ctx: &Context<'_>,
        input: <@ data.capitalize_name @>Input,
    ) -> Result<String, Error> {
        let current_user = ctx
            .data::<LoggedInUser>()
            .map_err(|_| Error::new("You are not logged in"))?
            .0
            .clone();
        if !current_user.is_root() {
            return Err(Error::new("You are not permission to action"));
        }

        let app_state = ctx.data::<AppState>()?;
        let loader = <@ data.capitalize_name @>Loader::new(app_state.clone());

        let data = <@ data.capitalize_name @> {
            created_at: None,
            updated_at: None,
            deleted_at: None,
            id: 0,
        };

        if let Err(err) = loader.store(&data).await {
            log::error!("Failed to create <@ data.name @>: {err}");
            return Err(Error::new("Failed to create <@ data.name @>"));
        }

        Ok("ok".to_string())
    }

    /// Updates an existing <@ data.name @> with the given parameters.
    ///
    /// This asynchronous method updates an <@ data.name @> in the database using the
    /// provided `id` and `input`. Existing <@ data.name @> details are modified based
    /// on the non-null fields in the `input`, while the `platform_type` is
    /// conditionally updated if a new value is provided.
    ///
    /// # Arguments
    ///
    /// * `ctx` - The GraphQL context containing shared data, including the application state.
    /// * `id` - The unique identifier of the <@ data.name @> to be updated.
    /// * `input` - The input parameters containing the updated <@ data.name @> details.
    ///
    /// # Returns
    ///
    /// Returns a `Result` containing a string with the value `"ok"` if the
    /// <@ data.name @> was updated successfully, or an error if the operation fails.
    ///
    /// # Errors
    ///
    /// Returns an error if the <@ data.name @> is not found or if there is a failure
    /// during the update process.
    async fn update_<@ data.name @>(
        &self,
        ctx: &Context<'_>,
        id: u64,
        input: <@ data.capitalize_name @>Input,
    ) -> Result<String, Error> {
        let current_user = ctx
            .data::<LoggedInUser>()
            .map_err(|_| Error::new("You are not logged in"))?
            .0
            .clone();
        if !current_user.is_root() {
            return Err(Error::new("You are not permission to action"));
        }

        let app_state = ctx.data::<AppState>()?;
        let loader = <@ data.capitalize_name @>Loader::new(app_state.clone());

        let record = match loader.first_by(&<@ data.capitalize_name @>QueryOneOption::Id(id)).await {
            Ok(row) => row,
            Err(err) => {
                log::error!("Failed to fetch <@ data.name @>: {err}");
                return Err(Error::new("Failed to fetch <@ data.name @>"));
            }
        };

        let data = <@ data.capitalize_name @> {
            ..record
        };

        if let Err(err) = loader.update(&data).await {
            log::error!("Failed to update <@ data.name @>: {err}");
            return Err(Error::new("Failed to update <@ data.name @>"));
        }

        Ok("ok".to_string())
    }

    /// Deletes an existing <@ data.name @> by its unique identifier.
    ///
    /// This asynchronous method deletes an <@ data.name @> from the database based
    /// on the provided `id`. It first attempts to retrieve the <@ data.name @>
    /// to ensure it exists before proceeding with the deletion process.
    ///
    /// # Arguments
    ///
    /// * `ctx` - The GraphQL context containing shared data, including the application state.
    /// * `id` - The unique identifier of the <@ data.name @> to be deleted.
    ///
    /// # Returns
    ///
    /// Returns a `Result` containing a string with the value `"ok"` if the
    /// <@ data.name @> was deleted successfully, or an error if the operation fails.
    ///
    /// # Errors
    ///
    /// Returns an error if the <@ data.name @> is not found or if there is a failure
    /// during the deletion process.
    async fn delete_<@ data.name @>(&self, ctx: &Context<'_>, id: u64) -> Result<String, Error> {
        let current_user = ctx
            .data::<LoggedInUser>()
            .map_err(|_| Error::new("You are not logged in"))?
            .0
            .clone();
        if !current_user.is_root() {
            return Err(Error::new("You are not permission to action"));
        }

        let app_state = ctx.data::<AppState>()?;
        let loader = <@ data.capitalize_name @>Loader::new(app_state.clone());

        let record = match loader.first_by(&<@ data.capitalize_name @>QueryOneOption::Id(id)).await {
            Ok(row) => row,
            Err(err) => {
                log::error!("Failed to fetch <@ data.name @>: {err}");
                return Err(Error::new("Failed to fetch <@ data.name @>"));
            }
        };

        if let Err(err) = loader.delete(record.id).await {
            log::error!("Failed to delete <@ data.name @>: {err}");
            return Err(Error::new("Failed to delete <@ data.name @>"));
        }

        Ok("ok".to_string())
    }
}