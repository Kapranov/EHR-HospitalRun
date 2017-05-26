namespace :permission do
  desc 'Load new snomed version'
  task reload: :environment do
    PermissionParser.reload
    puts "Reload permissions.\n"
  end
end