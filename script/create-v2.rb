#!/usr/bin/env ruby
# ruby script create temporary duplicates of smart answers
# These are used to allow testing and fact checking on preview
# but will not be served on live (due to the status of draft)

# usage: ruby scripts/create-v2.rb smart-answer-name

require 'fileutils'

answer_name = ARGV[0]
raise "answer name missing from arguments" unless answer_name

FileUtils.cp("lib/flows/#{answer_name}.rb", "lib/flows/#{answer_name}-v2.rb")
