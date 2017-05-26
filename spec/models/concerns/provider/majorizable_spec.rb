shared_examples Provider::Majorizable do
  shared_examples 'a checkable for being main' do |result|
    it { expect(provider.main_provider?).to eq result }
  end

  shared_examples 'a major' do
    it { expect(provider.main_provider).to  eq result }
  end

  shared_examples 'a container of all providers' do
    it { expect(provider.all_providers).to include provider }
    it { expect(provider.all_providers).to include provider.main_provider }
  end

  shared_examples 'a searcher for other providers' do
    it { expect(provider.find_provider(provider.id)).to               eq provider }
    it { expect(provider.find_provider(provider.main_provider.id)).to eq provider.main_provider }
  end

  shared_examples 'a searcher by a part of name' do
    it { expect(provider.find_providers_by(provider.first_name[0..3])).to               include provider }
    it { expect(provider.find_providers_by(provider.main_provider.first_name[0..3])).to include provider.main_provider }
    it { expect(provider.find_providers_by(provider.last_name[0..3])).to                include provider }
    it { expect(provider.find_providers_by(provider.main_provider.last_name[0..3])).to  include provider.main_provider }
  end

  context 'main provider' do
    let!(:provider) { create :provider, user_id: nil }

    it_behaves_like 'a checkable for being main', true
    it_behaves_like 'a major' do
      let!(:result) { provider }
    end
    it_behaves_like 'a container of all providers'
    it_behaves_like 'a searcher for other providers'
    it_behaves_like 'a searcher by a part of name'
  end

  context 'subprovider' do
    let!(:main_provider) { create :provider, user_id: nil }
    let!(:provider)      { create :provider, user_id: nil, practice_role: :Dentist, provider_id: main_provider.id }

    it_behaves_like 'a checkable for being main', false
    it_behaves_like 'a major' do
      let!(:result) { provider.provider }
    end
    it_behaves_like 'a container of all providers'
    it_behaves_like 'a searcher for other providers'
    it_behaves_like 'a searcher by a part of name'
  end
end