# frozen_string_literal: true

module EDM
  class Agent
    include Mongoid::Document
    include RDFModel
    include RemoveBlankAttributes

    embedded_in :dc_creator_for, class_name: 'EDM::ProvidedCHO', inverse_of: :dc_creator
    embedded_in :dc_contributor_for, class_name: 'EDM::ProvidedCHO', inverse_of: :dc_contributor

    #belongs_to :rdaGr2_placeOfBirth, class_name: 'EDM::Place', optional: true
    #belongs_to :rdaGr2_placeOfDeath, class_name: 'EDM::Place', optional: true

    field :rdaGr2_dateOfBirth, type: Date
    field :rdaGr2_dateOfDeath, type: Date
    field :rdaGr2_placeOfBirth, type: String
    field :rdaGr2_placeOfDeath, type: String
    field :skos_prefLabel, type: Hash
    field :skos_altLabel, type: Hash
    field :foaf_mbox, type: String
    field :foaf_name, type: String

    rails_admin do
      visible false
      object_label_method { :foaf_name }
      field :foaf_name, :string
      field :foaf_mbox, :string
      field :rdaGr2_dateOfBirth
      field :rdaGr2_placeOfBirth
      field :rdaGr2_dateOfDeath
      field :rdaGr2_placeOfDeath
    end

    def blank?
      attributes.except('_id').values.all?(&:blank?)# &&
        #rdaGr2_placeOfBirth.blank? &&
        #rdaGr2_placeOfDeath.blank?
    end
  end
end
