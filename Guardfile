# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard 'rspec', cmd: 'bundle exec rspec' do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^(.+)/(.+)\.rb$})     { |m| "spec/#{m[1]}/#{m[2]}_spec.rb" }
  watch('spec/spec_helper.rb')  { "spec" }
end

guard 'bundler', cmd: 'bundle install' do
  watch('Gemfile')
end
