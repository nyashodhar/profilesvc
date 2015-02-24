class Profile
  include Mongoid::Document

  field :user_id, type: String
  validates_presence_of :user_id, message: I18n.t("field_is_required")

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


  #
  # INDEXES
  #
  # Note on sparse indexes in mongo:
  #   http://stackoverflow.com/questions/8608567/sparse-indexes-and-null-values-in-mongo
  #
  index({ user_id: 1 }, { unique: true, background: true, sparse: false })

end