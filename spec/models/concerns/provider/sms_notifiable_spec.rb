shared_examples Provider::SmsNotifiable do
  context 'primary phone exists' do
    it 'notifies admin on create' do
      expect {
        create :provider, user_id: nil
      }.to change { TextMessage.count }
    end

    it 'notifies admin on update' do
      provider = create :provider, user_id: nil
      expect {
        provider.update(id: provider.id)
      }.to change { TextMessage.count }
    end
  end

  context 'primary phone does not exist' do
    it 'does not notify admin on create' do
      expect {
        create :provider_with_blank_phones, user_id: nil
      }.to_not change { TextMessage.count }
    end

    it 'does not notify admin on update' do
      provider = create :provider_with_blank_phones, user_id: nil
      expect {
        provider.update(id: provider.id)
      }.to_not change { TextMessage.count }
    end
  end
end