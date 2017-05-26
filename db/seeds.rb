if Rails.env.development?
  AdminService.create
  puts "CREATED USER: Admin, #{Rails.application.secrets.admin_email}"

  ProviderService.create
  puts "CREATED USER: Provider, #{Rails.application.secrets.ehr_provider_email}"

  PatientService.create
  puts "CREATED USER: Patient, #{Rails.application.secrets.ehr_patient_email}"

  PracticeService.create
  puts "CREATED USER: Practice"

  AppSetting.create(version: '1.6.1')
end

if Rails.env.test?
  AdminService.create
  puts "CREATED USER: Admin, #{Rails.application.secrets.admin_email}"

  ProviderService.create
  puts "CREATED USER: Provider, #{Rails.application.secrets.ehr_provider_email}"

  PatientService.create
  puts "CREATED USER: Patient, #{Rails.application.secrets.ehr_patient_email}"

  PracticeService.create
  puts "CREATED USER: Practice, #{Rails.application.secrets.ehr_practice_email}"

  AppSetting.create(version: '1.4')
end

if Rails.env.production?
  AdminService.create
  puts "CREATED USER: Admin, #{Rails.application.secrets.admin_email}"

  AppSetting.create(version: '1.6.1')
end
