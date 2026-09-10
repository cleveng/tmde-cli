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
pub struct <@ data.capitalize_name @>Query;

#[Object]
impl <@ data.capitalize_name @>Query {
    /// Retrieves a list of all non-deleted <@ data.plural_name @>.
    ///
    /// This asynchronous method fetches all <@ data.plural_name @> from the database
    /// where the `deleted_at` field is `NULL`, indicating that the <@ data.name @>
    /// has not been deleted. The <@ data.plural_name @> are then converted into `<@ data.capitalize_name @>Object`
    /// instances and returned as a vector.
    ///
    /// # Arguments
    ///
    /// * `ctx` - The GraphQL context containing shared data, including the application state.
    ///
    /// # Returns
    ///
    /// Returns a `Result` containing a vector of `<@ data.capitalize_name @>Object`s if successful,
    /// or an error if the operation fails.
    pub async fn <@ data.plural_lower_name @>(&self, ctx: &Context<'_>) -> Result<Vec<<@ data.capitalize_name @>Object>, Error> {
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

        let result = match loader.lists().await {
            Ok(value) => value,
            Err(err) => {
                error!("Failed to get <@ data.plural_name @>: {err}");
                return Err(Error::new("Failed to get <@ data.plural_name @>"));
            }
        };

        let data: Vec<<@ data.capitalize_name @>Object> = result.into_iter().map(|v| v.to_object()).collect();

        Ok(data)
    }

    /// Retrieves a list of all non-deleted <@ data.name @>.
    ///
    /// This asynchronous method fetches all <@ data.name @> from the database
    /// where the `deleted_at` field is `NULL`, indicating that the <@ data.name @>
    /// has not been deleted. The <@ data.name @> are then converted into `<@ data.capitalize_name @>Object`
    /// instances and returned as a vector.
    ///
    /// # Arguments
    ///
    /// * `ctx` - The GraphQL context containing shared data, including the application state.
    ///
    /// # Returns
    ///
    /// Returns a `Result` containing a vector of `<@ data.capitalize_name @>Object` if successful,
    /// or an error if the operation fails.
    pub async fn <@ data.name @>(&self, ctx: &Context<'_>, id: u64) -> Result<<@ data.capitalize_name @>Object, Error> {
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

        let result = match loader.first_by(&<@ data.capitalize_name @>QueryOneOption::Id(id)).await {
            Ok(value) => value,
            Err(err) => {
                error!("Failed to fetch <@ data.name @>: {err}");
                return Err(Error::new("Failed to fetch <@ data.name @>"));
            }
        };

        let data: <@ data.capitalize_name @>Object = result.to_object();

        Ok(data)
    }
}