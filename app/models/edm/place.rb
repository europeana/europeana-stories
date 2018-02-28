# frozen_string_literal: true

module EDM
  class Place
    include Mongoid::Document
    include Mongoid::Timestamps
    include AutocompletableModel
    include Blankness::Mongoid
    include RDFModel

    has_one :edm_happenedAt_for,
            class_name: 'EDM::Event', inverse_of: :edm_happenedAt

    field :owl_sameAs, type: String
    field :skos_altLabel, type: String
    field :skos_prefLabel, type: String
    field :skos_note, type: String
    field :wgs84_pos_lat, type: Float
    field :wgs84_pos_long, type: Float

    rails_admin do
      visible false

      field :owl_sameAs
      field :skos_altLabel
      field :skos_prefLabel
      field :skos_note
      field :wgs84_pos_lat, :string
      field :wgs84_pos_long, :string
    end

    def name
      skos_prefLabel
    end
  end
end
