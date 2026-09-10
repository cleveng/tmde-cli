use include_dir::{Dir, include_dir};
use tera::{Delimiters, Tera};

pub static TEMPLATE_DIR: Dir = include_dir!("$CARGO_MANIFEST_DIR/tpl");

pub fn build_tera() -> Result<Tera, anyhow::Error> {
    let mut tera = Tera::default();
    tera.set_delimiters(Delimiters {
        block_start: "<%".into(),
        block_end: "%>".into(),
        variable_start: "<@".into(),
        variable_end: "@>".into(),
        comment_start: "<#".into(),
        comment_end: "#>".into(),
    })?;

    #[cfg(debug_assertions)]
    {
        if let Err(err) = tera.load_from_glob("tpl/**/*.tpl") {
            panic!("Failed to load tpl templates: {}", err);
        };

        Ok(tera)
    }

    #[cfg(not(debug_assertions))]
    {
        fn add_files(tera: &mut Tera, dir: &Dir) -> anyhow::Result<()> {
            for entry in dir.entries() {
                match entry {
                    include_dir::DirEntry::File(f) => {
                        let name = f.path().to_string_lossy().replace('\\', "/");

                        let content = f.contents_utf8().unwrap();
                        tera.add_raw_template(&name, content)?;
                    }

                    include_dir::DirEntry::Dir(d) => {
                        add_files(tera, d)?;
                    }
                }
            }

            Ok(())
        }

        add_files(&mut tera, &TEMPLATE_DIR)?;

        Ok(tera)
    }
}
