module Ccda::PhoneFormatsHelper
  def ccda_phone(phone)
    number_to_phone(phone).gsub('+1', '+1-')
  end

  def value_or_null_phone(phone)
    if phone
      raw "value='tel:#{ccda_phone(phone)}'"
    else
      raw "nullFlavor='UNK'"
    end
  end

  def ccda_tel_phone(phone)
    "(#{phone[2..4]})#{phone[5..7]}-#{phone[8..-1]}"
  end
end