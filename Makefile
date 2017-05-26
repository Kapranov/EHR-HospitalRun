V ?= @
LOCALHOST := 'localhost'
PORT := '8000'
MAILER_PORT := '1080'
IP := '127.0.0.1'
RETHINKDB_PASSWORD := './rethinkdb_password'
RUBYSERVICE := $(shell pgrep ruby)
NGINXSERVICE := $(shell pgrep nginx)
UNICORNSERVICE := $(shell pgrep unicorn)
THINSERVICE := $(shell pgrep thin)
#START_THIN := $(shell RAILS_ENV=production bundle exec rackup config.ru -E production)
#START_THIN := $(shell thin -R config.ru -a 127.0.0.1 -p 8000 start -e production)
#START_THIN := $(shell thin start -C config/thin.yml)
VERSION := '1.6.1'
LOCALSERVER := 'http://127.0.0.1:8000'
ENV_DEVELOPMENT := 'development'
ENV_PRODUCTION := 'production'
ENV_TEST := 'test'

default:
	$(V)echo Please use \'make help\' or \'make ..any_parameters..\'

tag:
	$(V)git tag -d $(VERSION) 2>&1 > /dev/null
	$(V)git tag -d latest 2>&1 > /dev/null
	$(V)git tag $(VERSION)
	$(V)git tag latest

#push:
# $(V)git push --tags origin master -f

doc: clean build
	$(V)rake doc:app

help:
	$(V)clear
	$(V)echo "\n\n\t Manual Makefile to start of the project:\n\n make bundle    - installing libraries\n make clean     - clean temporary files\n make rethinkdb - generating fake data\n make processes - ways to kill a process\n\n Full information to usage Makefile bash> make help\n"

kill_ruby:
	$(V)echo "\nChecking to see if RUBY process exists:\n"
	$(V)if [ "$(RUBYSERVICE)" ]; then killall ruby && echo "Running Ruby Service Killed"; else echo "No Running Ruby Service!"; fi

processes:
	$(V)ps aux | grep 'ruby' | awk '{print $2}' | xargs kill -9

nginx: kill_ruby
	$(V)echo "\nChecking to see if Nginx process exists:\n"
	$(V)if [ "$(NGINXSERVICE)" ]; then service nginx stop && echo "Running Nginx Service Killed"; else echo "No Running Nginx Service!"; fi
	$(V)echo "\nChecking to see if Unicorn process exists:\n"
	$(V)if [ "$(UNICORNSERVICE)" ]; then ps aux | grep 'unicorn' | awk '{print $2}' | xargs kill -9 && echo "Running Unicorn Service Killed"; else echo "No Running Unicorn Service!"; fi

bundle:
	$(V)bundle

clean:
	$(V)rm -rf ./.bundle
	$(V)rm -rf ./tmp/*
	$(V)rm -rf ./vendor/bundle/
	$(V)rm -rf ./public/assets/
	$(V)rm -rf ./Gemfile.lock
	$(V)rm -f  ./app/services/*

clear_bundle:
	$(V)bundle exec rake tmp:clear
	$(V)bundle exec rake log:clear
	$(V)bundle exec rake assets:clean

clear_bundle_production:
	$(V)bundle exec rake tmp:clear 			RAILS_ENV=$(ENV_PRODUCTION)
	$(V)bundle exec rake log:clear 			RAILS_ENV=$(ENV_PRODUCTION)
	$(V)bundle exec rake assets:clean 	RAILS_ENV=$(ENV_PRODUCTION)

env_dev:
	$(V)cp ./.env_development ./.env

env_test:
	$(V)cp ./.env_test ./.env

env_prod:
	$(V)cp ./.env_production ./.env

services:
	$(V)cp -v ./lib/tasks/admin_service.rb 		./app/services/
	$(V)cp -v ./lib/tasks/provider_service.rb ./app/services/
	$(V)cp -v ./lib/tasks/patient_service.rb 	./app/services/
	$(V)cp -v ./lib/tasks/practice_service.rb ./app/services/

yml_kapranov:
	$(V)cp -v ./config/application.yml_kapranov ./config/application.yml

rethinkdb:
	$(V)bundle exec rake db:clean
	$(V)bundle exec rake permission:reload
	$(V)bundle exec rake nobrainer:seed
	$(V)bundle exec rake db:subjects
	$(V)bundle exec rake db:portions

admin:
	$(V)cp -v ./lib/tasks/admin_service.rb ./app/services/

icd10cm_for_development:
	$(V)rethinkdb import -f ./icd10cm_codes_2017.csv --table ehr_development.icd10cm_codes --format csv --force

icd10cm_for_production:
	$(V)rethinkdb import -f ./icd10cm_codes_2017.csv --table ehr_production.icd10cm_codes --format csv --force

codes_for_development:
	$(V)rethinkdb import -f ./diagnosis_codes.csv --table ehr_development.diagnosis_codes --format csv --force

loinc_for_development:
	$(V)rethinkdb import -f ./loincs.json 					--table ehr_development.loincs --force
	$(V)rethinkdb import -f ./loinc_comments.json 	--table ehr_development.loinc_comments --force

loinc_for_production:
	$(V)rethinkdb import -f ./loincs.json 					--table ehr_production.loincs --force
	$(V)rethinkdb import -f ./loinc_comments.json 	--table ehr_production.loinc_comments --force

codes_for_production:
	$(V)rethinkdb import -f ./diagnosis_codes.csv  --table ehr_production.diagnosis_codes --format csv --force

rake_permission_for_development:
	$(V)bundle exec rake permission:reload

rake_permission_for_production:
	$(V)bundle exec rake permission:reload RAILS_ENV=$(ENV_PRODUCTION)

rake_loinc_for_development:
	$(V)bundle exec rake db:upload_loinc

rake_loinc_for_production:
	$(V)bundle exec rake db:upload_loinc RAILS_ENV=$(ENV_PRODUCTION)

db_clean_production:
	$(V)bundle exec rake db:clean 					RAILS_ENV=$(ENV_PRODUCTION)
	$(V)bundle exec rake permission:reload 	RAILS_ENV=$(ENV_PRODUCTION)
	$(V)bundle exec rake nobrainer:seed 		RAILS_ENV=$(ENV_PRODUCTION)
	$(V)bundle exec rake db:subjects 				RAILS_ENV=$(ENV_PRODUCTION)
	$(V)bundle exec rake db:portions 				RAILS_ENV=$(ENV_PRODUCTION)

assets:
	$(V)bundle exec rake assets:precompile 	RAILS_ENV=$(ENV_PRODUCTION)

mailer:
	$(V)mailcatcher --smtp-ip ${IP} --http-ip ${IP}

test: kill_ruby nginx env_test clean bundle yml_kapranov mailer clear_bundle services
	$(V)echo "\n\n\t Start $(ENV_TEST) Enviroment on $(LOCALSERVER)\n\n"
	$(V)foreman start

development: kill_ruby nginx env_dev clean bundle yml_kapranov mailer clear_bundle services rethinkdb codes_for_development loinc_for_development rake_permission_for_development rake_loinc_for_development icd10cm_for_development
	$(V)echo "\n\n\t Start $(ENV_DEVELOPMENT) Enviroment on $(LOCALSERVER)\n\n"
	$(V)foreman start

production: kill_ruby nginx env_prod clean bundle yml_kapranov clear_bundle_production admin rake_permission_for_production icd10cm_for_production
	$(V)bundle install --deployment --without $(ENV_DEVELOPMENT) $(ENV_TEST)
	$(V)bundle exec rake assets:precompile RAILS_ENV=$(ENV_PRODUCTION)
	$(V)echo "\n\n\t Start Production Enviroment on $(LOCALSERVER)\n\n"
	$(V)foreman start

start_dev: kill_ruby nginx env_dev mailer
	$(V)echo "\n\n\t Start $(ENV_DEVELOPMENT) Enviroment on $(LOCALSERVER)\n\n"
	$(V)foreman start

start_test: kill_ruby nginx env_test mailer
	$(V)echo "\n\n\t Start $(ENV_TEST) Enviroment on $(LOCALSERVER)\n\n"
	$(V)foreman start

start_prod: kill_ruby nginx env_prod
	$(V)clear
	$(V)echo "\n\n\t Start $(ENV_PRODUCTION) Enviroment on $(LOCALSERVER)\n\n"
	$(V)foreman start
