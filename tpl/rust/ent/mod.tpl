mod entity;
mod loader;
mod repository;

pub use entity::{
    <@ data.capitalize_name @>, <@ data.capitalize_name @>Input, <@ data.capitalize_name @>Object,
    <@ data.plural_name @>QueryInput, <@ data.capitalize_name @>QueryOption, <@ data.plural_name @>QueryOption,
};
pub use repository::<@ data.capitalize_name @>Loader;
