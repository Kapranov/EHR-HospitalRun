shared_examples Notifiable do |user|
  it 'notifies admin on create' do
    expect {
      create user
    }.to change { AdminNotifierMailer.deliveries.count }
  end

  it 'notifies admin on destroy' do
    u = create(user)
    expect {
      u.destroy
    }.to change { AdminNotifierMailer.deliveries.count }
  end
end