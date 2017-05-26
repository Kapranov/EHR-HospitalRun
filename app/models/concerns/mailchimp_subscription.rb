class MailchimpSubscription

  class << self

    def subscribe(user)
      if exist? user.email
        update(user)
      else
        create(user)
      end
    end

    def members
      gibbon.lists(list_id).members.retrieve['members']
    end

    def exist?(email)
      members.map{ |user| user['email_address'] }.include? email
    end

    def member_id(user)
      mailchimp_members = members.select { |member| member['email_address'] == user.email }
      mailchimp_members[0]['id'] if mailchimp_members.any?
    end

    def create(user)
      gibbon.lists(list_id).members.create(params(user))
    end

    def update(user)
      gibbon.lists(list_id).members(member_id(user)).update(params(user))
    end

    private

    def gibbon
      Gibbon::Request.new(api_key: Rails.application.secrets.mailchimp_api_key, api_endpoint: endpoint)
    end

    def list_id
      Rails.application.secrets.mailchimp_list_id
    end

    def endpoint
      key = Rails.application.secrets.mailchimp_api_key
      "#{Rails.application.secrets.endpoint}://#{key[key.index('-') + 1..-1]}.api.mailchimp.com"
    end

    def params(user)
      {
          body: {
            email_address: user.email,
            status: :subscribed,
            merge_fields: { FNAME: user.person.first_name,
                            LNAME: user.person.last_name }
          }
      }
    end
  end
end