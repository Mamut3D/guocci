class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_filter :check_limit_and_offset_param

  rescue_from ::Errors::NotFoundError, with: :handle_not_found_err
  rescue_from ::Errors::ParameterError, with: :parameter_err

  protected

  DEFAULT_LIMIT = '10'.freeze
  DEFAULT_OFFSET = '0'.freeze

  def cache_manager
    @cache_instance ||= Utils::MongodbCache.new(logger: Rails.logger)
  end

  def check_limit_and_offset_param
    check_limit
    check_offset
  end

  def check_limit
    limit = params[:limit] || DEFAULT_LIMIT
    unless limit =~ /\A\d+\z/
      raise Errors::ParameterError, "Limit '#{params[:limit]}' is incorrect. " \
                                    'Integer is required'
    end
    @limit = limit.to_i
  end

  def check_offset
    offset = params[:offset] || DEFAULT_OFFSET
    unless offset =~ /\A\d+\z/
      raise Errors::ParameterError, "Offset '#{params[:offset]}' is incorrect. " \
                                    'Integer is required'
    end
    @offset = offset.to_i
  end

  def handle_not_found_err(ex)
    respond_with({ message: ex.message }, status: 404)
  end

  def parameter_err(ex)
    respond_with({ message: ex.message }, status: 400)
  end
end
