guard 'rake', :task => 'erb' do
    watch(%r{^.+.erb$})
end

guard 'rake', :task => 'all' do
    watch(%r{controller.rb|Rakefile})
end

guard 'sass', :input => 'stylesheets', :compass => true

guard 'livereload' do
    watch(%r{.+\.(css|js|html)})
end