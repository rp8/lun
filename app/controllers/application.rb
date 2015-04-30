# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
require 'aasm'

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  @cross_domain_check = false

  include AuthenticatedSystem

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  #protect_from_forgery :secret => 'dbe0bb348e4b57b48468b28f40efdc03', :digest => 'MD5', :only => [:update, :delete, :create]
  #protect_from_forgery :digest => 'MD5', :only => [:update, :delete, :create]
  self.allow_forgery_protection = false

  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  filter_parameter_logging :password

  protected

  def get_limit
    params[:n].blank? ? 5 : params[:n]
  end

  def get_url
    params[:u].blank? ? nil : params[:u]
  end

  def extract_root(url)
    results = url.match('(^http[s]?://[a-zA-z0-9\-_\.]*[:]?[0-9]*/)') if url
    results.nil? ? url : results[0]
  end

  # validate request and url: same domain policy
  def validate_domain(url)
    if @cross_domain_check
      url_root = extract_root(url)
      referer_root = extract_root(request.referer)
      unless referer_root.casecmp(url_root) == 0
        logger.warn "cross domain request: url=#{url}, referer=#{referer_root}"
        raise "cross domain request: #{url}"
      end
    end
  end

  def render_json(json, options={})
    status = options[:status].nil? ? 200 : options[:status]
    json = json.to_json(options) unless json.is_a?(String)
    cb, var = params[:cb], params[:v]
    json = begin
      if cb && var
        "var #{var} = #{json}; #{cb}(#{var});"
      elsif var
        "var #{var} = #{json};"
      elsif cb
        "#{cb}(#{json});"
      else
        json
      end
    end
    response.content_type = Mime::JSON
    if @debug
      render_for_text "DEBUG --- " + json
    else
      render_for_text "_xsajax$transport_status = #{status};" + json
    end
  end

  def find_topic(url)
    validate_domain(url)
    topic = Lun::Topic.find(:first, :conditions => ['url = ?', url])
    topic ||= nil
  end

  def find_or_create_topic
    url = get_url
    validate_domain(url)
    topic = find_topic(url)
    topic ||= create_topic_or_site(url)
  end

  def find_site(url)
    validate_domain(url)
    site = Lun::Site.find(:first, :conditions => ['url = ?', url])
  end

  def find_or_create_site
    url = extract_root(get_url)
    validate_domain(url)
    site = find_site(url)
    site ||= Lun::Site.new(:url => url) 
  end

  def create_topic_or_site(url)
    validate_domain(url)
    site = find_or_create_site
    site.increment(:topic_count)
    topic = site.topics.build(:new_site => site.new_record?, 
      :url => url, :title => params[:t], :description => params[:d], :keyword => params[:k]) 
    topic.site = site
    topic
  end
end
