mod entity;
mod loader;
mod repository;

pub use entity::{
    <@ data.capitalize_name @>, <@ data.capitalize_name @>Loader, <@ data.capitalize_name @>QueryOneOption, <@ data.plural_name @>QueryInput, <@ data.plural_name @>QueryOption,
};
pub use repository::<@ data.capitalize_name @>Loader;
