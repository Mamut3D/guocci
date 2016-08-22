class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_filter :check_limit_and_offset_param

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
      respond_with({ message: 'Limit is set incorrectly' }, status: 400)
      return false
    end
    unless offset =~ /\A\d+\z/
      respond_with({ message: 'Offset is set incorrectly' }, status: 400)
      return false
    end
    @limit = limit.to_i
    @offset = offset.to_i
    true
  end
end
