class Language
  include NoBrainer::Document
  include NoBrainer::Document::Timestamps

  field :alpha2,        type: String
  field :alpha3,        type: String
  field :bibliographic, type: String
  field :name,          type: String

  index :name
  index :alpha2

  scope :base_languages,      -> { where(:alpha2.not => '', :name.in     => ['English', 'Spanish', 'German', 'Russian']).order_by(name: :asc) }
  scope :preferred_languages, -> { where(:alpha2.not => '', :name.not.in => ['English', 'Spanish', 'German', 'Russian']).order_by(name: :asc) }

  def self.languages
    (base_languages + preferred_languages).uniq(&:name).map { |language| "#{language.name} (#{language.alpha2})" }
  end
end
