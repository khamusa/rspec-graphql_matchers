require 'spec_helper'
require 'pry'
require 'graphql'

describe 'The readme Examples' do
  ruby_code_regex = /```ruby(.*?)```/m
  readme_content = File.read(
    File.expand_path(
    '../../../README.md',
    __FILE__)
  )

  types = GraphQL::Define::TypeDefiner.instance
  matches = readme_content.scan(ruby_code_regex) do |ruby_code|
    eval(ruby_code[0])
  end
end
