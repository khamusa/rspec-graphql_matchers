# Changelog

### Breaking changes

### Deprecations

### New features

### Bug fixes

## 1.2 (Feb 6th, 2020)

-   Added support to underscored arguments in have_field (https://github.com/khamusa/rspec-graphql_matchers/pull/29 thanks to @makketagg)

## 1.1 (Sep 19th, 2019)

-   Added graphql-ruby 1.9.x support (thanks to @severin)

## 1.0.1 (June 22th, 2019)

### Bug fixes

-   Fixed issue causing `have_a_field(x).of_type(Y)` to fail on fields defined on implemented interfaces that were defined with legacy syntax.

## 1.0 (June, 2019)

### Breaking changes

-   Support to property and hash_key matchers will be dropped on upcoming releases.

### Deprecations

-   `.with_metadata` and `.with_property` matchers for fields will be removed on the next release;
-   `.accept_arguments` (plural form) will be removed on the next release;
-   `.accept_argument` (singular form) receiving a hash with a single or multiple arguments will no longer be supported, use `accept_argument(name).of_type('MyType')` instead.

### New features

-   Add support for Class-based type definition api (adds support for graphql-ruby v1.8.x). Please note that `.with_metadata` and `.with_property` support has been kept but will only work on fields defined using the legacy api.
-   Implemented `accept_argument(arg_name).of_type('MyType')´ matcher, which returns much clearer error messages when the arguments are not found on the target type.

### Bug fixes

## 0.7.1 (July 27, 2017)

Changelog fixes.

## 0.7.0 (July 27, 2017)

### New features

-   (#3, #8) New chainable matchers `with_property`, `with_hash_key` and `with_metadata` (Thanks to @marcgreenstock).

### Improvements

-   Default Raketask runs rubocop specs as well (Thanks to @marcgreenstock).

## 0.6.0 (July 25, 2017)

### New features

-   (PR #6) New matchers for interfaces: `expect(...).to implement(interface)` (Thanks to @marcgreenstock).

## 0.5.0 (May 10, 2017)

### New features

-   (PR #4) New matchers for mutations: `have_an_input_field` and `have_a_return_field` (Thanks to @aaronklaassen).

## 0.4.0 (Feb, 2017)

### New features

-   Improvements on error messages of have_a_field(...).of_type(...)

### Bug fixes

-   Fixed a bug preventing proper type checking when using matchers in the form have_a_field(fname).of_type(types.X). The bug would not happen when providing the type expectation as a string, only when using the GraphQL constants.

## 0.3.0 (Sep 16, 2016)

### Breaking changes

### Deprecations

### New features

-   New matcher have_field(field_name).of_type(type) for testing types and their fields

### Bug fixes

## 0.2.0 Initial public release

### Breaking changes

### Deprecations

### New features

-   New matcher be_of_type for testing fields
-   New matcher accept_arguments for testing fields

### Bug fixes
