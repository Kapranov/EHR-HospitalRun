class PracticeService
  def self.create
    current_provider = Provider.first

    Provider.practice_roles[1..-1].each do |role|
      user = FactoryGirl.create :user,
                        email: "#{role.to_s.downcase.gsub(' ', '_')}@ehr.com",
                     password: Rails.application.secrets.ehr_practice_password,
        password_confirmation: Rails.application.secrets.ehr_practice_password
      user.confirm

      FactoryGirl.create :provider,
        user_id:        user.id,
        provider_id:    current_provider.id,
        practice_role:  role

      user = FactoryGirl.create :user,
                         role: :Patient,
                     password:  Rails.application.secrets.ehr_practice_password,
        password_confirmation:  Rails.application.secrets.ehr_practice_password,
                     no_email:  true
      user.confirm

      FactoryGirl.create :patient, provider_id: current_provider.id, user_id: user.id
    end


  end
end
