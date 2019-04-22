# frozen_string_literal: true

group :red_green_refactor, halt_on_fail: true do
  guard :rspec, all_on_start: true, cmd: 'bundle exec rspec', failed_mode: :focus do
    watch('spec/spec_helper.rb') { 'spec' }
    watch(%r{^spec/.+_spec\.rb$})
  end

  guard :rubocop do
    watch('Gemfile')
    watch('Guardfile')
    watch(%r{.+\.rb$})
    watch(%r{(?:.+/)?\.rubocop(?:_todo)?\.yml$}) { |m| File.dirname(m[0]) }
  end
end
