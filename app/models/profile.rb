class Profile
  include Mongoid::Document

  field :first_name, type: String
  validates_presence_of :first_name, message: I18n.t("field_is_required")
  validates :first_name, length: {
      minimum: 1, too_short: I18n.t("input_is_too_short"),
      maximum: 256, too_long: I18n.t("input_is_too_long")
  }

  field :last_name, type: String
  validates_presence_of :last_name, message: I18n.t("field_is_required")
  validates :last_name, length: {
      minimum: 1, too_short: I18n.t("input_is_too_short"),
      maximum: 256, too_long: I18n.t("input_is_too_long")
  }

end