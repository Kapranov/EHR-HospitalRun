namespace :snomed do
  desc 'Load new snomed version'
  task load: :environment do
    puts "\n\nStart load snomed\n"
    secrets = Rails.application.secrets
    db_name = NoBrainer.connection.parsed_uri[:db]

    # Reload XML config
    doc = File.open(Rails.root.to_s + secrets.config_xml_path) { |f| Nokogiri::XML(f) }
    doc.xpath('//outputFolder')[0].inner_html = secrets.snomed_result_json_path
    doc.xpath('//foldersBaselineLoad//folder')[0].inner_html = secrets.snomed_zip_path
    File.open(Rails.root.to_s + secrets.config_xml_path, 'w') { |f| f.print(doc.to_xml) }
    puts "Config is initialized\n"

    # Parse zip to json
    %x(java -Xmx14g -jar #{Rails.root.to_s + secrets.java_parser_path} #{Rails.root.to_s + secrets.config_xml_path})
    puts "Data is parsed to json\n"

    # Upload json to rethink new_database
    %x(rethinkdb import -f #{secrets.snomed_result_json_path}/concepts.json --table #{db_name}.#{secrets.new_snomed_table_name} --force)
    puts "Data is written to database. New database #{secrets.new_snomed_table_name} is created successfully.\n"

    # Remove old database
    NoBrainer.run { |r| r.db(db_name).table_drop(secrets.old_snomed_table_name) }
    puts "Old database #{secrets.old_snomed_table_name} is removed successfully.\n"
  end
end