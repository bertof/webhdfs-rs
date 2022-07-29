//! Hadoop WebHDFS API for Rust
//!
//! Quick start:
//!
//! ```no_run
//! use webhdfs::*;
//! use webhdfs::sync_client::ReadHdfsFile;
//! use std::io::Read;
//!
//! let cx = SyncHdfsClientBuilder::new("http://namenode:50070".parse().unwrap())
//!     .user_name("johnd".to_owned())
//!     .build().unwrap();
//!
//! let mut file = ReadHdfsFile::open(cx, "/user/johnd/in.txt".to_owned()).unwrap();
//! let mut buf = [0u8; 100];
//! let _ = file.read(&mut buf).unwrap();
//!
//! ```

#[macro_use]
mod error;
pub mod async_client;
pub mod config;
pub mod datatypes;
mod https;
mod natmap;
mod op;
mod rest_client;
pub mod sync_client;
mod uri_tools;

pub use async_client::{HdfsClient, HdfsClientBuilder};
pub use datatypes::*;
pub use error::{Error, Result};
pub use http::Uri;
pub use natmap::NatMap;
pub use op::*;
pub use sync_client::{SyncHdfsClient, SyncHdfsClientBuilder};
