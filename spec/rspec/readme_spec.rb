# frozen_string_literal: true

require 'spec_helper'

describe 'The readme Examples' do
  ruby_code_regex = /```ruby(.*?)```/m
  readme_content = File.read(
    File.expand_path(
      '../../README.md',
      __dir__
    )
  )

  # rubocop:disable Security/Eval
  readme_content.scan(ruby_code_regex) do |ruby_code|
    eval(ruby_code[0])
  end
  # rubocop:enable Security/Eval
end
