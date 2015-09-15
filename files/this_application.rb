#! /usr/bin/env ruby

require 'sinatra'
require 'pg'
require 'open-uri'

# Get connection to postgres
conn = PG.connect( dbname: 'demo', user: 'demo', host: 'localhost' )

# Serve index page
get '/' do
  erb :index
end

# SQL injection demo
get '/sql' do
  # Get message from params
  query = params['query']
  message = "SQL query was \"#{query};\"" unless query.nil?

  # Userinfo array, is an array of hashes
  userinfo = []

  begin
    # Select all users, build userinfo array
    conn.exec("SELECT * FROM users ORDER BY name;") do |result|
      result.each_row do |row|
        userinfo << row
      end
    end
  rescue PG::UndefinedTable
    return [500, "ERROR: Table does not exist! (500)."]
  end

  # Render template, with userinfo provided
  erb :sql, :locals => { userinfo: userinfo , message: message}
end

post '/sql' do
  # Get username from parameters
  name = params['user']

  # Create query
  query =  "UPDATE users SET admin=TRUE WHERE name='#{name}';"

  # Set the user to an administrator
  conn.exec(query)
  
  # Redirect back to the GET page, with query passed as message
  redirect "/sql?query=#{URI::encode(query)}"
end

# Path injection demo
get '/path' do
  # Set file
  file = params['file']

  contents = ""

  begin
    # Read file contents (if file provided)
    contents = IO.read("files/#{file}") unless file.nil?
  rescue Errno::ENOENT
    return [404, "ERROR: File does not exist (404)"]
  end

  # HTML-Escape contents
  contents = Rack::Utils.escape_html(contents)

  # Get list of files in the 'files' directory
  files = Dir.entries('files')

  # Remove . and ..
  files.delete_at(0)
  files.delete_at(0)

  # Render template
  erb :path, :locals => { files: files , file: file, contents: contents}
end
