#!/usr/bin/env ruby

require_relative "builders"

app = Star::AppBuilder.build {
  instance_eval(File.read("./Starfile"))
}

puts app.to_json

puts app.models.tasks
