use std::collections::HashMap;
use std::ffi::CString;
use std::os::raw::{c_char};
use std::ptr;

extern "C" {
    fn execv(path: *const c_char, argv: *const *const c_char) -> i32;
}

const USAGE: &str =
r#"cmdfmt <cmd> [key=value]...

Formats a cmd string by replacing placeholders with values.
The resulting command is finally executed using execv.

Arguments:
  <cmd>            A string with placeholders like {key} to format.
  [key=value]...   One or more key-value pairs used for substitution.

Example:
  cmdfmt "code -g {path}:{line}:{char}" char=11 line=13 path=main.c

  Will execute: code -g main.c:13:11"#;

fn usage<T>() -> T {
    let argv = std::env::args();
    eprintln!("\x1b[38;5;1mReceived invalid arguments\x1b[0m\n  {}\n", argv.collect::<Vec<_>>().join(" "));
    eprintln!("Usage: {}", USAGE);
    std::process::exit(1);
}

fn exit_err(msg: impl Into<String>) -> ! {
    eprintln!("{}", msg.into());
    std::process::exit(1);
}

fn main() {
    let mut argv = std::env::args();

    argv.next(); // Ignore self
    let cmd = argv.next().unwrap_or_else(usage);
    let mut input_kv_map = HashMap::with_capacity(4);

    for kv in argv {
        let separator_idx = kv.find("=").unwrap_or_else(usage);
        let key = &kv[..separator_idx];
        let value = &kv[separator_idx+1..];
        input_kv_map.insert(key.to_string(), value.to_string());
    }

    let mut formatted_cmd = String::with_capacity(cmd.len() * 2);
    let mut chars_iter = cmd.chars();

    while let Some(c) = chars_iter.next() {
        if c != '{' {
            formatted_cmd.push(c);
            continue;
        }

        let mut found_key = String::with_capacity(16);
        let mut key_closed = false;

        while let Some(cv) = chars_iter.next() {
            if cv != '}' {
                found_key.push(cv);
            } else {
                key_closed = true;
                break;
            }
        }

        if !key_closed {
            exit_err(format!("Unclosed key {} in command: {}", found_key, cmd));
        }

        match input_kv_map.get(&found_key) {
            Some(to_replace) => {
                formatted_cmd.push_str(to_replace);
            },
            None => panic!("Key not found: {}", found_key),
        };
    }

    // We open the command using execv

    let mut cmd_parts_iter = formatted_cmd.split_whitespace().peekable();

    let cmd_program = CString::new(*cmd_parts_iter.peek().unwrap()).unwrap();

    let mut cmd_args: Vec<*const c_char> = cmd_parts_iter
        .map(|p| {
            let cstr = CString::new(p).unwrap();
            let ptr = cstr.as_ptr();
            std::mem::forget(cstr);
            ptr
        })
        .collect();

    cmd_args.push(ptr::null()); // execv expects a null-terminated array of args
    cmd_args.shrink_to_fit();

    unsafe {
        execv(cmd_program.as_ptr(), cmd_args.as_ptr());
    }
}
