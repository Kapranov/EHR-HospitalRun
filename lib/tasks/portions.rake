namespace :db do
  desc "Create Portion Model"
  task portions: :environment do

    Portion.destroy_all

    20.times do |nested|
      Portion.create(drug: FFaker::Lorem.word, dose: FFaker::Lorem.word, instruction: FFaker::Lorem.word)
    end

    message = "==== Portions Created: 20 Portions ====\r"
    print "\n"
    print message
    $stdout.flush
    sleep 1
  end
end
