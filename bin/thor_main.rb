#!/usr/bin/env ruby
require 'sqlite3'
require 'rubygems'
require 'thor'
require 'highline'

class ThorRubyCli < Thor
  desc "new" ,"new"
  def new
    db_connect
    @db.execute "INSERT INTO Properties(Title) values ('new')"
    prop_id = @db.last_insert_row_id
    cli = HighLine.new
    puts "Starting with new property #{prop_id}."
    title = ask("Title:") { |q| q.validate = /(?!\s*$)/ }
    update_property(prop_id, "Title", title)
    address = ask "Address:"

  end

  desc "continue" ,"continue"
  def continue(prop_id)
    db_connect
    cli = HighLine.new
    property = @db.execute "select * from Properties where id = #{prop_id}"
    property "No properties found." if property.to_a.empty?
    puts "Continuing with property #{property[0]['Id']}"
    prop_type = ask("Property type:", limited_to: ['holiday home', 'apartment', 'private room'])
    update_property(prop_id, "Property_type", prop_type)
    address = cli.ask("Address:") { |q| q.validate = /(?!\s*$)/}
    update_property(prop_id, "Address", address)
    rate = cli.ask("Nightly rate in EUR:", Float)
    update_property(prop_id, "Nightly_rate_in_EUR", rate)
    max_guests = cli.ask("Max guests:", Integer)
    update_property(prop_id, "Max_guests", max_guests)
    email = cli.ask("Email:") { |q| q.validate = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i }
    update_property(prop_id, "Email", email)
    phone_number = cli.ask("Phone number:") { |q| q.validate = /(?!\s*$)/}
    update_property(prop_id, "Phone_number", phone_number)
    puts "Great job! Listing #{property[0]["Id"]} is complete!"
  end

  desc "list" ,"list of properties"
  def list
    db_connect
    props = @db.execute "SELECT * FROM Properties WHERE  Email is not null"
    puts "No properties found." if props.to_a.empty?
    props.each do |prop|
      puts prop#"#{prop['Id']} : #{prop['Title']}"
    end
  end

  private

  def db_connect
    @db = SQLite3::Database.new "test.db"
    @db.results_as_hash = true
    @db.execute "CREATE TABLE IF NOT EXISTS Properties(Id INTEGER PRIMARY KEY AUTOINCREMENT,
    Title TEXT,
    Property_type TEXT,
    Address TEXT,
    Nightly_rate_in_EUR REAL,
    Max_guests INTEGER,
    Email TEXT,
    Phone_number TEXT)"
  end

  def update_property(prop_id, field, value)
    @db.execute "UPDATE Properties
    SET #{field} = '#{value}'
    WHERE Id = #{prop_id}"
  end
end

ThorRubyCli.start