![RSpec Status](https://github.com/khamusa/rspec-graphql_matchers/actions/workflows/rspec.yml/badge.svg)

# Rspec::GraphqlMatchers

Convenient rspec matchers for testing your [graphql-ruby](https://github.com/rmosolgo/graphql-ruby) API/Schema.

## Installation

```
gem 'rspec-graphql_matchers'
```

## Usage

The matchers currently supported are:

-   `expect(a_graphql_object).to have_a_field(field_name).of_type(valid_type)`
-   `expect(a_graphql_object).to implement(interface_name, ...)`
-   `expect(a_mutation_type).to have_a_return_field(field_name).returning(valid_type)`
-   `expect(a_mutation_type).to have_an_input_field(field_name).of_type(valid_type)`
-   `expect(a_field).to be_of_type(valid_type)`
-   `expect(an_input).to accept_argument(argument_name).of_type(valid_type)`

Where a valid type for the expectation is either:

-   A reference to the actual type you expect;
-   [Recommended] A String representation of a type: `"String!"`, `"Int!"`, `"[String]!"`
    (note the exclamation mark at the end, as required by the [GraphQL specs](http://graphql.org/).

For objects defined with the legacy `#define` api, testing `:property`, `:hash_key` and _metadata_ is also possible by chaining `.with_property`, `.with_hash_key` and `.with_metadata`. For example:

-   `expect(a_graphql_object).to have_a_field(field_name).with_property(property_name).with_metadata(metadata_hash)`
-   `expect(a_graphql_object).to have_a_field(field_name).with_hash_key(hash_key)`

## Examples

Given a GraphQL object defined as

```ruby
class PostType < GraphQL::Schema::Object
  graphql_name "Post"
  description "A blog post"

  implements GraphQL::Relay::Node.interface

  field :id, ID, null: false
  field :comments, [String], null: false
  field :isPublished, Boolean, null: true
  field :published, Boolean, null: false, deprecation_reason: 'Use isPublished instead'

  field :subposts, PostType, null: true do
    argument :filter, types.String, required: false
    argument :id, types.ID, required: false
    argument :isPublished, types.Boolean, required: false
  end
end
```

### 1) Test your type defines the correct fields:

```ruby
describe PostType do
  subject { described_class }

  it { is_expected.to have_field(:id).of_type(!types.ID) }
  it { is_expected.to have_field(:comments).of_type("[String!]!") }
  it { is_expected.to have_field(:isPublished).of_type("Boolean") }

  # Check a field is deprecated
  it { is_expected.to have_field(:published).with_deprecation_reason }
  it { is_expected.to have_field(:published).with_deprecation_reason('Use isPublished instead') }
  it { is_expected.not_to have_field(:published).with_deprecation_reason('Wrong reason') }
  it { is_expected.not_to have_field(:isPublished).with_deprecation_reason }

  # The gem automatically converts field names to CamelCase, so this will
  # pass even though the field was defined as field :isPublished
  it { is_expected.to have_field(:is_published).of_type("Boolean") }
end
```

### 2) Test a specific field type with `be_of_type` matcher:

```ruby
describe PostType do
  describe 'id' do
    subject { PostType.fields['id'] }

    it { is_expected.to be_of_type('ID!') }
    it { is_expected.not_to be_of_type('Float!') }
  end

  describe 'subposts' do
    subject { PostType.fields['subposts'] }

    it { is_expected.to be_of_type('Post') }
  end
end
```

### 3) For objects defined using the legacy `#define` api, you can also use `with_property`, `with_hash_key` and `with_metadata`:

```ruby
PostTypeWithDefineApi = GraphQL::ObjectType.define do
  name "DefinedPost"

  interfaces [GraphQL::Relay::Node.interface]

  field :id, !types.ID, property: :post_id
  field :comments, !types[types.String], hash_key: :post_comments
  field :isPublished, admin_only: true
end

describe PostTypeWithDefineApi do
  it { is_expected.to have_a_field(:id).of_type('ID!').with_property(:post_id) }
  it { is_expected.to have_a_field(:comments).with_hash_key(:post_comments) }
  it { is_expected.to have_a_field(:isPublished).with_metadata(admin_only: true) }
end
```

### 4) Test the arguments accepted by a field with `accept_argument` matcher:

```ruby
describe PostType do
  describe 'subposts' do
    subject { PostType.fields['subposts'] }

    it 'accepts a filter and an id argument, of types String and ID' do
      expect(subject).to accept_argument(:filter).of_type('String')
      expect(subject).to accept_argument(:id).of_type('ID')
    end

    it { is_expected.not_to accept_argument(:weirdo) }

    # The gem automatically converts argument names to CamelCase, so this will
    # pass even though the argument was defined as :isPublished
    it { is_expected.to accept_argument(:is_published).of_type("Boolean") }
  end
end
```

### 5) Test an object's interface implementations:

```ruby
describe PostType do
  subject { described_class }

  it 'implements interface Node' do
    expect(subject).to implement('Node')
  end

  # Accepts arguments as an array and type objects directly
  it { is_expected.to implement(GraphQL::Relay::Node.interface) }
  it { is_expected.not_to implement('OtherInterface') }
end
```

### 6) Using camelize: false on field names

By default the graphql gem camelizes field names. This gem deals with it transparently:

```ruby
class ObjectMessingWithCamelsAndSnakesType < GraphQL::Schema::Object
  graphql_name 'ObjectMessingWithCamelsAndSnakes'

  implements GraphQL::Relay::Node.interface

  field :me_gusta_los_camellos, ID, null: false

  # note the camelize: false
  field :prefiero_serpientes, ID, null: false, camelize: false
end
```

The following specs demonstrate the current behavior of the gem regarding fields:

```ruby
describe ObjectMessingWithCamelsAndSnakesType do
  subject { described_class }

  # For a field name that was automatically camelized, you can add expectations
  # against both versions and we handle it transparently:
  it { is_expected.to have_a_field(:meGustaLosCamellos) }
  it { is_expected.to have_a_field(:me_gusta_los_camellos) }

  # However, when using camelize: false, you have to use the exact case of the field definition:
  it { is_expected.to have_a_field(:prefiero_serpientes) }
  it { is_expected.not_to have_a_field(:prefieroSerpientes) } # Note we're using `not_to`
end
```

This behaviour is currently active only on field name matching. PRs are welcome to
reproduce it to arguments as well.

## TODO

-   New matchers!

## Contributing

-   Send Bug reports, suggestions or any general
    question through the [Issue tracker](https://github.com/khamusa/rspec-graphql_matchers/issues).
    Think of another matcher that could be useful? This is the place to ask, or...
-   Pull requests are welcome through the usual procedure: fork the project,
    commit your changes and open the [PR](https://github.com/khamusa/rspec-graphql_matchers/pulls).

This project is intended to be a safe, welcoming space for collaboration, and
contributors are expected to adhere to the
[Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the
[MIT License](http://opensource.org/licenses/MIT).
