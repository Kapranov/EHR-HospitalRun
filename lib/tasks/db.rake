namespace :db do
  desc 'Clean up the tables to DB'
  task clean: :environment do
    # User.destroy_all
    exceptions = STATIC_TABLES_LIST # static tables
    exceptions += ['cals', 'gms', 'mgls', 'pds'] # this models saves in tooth_fields table
    tables = Dir.glob("#{Rails.root}/app/models/*.rb")
                .map{ |path| File.basename(path).gsub('.rb', '').pluralize }
                .reject{ |model| exceptions.include?(model) }
    tables.each do |table|
      NoBrainer.run do |r|
        r.table_drop(table)
      end
      puts "Table #{table} dropped" if Rails.env.test?
    end
    puts "Clean database.\n"
  end

  desc 'Upload loinc codes'
  task upload_loinc: :environment do
    loinc_dump_file = 'loincs.json'
    NoBrainer.run{ |r| r.table_drop('loincs') }
    loincs = JSON.parse(File.read(loinc_dump_file))
    Loinc.insert_all(loincs)
    puts "Loinc uploaded.\n"
  end

  # desc 'Upload icd-10 to DiagnosisCodes'
  # task upload_icd: :environment do
  #   DiagnosisCode.insert_all([
  #     {code: 'K02.3',  description: 'Arrested dental caries'},
  #     {code: 'K02.51', description: 'Dental caries on pit and fissure surface limited to enamel'},
  #     {code: 'K02.52', description: 'Dental caries on pit and fissure surface penetrating into dentin'},
  #     {code: 'K02.53', description: 'Dental caries on pit and fissure surface penetrating into pulp'},
  #     {code: 'K02.61', description: 'Dental caries on smooth surface limited to enamel'},
  #     {code: 'K02.62', description: 'Dental caries on smooth surface penetrating into dentin'},
  #     {code: 'K02.63', description: 'Dental caries on smooth surface penetrating into pulp'},
  #     {code: 'K02.7',  description: 'Dental root caries'},
  #     {code: 'K02.9',  description: 'Dental caries, unspecified'}])
  # end
end
