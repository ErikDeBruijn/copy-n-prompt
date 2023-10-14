#!/usr/bin/env ruby
# frozen_string_literal: true
# <swiftbar.hideAbout>true</swiftbar.hideAbout>
# <swiftbar.hideRunInTerminal>true</swiftbar.hideRunInTerminal>
# <swiftbar.hideLastUpdated>true</swiftbar.hideLastUpdated>
# <swiftbar.hideDisablePlugin>true</swiftbar.hideDisablePlugin>
# <swiftbar.hideSwiftBar>true</swiftbar.hideSwiftBar>

require 'yaml'
require 'json'
require 'net/http'
require 'uri'
require 'shellwords'

puts '📋🤖'
puts '---'

def debug_to_file(debug_message, file_path = '/tmp/xbar-gpt.log')
  File.open(file_path, 'a') { |f| f.puts(debug_message) }
end

begin
  settings_file = File.expand_path('~/.copy-n-prompt/.openai.yml')
  settings = YAML.safe_load(File.read(settings_file))
rescue StandardError
  puts "Couldn't open settings file with OpenAI API key."
  exit(0)
end

begin
  prompts_file = File.expand_path('~/.copy-n-prompt/prompts.yml')
  prompts = YAML.safe_load(File.read(prompts_file))
rescue StandardError
  puts 'Prompts YAML not found | color=red'
  puts "Edit Prompts | bash=nano param1=#{prompts_file} terminal=true"
  exit(0)
end

api_key = settings['open_ai_api_key']

debug_to_file('Started copy-n-prompt!')

prompts.each_with_index do |prompt, i|
  script_path = Shellwords.escape(File.expand_path(__FILE__))
  image = prompt['image'] || 'captions.bubble'
  puts %(#{prompt['name']} | bash=#{script_path} param1=#{i} terminal=false sfimage=#{image})
end

editor = ENV['EDITOR'] || 'nano'
puts '---'
puts "Edit Prompts | bash=#{editor} param1=#{prompts_file} terminal=true"

debug_to_file("ARGV.length: #{ARGV.length}")

begin
  if ARGV.length > 0
    prompt_index = ARGV[0].to_i
    prompt_text = prompts[prompt_index]

    debug_to_file("gpt request")

    clipboard_content = `pbpaste`
    uri = URI.parse('https://api.openai.com/v1/chat/completions')
    request = Net::HTTP::Post.new(uri)
    request.content_type = 'application/json'
    request['Authorization'] = "Bearer #{api_key}"
    request.body = JSON.dump({
                               'model' => 'gpt-3.5-turbo',
                               'messages' => [
                                 {
                                   'role' => 'system',
                                   'content' => prompt_text['prompt']
                                 },
                                 {
                                   'role' => 'user',
                                   'content' => clipboard_content.strip
                                 }
                               ],
                               'temperature' => 1,
                               'max_tokens' => 256,
                               'top_p' => 1,
                               'frequency_penalty' => 0,
                               'presence_penalty' => 0
                             })

    req_options = {
      use_ssl: uri.scheme == 'https'
    }

    debug_to_file("gpt request: #{request.body}")

    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end

    debug_to_file("gpt_response: #{response.body}")

    gpt_response = JSON.parse(response.body)['choices'][0]['message']['content'].strip.force_encoding('UTF-8')

    IO.popen('/usr/bin/pbcopy', 'w') { |f| f.puts gpt_response }

    system('afplay /System/Library/Sounds/Glass.aiff') unless prompt_text['alert'] == false
  end
rescue StandardError => e
  debug_to_file("Error: #{e}")
  %x[osascript -e 'display alert "Error" message "Copy-n-pompt raised an error" as warning buttons "OK"']
end
