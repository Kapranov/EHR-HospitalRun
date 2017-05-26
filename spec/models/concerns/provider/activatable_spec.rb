shared_examples Provider::Activatable do
  describe 'activates' do
    let!(:provider) { create :inactive_and_paid_provider }

    it 'sets active as true' do
      expect {
        provider.activate
      }.to change { Provider.find(provider.id).active }.from(false).to(true)
    end

    it 'notifies admin' do
      expect {
        provider.activate
      }.to change { AdminNotifierMailer.deliveries.count }
    end

    it 'notifies himself' do
      expect {
        provider.activate
      }.to change { SelfNotifierMailer.deliveries.count }
    end
  end

  describe 'deactivates' do
    let!(:provider) { create :active_and_paid_provider }

    it 'sets active as false' do
      expect {
        provider.deactivate
      }.to change { Provider.find(provider.id).active }.from(true).to(false)
    end

    it 'notifies admin' do
      expect {
        provider.deactivate
      }.to change { AdminNotifierMailer.deliveries.count }
    end

    it 'notifies himself' do
      expect {
        provider.deactivate
      }.to change { SelfNotifierMailer.deliveries.count }
    end
  end
end