class StreetAddressesController < ApplicationController
  skip_before_action :authenticate_user!

  def registration_addresses
    @address_data = get_street_addresses(params[:full_street_line], params[:suit_apt_number]);
  end

  private

  def get_street_addresses(full_address, suit_apt_number)
    street_address_url = "#{ Rails.application.secrets.zipcode_api_street_address_url }?auth-id=#{ Rails.application.secrets.zipcode_api_id }&auth-token=#{ Rails.application.secrets.zipcode_api_token }"
    uri = URI.encode("#{street_address_url}&street=#{full_address}&street2=&city=&state=&zip=&candidates=5")
    data = JSON.load(open(uri))

    if !data.empty?
      data = data.map { |address| { 
        street_line: address['delivery_line_1'],
        city: address['components']['city_name'],
        state: address['components']['state_abbreviation'],
        zip: "#{address['components']['zipcode']}#{'-' + address['components']['plus4_code'] if address['components']['plus4_code']}",
        full_address: "#{address['delivery_line_1']}, #{('Suite ' + suit_apt_number + ', ') if suit_apt_number.present?}#{address['components']['city_name']}, #{address['components']['state_abbreviation']}, #{address['components']['zipcode']}#{'-' + address['components']['plus4_code'] if address['components']['plus4_code']}",
        suit_apt_number: suit_apt_number
      } }
    end
    return data
  end
end