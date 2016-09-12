# Rspec::GraphqlMatchers

Convenient rspec matchers for testing your (GraphQL)[https://github.com/rmosolgo/graphql-ruby] API/Schema.

## Installation

```
gem 'rspec-graphql_matchers'
```

## Usage

The two matchers currently supported are:
   - be_of_type(a_graphql_type_identifier)
   - accept_arguments(hash_of_arg_names_and_type_identifiers)

Where a type identifier is either:
   - A GraphQL type object (ex: `types.String`, `!types.Int`, `types[types.Int]`)
   - A String representation of a type: `"String!"`, `"Int!"`, `"[String]!"`

## Examples

Given a GraphQL type defined as such

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

### 1) Test the field types with `be_of_type` matcher:

```ruby
describe PostType do
  describe 'id' do
    subject { PostType.fields['id'] }

    # These will match
    it { is_expected.to be_of_type('ID!') }

    # While 'Float!' will not match
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
hardcoded the type name as a String.

You can also use the built-in GraphQL scalar types:


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
(for example in your `spec_helper.rb`, but not within a `RSpec.configure` block)
and the `types` shortcut will be available globally (ouch!) for your tests.
Use at your own risk.

### 2) Test the arguments accepted by a field with `accept_arguments` matcher:

Testing arguments use the `accept_arguments` matcher passing a hash where
keys represent the attribute name and values respresent the attribute type.

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
The spec will pass only if all attributes/types specified in the hash are
defined on the field. Type specification follows the same rules from
`be_of_type` matcher.

For better fluency, `accept_arguments` is always available in singular form, as
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

