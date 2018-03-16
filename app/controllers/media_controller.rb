# frozen_string_literal: true

class MediaController < ApplicationController
  def show

    web_resource = EDM::WebResource.find_by(uuid: params[:uuid])

    authorize! :show, web_resource&.ore_aggregation&.contribution
    redirect_to redirect_location(web_resource), status: 303
  rescue Mongoid::Errors::DocumentNotFound
    DeletedWebResource.find_by(uuid: params[:uuid])
    render plain: Rack::Utils::HTTP_STATUS_CODES[410], status: 410
  end

  private

  def redirect_location(web_resource)
    case params[:size]
    when 'w200', 'w400'
      web_resource.media.url(params[:size].to_sym)
    else
      web_resource.media_url
    end
  end
end
