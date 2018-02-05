# frozen_string_literal: true

module EDM
  class Event
    include Mongoid::Document
    include Mongoid::Timestamps
    include RDFModel
    include RemoveBlankAttributes

    has_many :stories, class_name: 'Story', inverse_of: :edm_event, dependent: :nullify
    embeds_one :edm_happenedAt, class_name: 'EDM::Place', inverse_of: :edm_happenedAt_for, cascade_callbacks: true
    embeds_one :edm_occurredAt, class_name: 'EDM::TimeSpan', inverse_of: :edm_occurredAt_for, cascade_callbacks: true

    field :dc_identifier, type: String
    field :edm_isRelatedTo, type: String
    field :skos_altLabel, type: String
    field :skos_prefLabel, type: String
    field :skos_note, type: String

    accepts_nested_attributes_for :edm_happenedAt, :edm_occurredAt

    rails_admin do
      field :dc_identifier, :string
      field :skos_prefLabel
      field :edm_isRelatedTo, :string
      field :skos_note
      field :edm_happenedAt
      field :edm_occurredAt
    end

    def name
      candidates = [skos_prefLabel, edm_happenedAt&.name, edm_occurredAt&.name].compact
      candidates.present? ? candidates.join(', ') : id.to_s
    end
  end
end
