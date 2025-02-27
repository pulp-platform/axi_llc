# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## 0.2.2 - 2025-02-27

### Changed
- Bump dependencies, fix CI. [#16](https://github.com/pulp-platform/axi_llc/pull/16)

### Fixed
- Fix implicit cast of enum-type for Verilator. [#18](https://github.com/pulp-platform/axi_llc/pull/18)
- Fix transition from LLC to SPM. [#21](https://github.com/pulp-platform/axi_llc/pull/21)


## 0.2.1 - 2023-03-29

### Added
- Add a BIST status register. [#6](https://github.com/pulp-platform/axi_llc/pull/6)
- Add parameters to control config prints. [#7](https://github.com/pulp-platform/axi_llc/pull/7)

## 0.2.0 - 2022-11-21

### Changed
- Separate config registers from the LLC implementation. Add a top level, `axi_llc_reg_wrap`,
  containing a *default* configuration register file. [#5](https://github.com/pulp-platform/axi_llc/pull/5).
  This addresses [#2](https://github.com/pulp-platform/axi_llc/issues/2).
- Update AXI dependency from `0.37.0` to `0.39.0-beta.2` fixing [#3](https://github.com/pulp-platform/axi_llc/issues/3).
- Various fixes to ci

## 0.1.0 - 2022-09-01

### Added
- Add initial version of the AXI Last-level Cache (LLC).
