#!/usr/bin/env ruby
# Ruby script to create temporary duplicates of smart answers.
# These are used to allow testing and fact checking on preview
# but will not be served on live (due to the status of draft).

# usage: ruby scripts/create-v2.rb smart-answer-name

def v2file(source, dest, &block)
  content = File.read(source)
  File.open(dest, "w") do |file|
    update = block.call(content)
    file << update
  end
end

def setup_filenames(answer_name)
  @rb_file_original = "lib/flows/#{answer_name}.rb"
  @rb_file_v2 = "lib/flows/#{answer_name}-v2.rb"

  @yml_file_original = "lib/flows/locales/en/#{answer_name}.yml"
  @yml_file_v2 = "lib/flows/locales/en/#{answer_name}-v2.yml"

  snake_name = answer_name.gsub("-", "_")
  @test_file_original = "test/integration/flows/#{snake_name}_test.rb"
  @test_file_v2 = "test/integration/flows/#{snake_name}_v2_test.rb"

  @calc_file_original = "lib/smart_answer/calculators/#{snake_name}.rb"
  @calc_file_v2 = "lib/smart_answer/calculators/#{snake_name}_v2.rb"
end

def createv2(answer_name)
  setup_filenames answer_name

  class_name = answer_name.split("-").map(&:capitalize).join

  v2file @rb_file_original, @rb_file_v2 do |content|
    content.gsub(/^status \:published$/, 'status :draft')
  end

  v2file @yml_file_original, @yml_file_v2 do |content|
    content.gsub(/#{answer_name}/, "#{answer_name}-v2")
  end

  v2file @test_file_original, @test_file_v2 do |content|
    content.gsub(/#{answer_name}/, "#{answer_name}-v2")
      .gsub(/#{class_name}/, "#{class_name}V2")
  end
end

def diffv2(answer_name)
  setup_filenames answer_name
  diff @rb_file_original, @rb_file_v2
  diff @yml_file_original, @yml_file_v2
  diff @test_file_original, @test_file_v2
end

def diff(file1, file2)
  command = "kdiff3 #{file1} #{file2} &"
  p command
  system(command)
end

answer_name = ARGV[0]
raise "answer name missing from arguments" unless answer_name

if ARGV[1] == "--diff"
  diffv2 answer_name
else
  createv2 answer_name
end

