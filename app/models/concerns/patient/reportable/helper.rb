module Patient::Reportable::Helper
  def add_time_ranges_criteria(ranges)
    criterias = []
    if ranges.present? && ranges.is_a?(Hash)
      ranges.each do |field, range|
        criterias << if range.present? && range.is_a?(Range) && range.first.present? && range.last.present?
          {field.eq => range.first.beginning_of_day..range.last.end_of_day}
        end
      end
    end
    criterias.reject{ |crit| crit.blank? }
  end
end