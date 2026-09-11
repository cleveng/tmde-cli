use heck::ToUpperCamelCase;
use inflector::Inflector;
use pluralizer::pluralize;
use serde::Serialize;

#[derive(Serialize)]
pub struct Tmde {
    /// 原始名称，例如 account
    pub name: String,

    /// 原始名称 UpperCamelCase，例如 Account
    pub capitalize_name: String,

    /// 单数 UpperCamelCase，例如 Account
    pub pascal_case_name: String,

    /// 复数 UpperCamelCase，例如 Accounts
    pub plural_name: String,

    /// 小写复数，例如 accounts
    pub plural_lower_name: String,
}

impl Tmde {
    pub fn new(name: impl Into<String>) -> Self {
        let name = name.into();

        let capitalize_name = name.as_str().to_upper_camel_case(); // 首字母大写
        let pascal_case_name = name.to_pascal_case().to_singular();

        let plural_name = pluralize(&capitalize_name, 2, false);
        let plural_lower_name = plural_name.to_lowercase();

        Self {
            name: name.to_string(),
            capitalize_name,
            pascal_case_name,
            plural_name,
            plural_lower_name,
        }
    }
}
