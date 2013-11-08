#!/usr/bin/env ruby
# Ruby script to create temporary duplicates of smart answers.
# These are used to allow testing and fact checking on preview
# but will not be served on live (due to the status of draft).

# Usage:
#  create-v2.rb smart-answer-name --diff [base-sha1]
#  base-sha1 is the revision or branch name of the v1 where no changes to
#  either have been made (usually just before the v2 was copied out)

def v2file(source, dest, &block)
  content = File.read(source)
  File.open(dest, "w") do |file|
    update = block.call(content)
    file << update
  end
  puts "Created: #{dest}"
end

def setup_filenames(answer_name)
  snake_name = answer_name.gsub("-", "_")
  [
    {
      name: 'rb',
      original: "lib/flows/#{answer_name}.rb",
      v2: "lib/flows/#{answer_name}-v2.rb"
    },
    {
      name: 'yml',
      original: "lib/flows/locales/en/#{answer_name}.yml",
      v2: "lib/flows/locales/en/#{answer_name}-v2.yml"
    },
    {
      name: 'test',
      original: "test/integration/flows/#{snake_name}_test.rb",
      v2: "test/integration/flows/#{snake_name}_v2_test.rb"
    },
    {
      name: 'calc',
      original: "lib/smart_answer/calculators/#{snake_name}.rb",
      v2: "lib/smart_answer/calculators/#{snake_name}_v2.rb"
    }
  ]
end

def createv2(answer_name)
  files = setup_filenames answer_name

  class_name = answer_name.split("-").map(&:capitalize).join

  bail = false
  files.each do |file|
    if File::exists?(file[:v2])
      puts "v2 file already exists #{file[:v2]}"
      bail = true
    end
  end
  exit 1 if bail
  files.each do |file|
    if File::exists?(file[:original])
      v2file file[:original], file[:v2] do |content|
        case file[:name]
        when 'rb'
          content.gsub(/^status \:published$/, 'status :draft')
        when 'yml'
          content.gsub(/#{answer_name}/, "#{answer_name}-v2")
        when 'test'
          content.gsub(/#{answer_name}/, "#{answer_name}-v2")
            .gsub(/#{class_name}/, "#{class_name}V2")
        else
          throw "Unexpected file[:name] value '#{file[:name]}'"
        end
      end
    else
      puts "Skipped unused: #{file[:original]}"
    end
  end
end

def diffv2(answer_name, base)
  files = setup_filenames answer_name

  files.each do |file|
    if File::exists?(file[:v2])
      if base
        base_file="#{file[:original]}.base~"
        system("git show \"#{base}:#{file[:original]}\" > \"#{base_file}\"")
      end
      diff file[:original], file[:v2], base_file
    else
      puts "No v2 found at #{file[:v2]}"
    end
  end
end

def diff(file1, file2, base)
  if base
    command = "kdiff3 #{file1} #{file2} --base #{base} &"
  else
    command = "kdiff3 #{file1} #{file2} &"
  end
  run command
end

def run(command)
  p command
  system(command)
end

answer_name = ARGV[0]
raise "answer name missing from arguments" unless answer_name

if ARGV[1] == "--diff"
  base = ARGV[2]
  diffv2 answer_name, base
else
  createv2 answer_name
end

