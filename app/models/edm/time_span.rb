# frozen_string_literal: true

module EDM
  class TimeSpan
    include Mongoid::Document
    include Mongoid::Timestamps
    include Mongoid::Uuid
    include ArrayOfAttributeValidation
    include Blankness::Mongoid::Attributes
    include Blankness::Mongoid::Relations
    include RDF::Graphable
    include RDF::Graphable::Literalisation

    field :edm_begin, type: Date
    field :edm_end, type: Date
    field :skos_altLabel, type: ArrayOf.type(String), default: []
    field :skos_prefLabel, type: String
    field :skos_note, type: ArrayOf.type(String), default: []

    has_one :edm_occurredAt_for,
            class_name: 'EDM::Event', inverse_of: :edm_occurredAt

    graphs_as_literal RDF::Vocab::SKOS.prefLabel

    def name
      name_with_begin_and_end || skos_prefLabel || id.to_s
    end

    def name_with_begin_and_end
      begin_and_end = [edm_begin, edm_end].compact.map(&:to_s).join('–')
      return nil unless begin_and_end.present?
      skos_prefLabel.present? ? "#{skos_prefLabel} (#{begin_and_end})" : begin_and_end
    end
  end
end
