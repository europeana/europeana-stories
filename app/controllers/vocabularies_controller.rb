# frozen_string_literal: true

class VocabulariesController < ApplicationController
  class << self
    attr_reader :index_options

    def vocabulary_index(options)
      @index_options = options
    end
  end

  delegate :index_options, to: :class

  def index
    response = Faraday.get(index_options[:url], index_params)
    json = JSON.parse(response.body)
    data = index_data(json)
    render json: data.uniq
  end

  protected

  def index_params
    index_options[:params].merge(index_options[:query] => index_query)
  end

  def index_query
    params[:q]
  end

  def index_data(json)
    json[index_options[:results]].map do |result|
      result_text = call_or_fetch(index_options[:text], result)
      result_value = call_or_fetch(index_options[:value], result)
      { text: result_text, value: result_value }
    end
  end

  def call_or_fetch(proc_or_key, hash)
    proc_or_key.respond_to?(:call) ? proc_or_key.call(hash) : hash[proc_or_key]
  end
end
