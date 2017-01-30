#!/usr/bin/env ruby
require 'sqlite3'
require 'rubygems'
require 'thor'
require 'highline'
require './property.rb'
require 'securerandom'
def db_connect
  @db = SQLite3::Database.new "test.db"
  @db.results_as_hash = true
  @db.execute "CREATE TABLE IF NOT EXISTS Properties(Id TEXT PRIMARY KEY ,
    Title TEXT,
    Property_type TEXT,
    Address TEXT,
    Nightly_rate_in_EUR REAL,
    Max_guests INTEGER,
    Email TEXT,
    Phone_number TEXT)"
  @db
end

class ThorRubyCli < Thor
  desc "new" ,"new"
  def new
    property = Property.new(id: SecureRandom.hex(10).to_s.upcase!)
    puts "Starting with new property #{property.id}."
    input_params(property)
  end

  desc "continue" ,"continue"
  def continue(prop_id)
    property = Property.find(prop_id)
    puts "Continuing with property #{property.id}"
    input_params(property)
    puts "Great job! Listing #{property.id} is complete!"
  end

  desc "list" ,"list of properties"
  def list
    props = Property.list
    puts "No properties found." if props.to_a.empty?
    props.each do |prop|
      puts "#{prop['Id']} : #{prop['Title']}"
    end
  end

  private

  def input_params(property)
    cli = HighLine.new
    validate_hash = Property.validate_hash
    property.instance_variables.each do |var|
      if property.instance_variable_get(var).nil? || property.instance_variable_get(var).to_s.empty?
        property.instance_variable_set(var, cli.ask(Property.question(var)) { |q| q.validate = validate_hash[var] })
        property.save
      end
    end
  end
end

$db = db_connect
ThorRubyCli.start
