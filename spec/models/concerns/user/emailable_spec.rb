shared_examples User::Emailable do
  let!(:inbox)   { create :email_message, to_id: user.id,   draft: false, archive: false }
  let!(:sent)    { create :email_message, from_id: user.id, draft: false, archive: false }
  let!(:draft)   { create :email_message, from_id: user.id, draft: true,  archive: false }
  let!(:urgent)  { create :email_message, to_id: user.id,   draft: false, archive: false, urgent: true }
  let!(:archive) { create :email_message, to_id: user.id,   draft: false, archive: true }

  it 'returns inbox messages' do
    expect(user.inbox).to   contain_exactly inbox, urgent
  end

  it 'returns sent messages' do
    expect(user.sent).to    contain_exactly sent
  end

  it 'returns draft messages' do
    expect(user.draft).to   contain_exactly draft
  end

  it 'returns urgent messages' do
    expect(user.urgent).to  contain_exactly urgent
  end

  it 'returns archive messages' do
    expect(user.archive).to contain_exactly archive
  end
end