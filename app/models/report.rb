class Report
  include NoBrainer::Document
  include NoBrainer::Document::Timestamps

  def self.categories
    [:Patients]
  end

  def self.lists
    [:'Patient Lists']
  end

  field :category,   type: Enum,      in: self.categories,       default: self.categories.first
  field :list,       type: Enum,      in: self.lists,            default: self.lists.first
  field :criteria,   type: String
  field :query,      type: Array

  belongs_to :provider

  before_validation :set_datetimes
  after_initialize  :get_datetimes

  attr_accessor :created_at_date, :created_at_time

  def partial_name(dir_name)
    "reports/#{dir_name}/#{Patient.find_by_criteria_name(criteria)[0]}"
  end

  def allergy_values_list
    if Patient.find_by_criteria_name(criteria)[0] == :allergy
      case query[0]
        when Patient.allergy_criterias[:by_type]
          Allergy.allergen_types
        when Patient.allergy_criterias[:by_level]
          Allergy.severity_levels
        when Patient.allergy_criterias[:by_onset]
          Allergy.onset_ats
      end
    end
  end

  private
    def get_datetimes
      self.created_at ||= Time.now

      self.created_at_date ||= self.created_at.to_date.to_s(:frontend_date)
      self.created_at_time ||= "#{'%02d' % self.created_at.to_time.hour}:#{'%02d' % self.created_at.to_time.min}"
    end

    def set_datetimes
      self.created_at = "#{Date.strptime(self.created_at_date, Date::DATE_FORMATS[:frontend_date]).to_s(:db)} #{self.created_at_time}".to_time
    end
end
