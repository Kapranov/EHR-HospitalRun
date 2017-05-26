describe Amendment do
  clean_users

  it { should validate_inclusion_of(:status).in_array(Amendment.statuses) }
  it { should validate_inclusion_of(:source).in_array(Amendment.sources) }

  describe 'checks whether attachments exist' do
    let!(:amendment) { create :amendment, patient_id: nil }

    it 'returns true' do
      create :attachment, amendment_id: amendment.id
      expect(amendment.scanned).to eq true
    end

    it 'returns false' do
      expect(amendment.scanned).to eq false
    end
  end
end
