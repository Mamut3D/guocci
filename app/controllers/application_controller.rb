class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_filter :check_limit_and_offset_param

  rescue_from ::Errors::ApplianceNotFoundError, with: :handle_not_found_err
  rescue_from ::Errors::SiteNotFoundError, with: :handle_not_found_err
  rescue_from ::Errors::FlavourNotFoundError, with: :handle_not_found_err

  protected
  DEFAULT_LIMIT = '10'.freeze
  DEFAULT_OFFSET = '0'.freeze

  def cache_manager
    @cache_instance ||= Utils::MongoDBCache.new(logger: Rails.logger)
  end

  def check_limit_and_offset_param
    limit = params[:limit] || DEFAULT_LIMIT
    offset = params[:offset] || DEFAULT_OFFSET

    unless limit =~ /\A\d+\z/
      respond_with({ message: "Limit '#{params[:limit]}' is incorrect. Integer is required" }, status: 400)
      return false
    end
    unless offset =~ /\A\d+\z/
      respond_with({ message: "Offset '#{params[:offset]}' is incorrect. Integer is required" }, status: 400)
      return false
    end
    @limit = limit.to_i
    @offset = offset.to_i
    true
  end

  def handle_not_found_err(ex)
    respond_with({message: ex.message}, status: 404)
  end
end
