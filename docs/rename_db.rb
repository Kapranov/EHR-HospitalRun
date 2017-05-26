#!/usr/bin/env ruby

require 'rethinkdb'
include RethinkDB::Shortcuts

r.connect(:host=>"localhost", :port=>28015).repl
r.db("ehr_development").config().update({:name => "ehr_production"}).run
