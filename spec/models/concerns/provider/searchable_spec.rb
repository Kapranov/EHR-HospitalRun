shared_examples 'an instance searchable' do
  describe 'creates simple collection' do
    let!(:provider) { create :provider, user_id: nil }
    let!(:patient1) { create :patient,  user_id: nil, provider_id: provider.id, first_name: 'Andrew', last_name: 'Smith' }
    let!(:patient2) { create :patient,  user_id: nil, provider_id: provider.id, first_name: 'Zack',   last_name: 'Smith' }

    it { expect(provider).to respond_to(:find_patients_by) }
    it { expect(provider).to respond_to(:patients_first) }
    it { expect(provider.find_patients_by('And').to_a).to     include patient1 }
    it { expect(provider.find_patients_by('And').to_a).to_not include patient2 }
    it { expect(provider.patients_first(10).to_a).to          match_array [patient1, patient2] }
  end
end

# Due to I don't know how to stub returning NoBrainer::Criteria
# this module tests #seacrh in models/provider_spec
# and #self_seacrh in models/diagnosis_codes_spec # does not exist yet
