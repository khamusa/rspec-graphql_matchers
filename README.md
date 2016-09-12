# Rspec::GraphqlMatchers

Convenient rspec matchers for testing your [graphql-ruby](https://github.com/rmosolgo/graphql-ruby) API/Schema.

## Installation

```
gem 'rspec-graphql_matchers'
```

## Usage

The matchers currently supported are:
   - `expect(graphql_type).to have_a_field(field_name).that_returns(valid_type)`
   - `expect(graphql_field).to be_of_type(valid_type)`
   - `expect(graphql_field).to accept_arguments(hash_of_arg_names_and_valid_types)`

Where a valid type for the expectation is either:
   - A `GraphQL::ObjectType` object (ex: `types.String`, `!types.Int`, `types[types.Int]`, or your own)
   - A String representation of a type: `"String!"`, `"Int!"`, `"[String]!"`
   (note the exclamation mark at the end, as required by the [GraphQL specs](http://graphql.org/).

## Examples

Given a `GraphQL::ObjectType` defined as

```ruby

PostType = GraphQL::ObjectType.define do
  name "Post"
  description "A blog post"

  field :id, !types.ID

  field :comments, !types[types.String]

  field :subposts, PostType do
    type !PostType

    argument :filter, types.String
    argument :id, types.ID
  end
end
```

### 1) Test your type defines the correct fields:

```ruby
describe PostType do
  it 'defines a field id of type ID!' do
    expect(subject).to have_field(:id).that_returns(!types.ID)
  end

  # Fluent alternatives
  it { is_expected.to have_field(:id).of_type("ID!") }
  it { is_expected.to have_a_field(:id).returning("ID!") }
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

    # You can use your type object directly when building expectations
    it 'has type PostType' do
      expect(subject).to be_of_type(!PostType)
    end

    # Or as usual, a literal String
    it { is_expected.to be_of_type('Post!') }
  end
end
```

Keep in mind that when using strings as type expectation you have to use the
type name (`Post`) and not the constant name (`PostType`).

Using your type objects directly has the advantage that if you
decide to rename the type your specs won't break, as they would had you
hardcoded it as a String.

You can also use the built-in [graphql-ruby](https://github.com/rmosolgo/graphql-ruby) scalar types:

```ruby
# ensure you have the GraphQL type definer available in your tests
types = GraphQL::Define::TypeDefiner.instance

describe PostType do
  describe 'comments' do
    subject { PostType.fields['comments'] }
    it { is_expected.to be_of_type(!types[types.String]) }
    it { is_expected.to be_of_type('[String]!') }
  end
end
```

Having to define `types` everywhere is quite annoying. If you prefer, you can
just `include RSpec::GraphqlMatchers::TypesHelper` once 
(for example in your `spec_helper.rb`)
and the `types` shortcut will be available within the include context.

### 3) Test the arguments accepted by a field with `accept_arguments` matcher:

```ruby
describe PostType do
  describe 'subposts' do
    subject { PostType.fields['subposts'] }

    let(:a_whole_bunch_of_args) do
      { filter: 'String', id: types.Int, pippo: 'Float', posts: PostType }
    end

    it 'accepts a filter and an id argument, of types String and ID' do
      expect(subject).to accept_arguments(filter: types.String, id: types.ID)
    end

    # You can also test if a field does not accept args. Not quite useful :D.
    it { is_expected.not_to accept_arguments(a_whole_bunch_of_args) }
  end
end
```

The spec will only pass if all attributes/types specified in the hash are
defined on the field.

For better fluency, `accept_arguments` is also available in singular form, as
`accept_argument`.

## TODO

  - Setup CI and integrate w/codeclimate
  - Setup codeclimate / CI badges
  - New matchers!

## Contributing

  - Send Bug reports, suggestions or any general
    question through the [Issue tracker](https://github.com/khamusa/rspec-graphql_matchers/issues).
    Think of another matcher that could be useful? This is the place to ask, or...
  - Pull requests are welcome through the usual procedure: fork the project,
    commit your changes and open the [PR](https://github.com/khamusa/rspec-graphql_matchers/pulls).

This project is intended to be a safe, welcoming space for collaboration, and
contributors are expected to adhere to the
[Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the 
[MIT License](http://opensource.org/licenses/MIT).

