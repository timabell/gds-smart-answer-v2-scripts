#!/usr/bin/env ruby
# ruby script create temporary duplicates of smart answers
# These are used to allow testing and fact checking on preview
# but will not be served on live (due to the status of draft)

# usage: ruby scripts/create-v2.rb smart-answer-name

def v2file(source, dest, &block)
  content = File.read(source)
  File.open(dest, "w") do |file|
    update = block.call(content)
    file << update
  end
end

answer_name = ARGV[0]
raise "answer name missing from arguments" unless answer_name

rb_file_original = "lib/flows/#{answer_name}.rb"
rb_file_v2 = "lib/flows/#{answer_name}-v2.rb"

yml_file_original = "lib/flows/locales/en/#{answer_name}.yml"
yml_file_v2 = "lib/flows/locales/en/#{answer_name}-v2.yml"

test_name = answer_name.gsub("-", "_")
test_file_original = "test/integration/flows/#{test_name}_test.rb"
test_file_v2 = "test/integration/flows/#{test_name}_v2_test.rb"

v2file rb_file_original, rb_file_v2 do |content|
  content.gsub(/^status \:published$/, 'status :draft')
end

v2file yml_file_original, yml_file_v2 do |content|
  content
end

v2file test_file_original, test_file_v2 do |content|
  content
end

# change class names
