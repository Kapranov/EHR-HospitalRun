#!/usr/bin/python

import rethinkdb as r

r.connect( "localhost", 28015).repl()
r.db("ehr_development").config().update({"name": "ehr_production"}).run()
