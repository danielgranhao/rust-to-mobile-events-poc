use std::fmt::Debug;
use std::sync::Arc;
use std::time::Duration;
use tokio::runtime::Runtime;
#[cfg(target_os = "android")]
use log::Level;
#[cfg(not(target_os = "android"))]
use log::LevelFilter;
#[cfg(target_os = "ios")]
use oslog::OsLogger;
#[cfg(target_os = "android")]
use android_logger::Config;

pub trait PersistCallback: Send + Sync + Debug {
    /// Check if a file or directory exists
    fn exists(&self, path: String) -> bool;

    /// Read filenames in the given path
    fn read_dir(&self, path: String) -> Vec<String>;

    /// Write data to a file
    ///
    /// # Return
    /// Returns `true` if successful and `false` otherwise.
    ///
    /// Must only return after being certain that data was persisted safely.
    /// Failure to do so will result in loss of funds.
    ///
    /// Returning `false` will likely result in a channel being force-closed.
    fn write_to_file(&self, path: String, data: Vec<u8>) -> bool;

    /// Read data from file
    fn read(&self, path: String) -> Vec<u8>;
}


pub struct EventsPoc {
    tokio_runtime: Runtime,
    persist_callback: Arc<Box<dyn PersistCallback>>,
}

impl EventsPoc {
    pub fn new(persist_callback: Box<dyn PersistCallback>) -> Self {

        let tokio_runtime = tokio::runtime::Builder::new_multi_thread()
            .enable_all()
            .build()
            .unwrap();

        EventsPoc {
            tokio_runtime,
            persist_callback: Arc::new(persist_callback),
        }
    }

    pub fn update_record_after_delay(&self, path: String, data: Vec<u8>, delay_secs: u64) {
        let task_callback = Arc::clone(&self.persist_callback);
        self.tokio_runtime.spawn(async move {
            tokio::time::sleep(Duration::from_secs(delay_secs)).await;
            task_callback.write_to_file(path, data);
        });
    }
}


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
