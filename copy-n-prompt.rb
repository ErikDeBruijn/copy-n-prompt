#!/usr/bin/env ruby
# frozen_string_literal: true

# <xbar.title>Copy-n-Prompt</xbar.title>
# <xbar.version>v1.0</xbar.version>
# <xbar.author>Erik de Bruijn</xbar.author>
# <xbar.author.github>erikdebruijn</xbar.author.github>
# <xbar.desc>A Swiftbar script to copy text that gets prompted to OpenAI's ChatGPT conversation API. The result is ready for you to paste.</xbar.desc>
# <xbar.dependencies>ruby</xbar.dependencies>
# <xbar.abouturl>https://erikdebruijn.nl/</xbar.abouturl>

require 'yaml'
require 'json'
require 'faraday'
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
  puts "Edit Prompts | bash=nano param1=#{Shellwords.escape(prompts_file)} terminal=true"
  exit(0)
end

api_key = settings['open_ai_api_key']

debug_to_file('Started copy-n-prompt!')

prompts.each_with_index do |prompt, i|
  script_path = Shellwords.escape(File.expand_path(__FILE__))
  image = prompt['image'] || "captions.bubble"
  puts %(#{prompt['name']} | bash=#{script_path} param1=#{i} terminal=false sfimage=#{image})
end

editor = ENV['EDITOR'] || 'nano'
puts '---'
puts "Edit Prompts | bash=#{editor} param1=#{Shellwords.escape(prompts_file)} terminal=true"

puts '---'

def cloud_mode?
  current_mode = File.exist?(File.expand_path("~/.copy-n-prompt/mode")) ? File.read(File.expand_path("~/.copy-n-prompt/mode")).strip : "Cloud"
  current_mode == "Cloud"
end

puts "Server: #{cloud_mode? ? "Cloud" : "Local"}"
puts "Cloud mode | bash=#{__FILE__} param1=set_mode param2=Cloud terminal=false refresh=True sfimage=#{cloud_mode? ? "checkmark.icloud" : "icloud"}"
puts "Local mode | bash=#{__FILE__} param1=set_mode param2=Local terminal=false refresh=True sfimage=#{cloud_mode? ? "shield" : "checkmark.shield"}"
puts '---'

# ... [rest of your existing code] ...

# Check for mode change argument
if ARGV.length > 1 && ARGV[0] == 'set_mode'
  selected_mode = ARGV[1]
  File.write(File.expand_path("~/.copy-n-prompt/mode"), selected_mode)
  exit(0)
end

if ARGV.length.positive?
  begin
    prompt_index = ARGV[0].to_i
    prompt_text = prompts[prompt_index]
  rescue StandardError
    puts "Invalid index"
    exit(1)
  end

  clipboard_content = `pbpaste`

  payload = {
    "model" => "gpt-4",
    "messages" => [
      {
        "role" => "system",
        "content" => prompt_text["prompt"]
      },
      {
        "role" => "user",
        "content" => clipboard_content.strip
      }
    "temperature" => 0.0,
    "max_tokens" => 1000
  }

  server_host = if cloud_mode?
                  (settings["open_ai_host"] || "http://localhost:1234")
                else
                  (settings["open_ai_host_local"] || "http://localhost:1234")
                end

  conn = Faraday.new(
    url: server_host,
    headers: {
      "Content-Type" => "application/json",
      "Authorization" => "Bearer #{api_key}"
    }
  )

  begin
    response = conn.post do |req|
      req.url '/v1/chat/completions'
      req.body = payload.to_json
      req.options.timeout = 120  # open/read timeout in seconds
    end
  rescue Faraday::TimeoutError
    puts 'Read timeout occurred'
    exit(1)
  end

  debug_to_file("gpt_response: #{response.body}")

  gpt_response = JSON.parse(response.body)['choices'][0]['message']['content'].strip.force_encoding('UTF-8')

  IO.popen('/usr/bin/pbcopy', 'w') { |f| f.puts gpt_response }

  unless prompt_text['alert'] == false
    system("afplay /System/Library/Sounds/Glass.aiff")
  end
end
