#!/bin/bash

rustc -C opt-level=z -C lto=yes -C codegen-units=1 -C panic=abort -C strip=debuginfo cmdfmt.rs
mv cmdfmt ~/.scripts/
