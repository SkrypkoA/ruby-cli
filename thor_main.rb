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
    property = Property.new(id: SecureRandom.hex(2).to_s)
    cli = HighLine.new
    puts "Starting with new property #{property.id}."
    property.title = cli.ask("Title: ") { |q| q.validate = Property::EMPTY_REGEXP }
    property.save
    property.address = cli.ask("Address: ") { |q| q.validate = Property::EMPTY_REGEXP }
    property.save

  end

  desc "continue" ,"continue"
  def continue(prop_id)
    cli = HighLine.new
    property = Property.find(prop_id)
    validate_hash = Property.validate_hash
    puts "Continuing with property #{property.id}"
    property.instance_variables.each do |var|
      property.instance_variable_set(var, cli.ask(Property.question(var)) { |q| q.validate = validate_hash[var] }) unless var == :@id
      property.save
    end
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
end

$db = db_connect
ThorRubyCli.start
