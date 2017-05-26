module Provider::Subscribable
  def add_to_subscribe_list
    MailchimpSubscription.subscribe user if notify?
  end

  private

  def notify?
    notify
  end
end