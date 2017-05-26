class Vital
  include NoBrainer::Document
  include NoBrainer::Document::Timestamps

  def self.temp_types
    [
        :'Unspecified',
        :'Axillary',
        :'Oral',
        :'Rectal',
        :'Skin',
        :'Temporal',
        :'Tympanic'
    ]
  end

  def self.ra_types
    [
        :'RA',
        :'0.5 LO2',
        :'1.0 LO2',
        :'1.5 LO2',
        :'2.0 LO2',
        :'2.5 LO2',
        :'3.0 LO2',
        :'>3.0 LO2'
    ]
  end

  def self.units_systems
    [:us, :euro]
  end

  field :height_major, type: Integer
  field :height_minor, type: Integer
  field :weight,       type: Float
  field :bmi,          type: Float
  field :units_system, type: Enum,      in: self.units_systems, default: self.units_systems.first
  field :bp_left,      type: String
  field :bp_right,     type: String
  field :temp,         type: String
  field :pulse,        type: String
  field :rr,           type: String
  field :sat,          type: String
  field :temp_type,    type: Enum,      in: self.temp_types,    default: self.temp_types.first
  field :ra_type,      type: Enum,      in: self.ra_types,      default: self.ra_types.first
  field :blood,        type: String

  belongs_to :encounter

  after_create :set_bmi

  def to_label
    "HEIGHT: #{height_major} ft. #{height_minor} in.; WEIGHT: #{weight} lbs.; BLOOD PRESSURE: #{bp_left} / #{bp_right} mmHg, BMI: #{bmi}"
  end

  def height_in_m
    if units_system == :us
      (height_major * 12 + height_minor) * 0.0254
    else
      height_major + height_minor * 100
    end
  end

  def weight_in_kg
    if units_system == :us
      weight * 0.4535
    else
      weight
    end
  end

  private

  def set_bmi
    if [:height_minor, :height_major, :weight].all? { |field| send(field) != 0 && send(field).present? }
      update(bmi: ((weight * 703) / ((height_major * (units_system == :euro ? 100 : 12) + height_minor)**2)).round(2))
    end
  end
end
