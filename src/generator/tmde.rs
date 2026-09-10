use heck::ToUpperCamelCase;
use pluralizer::pluralize;
use serde::Serialize;

#[derive(Serialize)]
pub struct Tmde {
    /// 原始名称，例如 account
    pub name: String,

    /// UpperCamelCase，例如 Account
    pub capitalize_name: String,

    /// 复数 UpperCamelCase，例如 Accounts
    pub plural_name: String,

    /// 小写复数，例如 accounts
    pub plural_lower_name: String,
}

impl Tmde {
    pub fn new(name: &str) -> Self {
        let capitalize_name = name.to_upper_camel_case();
        let plural_name = pluralize(&capitalize_name, 2, false);
        let plural_lower_name = plural_name.to_lowercase();

        Self {
            name: name.to_string(),
            capitalize_name,
            plural_name,
            plural_lower_name,
        }
    }
}
