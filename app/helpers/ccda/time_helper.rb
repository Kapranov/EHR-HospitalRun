module Ccda::TimeHelper
  def value_or_null_flavor(time)
    if time
      raw "value='#{ccda_time(time)}'"
    else
      raw "nullFlavor='UNK'"
    end
  end

  def ccda_time(time)
    Time.at(time).utc.to_formatted_s(:number)
  end
end