class PhoneValidator < ActiveModel::EachValidator
  VALID_COUNTRY_CODES = ['+1', '+380', '+7']

  def validate_each(record, attribute, value)
    if value.present? && !valid?(value)
      record.errors[attribute] << (options[:message] || 'has invalid country code') unless valid_country?(value)
      record.errors[attribute] << (options[:message] || 'has invalid state code') unless valid_state?(value)
      record.errors[attribute] << (options[:message] || 'is invalid') unless TextMessage.valid?(value)
    end
  end

  def valid?(value)
    valid_country?(value) && valid_state?(value) && TextMessage.valid?(value)
  end

  def valid_country?(value)
    VALID_COUNTRY_CODES.any? { |country_code| value.start_with? country_code }
  end

  def valid_state?(value)
    phone = phone_without_country_code(value)
    AreaCode.all.map(&:code).any? { |state_code| phone.start_with? state_code.to_s }
  end

  def phone_without_country_code(value)
    VALID_COUNTRY_CODES.each { |country_code| value = value[(country_code.length)..-1] if value.start_with?(country_code) }
    value
  end
end