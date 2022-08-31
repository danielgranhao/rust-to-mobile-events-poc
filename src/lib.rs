#[cfg(target_os = "android")]
use log::Level;
#[cfg(not(target_os = "android"))]
use log::LevelFilter;
#[cfg(target_os = "ios")]
use oslog::OsLogger;

/// Initializes Rust-side logging.
///
/// For logging to work it must be called first.
///
/// Must only be called once. Calling this function more than once can cause a panic.
pub fn init_logger_once() {
    #[cfg(all(not(target_os = "android"), not(target_os = "ios")))]
    env_logger::Builder::filter_level(&mut Default::default(), LevelFilter::Info).init();
    #[cfg(target_os = "android")]
    android_logger::init_once(Config::default().with_min_level(Level::Trace));
    #[cfg(target_os = "ios")]
    OsLogger::new("com.example.rust_test")
        .level_filter(LevelFilter::Trace)
        .init()
        .unwrap();
}

include!(concat!(env!("OUT_DIR"), "/events_poc.uniffi.rs"));
