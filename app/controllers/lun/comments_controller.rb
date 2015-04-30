class Lun::CommentsController < ApplicationController
  layout 'application'

  before_filter :login_required, :only => [:index]

  # route: /cmt/
  def index
    @latest_comments = Lun::Comment.find(:all, :limit => 25, :order => 'id DESC', :include => :topic)
    @top_topics = Lun::Topic.find(:all, :limit => 25, :order => 'comment_count DESC')
    @top_sites = Lun::Site.find(:all, :limit => 5, :order => 'topic_count DESC')
  end

  def user
    id = params[:id]
    page = params[:page] 
    @comments = Lun::Comment.paginate(:all, :order => 'id ASC',
      :per_page => 5, :page => page.blank? ? 1 : page, :include => :topic,
      :conditions => ['disabled = ? and user_id = ?', false, id] 
    )
  end

  # route: /cmt/count.:format?u=url1,url2
  def count
    counters = {}
    begin
      params[:u].split(',').each do |url|
        topic = find_topic(url)
        counters[url] = topic.nil? ? 0 : topic.comment_count
      end unless params[:u].blank?
    rescue Exception => ex
      flash[:error] = ex.message
    end

    respond_to do |format|
      format.js {render_json({:flash => flash, :urls => counters})}
    end
  end

  # route: /cmt/latest.:format?v=lr&u=url&n=n
  def latest
    begin
      site = find_site(extract_root(get_url))
      comments = Lun::Comment.find(:all, :limit => get_limit,
        :select => 'lun_comments.*, lun_topics.url', :order => 'lun_comments.id DESC',
        :joins => 'inner join lun_topics on lun_topics.id = lun_comments.topic_id inner join lun_sites on lun_sites.id = lun_topics.site_id',
        :conditions => ['lun_sites.id = ? and disabled = ?', site.id, false]) if site
    rescue Exception => ex
      flash[:error] = ex.message
    end

    comments ||= []

    respond_to do |format|
      format.js {
        render_json({:flash => flash, :comments => comments}, 
          :except => Lun::Comment.json_except << :url
        )
      }
    end
  end

  # top topics on a site
  # route: /cmt/top.:format?var=lr&u=url&n=n
  def top
    begin
      site = find_site(extract_root(get_url))
      topics = site.topics.find(:all, :limit => get_limit, :order => 'comment_count DESC') if site
    rescue Exception => ex
      flash[:error] = ex.message
    end

    topics ||= []

    respond_to do |format|
      format.js {
        render_json({:flash => flash, :topics => topics}, :except => Lun::Topic.json_except)
      }
    end
  end

  # show comments under a topic
  # route: /cmts/show.:format?v=lr&u=url
  def show
    begin
      topic = find_topic(get_url)
      size = params[:s].to_i
      page = params[:p].to_i

      page = 1 if page.zero?
      size = 50 if size.zero?

      comments = topic.comments.paginate(:all, :order => 'id ASC',
        :per_page => size, :page => page, :conditions => ['disabled = ?', false] 
      ) if topic
      comment = topic.nil? ? Lun::Comment.new : topic.comments.build
    rescue Exception => ex
      flash[:error] = ex.message
    end

    comments ||= []

    respond_to do |format|
      format.js {
        render_json({:flash => flash, :comments => comments, 
          :pager => {
            :page => page, :size => size,
            :pages => comments.empty? ? 0 : comments.total_pages
          }, 
          :new => comment
        }, :except => Lun::Comment.json_except)
      }
    end
  end

  def new
    @comment ||= Lun::Comment.new(:created_by => self.current_user.login,
      :email => self.current_user.email, :user_id => self.current_user.id,
      :topic_id => 2, :website => self.current_user.website
    )
    @errors = @comment.errors
  end

  # create a new comment on a site/topic
  # route: /cmt/create.:format?var=lresult...
  def create
    begin
      topic = find_or_create_topic
      if topic
          if params[:id].to_i > 0
            p = topic.comments.find(params[:id])
            @comment = topic.comments.build(:created_by => params[:n], 
              :email => params[:e], :website => params[:w], 
              :content => params[:c], :ip => request.remote_ip,
              :user_id => self.current_user ? self.current_user.id : nil
            )
            Lun::Comment.transaction do
              topic.increment(:comment_count)
              topic.save 
              @comment.save_as_reply!(p)
            end
          else
            @comment = topic.comments.build(:created_by => params[:n], 
              :email => params[:e], :website => params[:w], 
              :content => params[:c], :ip => request.remote_ip,
              :user_id => self.current_user ? self.current_user.id : nil
                                           )
            Lun::Comment.transaction do
              topic.site.save if topic.new_site? || topic.site.changed?
              topic.increment(:comment_count)
              topic.save 
              @comment.save!
            end
            flash[:notice] = 'comment posted'
          end
      end
    rescue Exception => ex
      flash[:error] = ex.message
    end

    @errors = @comment.errors

    respond_to do |format|
      format.html {render :action => 'new'}
      format.js { 
        render_json({
          :flash => flash,
          :errors => @errors, 
          :created => @comment
          }, :except => Lun::Comment.json_except) 
      }
    end
  end

  def reply
    begin
      topic = find_or_create_topic
      comment = nil
      if topic
          p = topic.comments.find(params[:id])
          Lun::Comment.transaction do
            comment = topic.comments.build(:created_by => 'user', 
              :email => 'email@a.com', :website => '', 
              :content => 'a...', :ip => request.remote_ip
            )
            topic.increment(:comment_count)
            topic.save 
            comment.save_as_reply!(p)
          end
      end
    rescue Exception => ex
      flash[:error] = ex.message
    end

    respond_to do |format|
      format.js { 
        render_json({
          :flash => flash,
          :errors => comment.nil? || comment.errors.empty? ? nil : comment.errors, 
          :created => comment
          }, :except => Lun::Comment.json_except) 
      }
    end

  end

  # route: /cmt/spam.:format?var=lresult&url=url1&id=id1
  def spam
    id = params[:id]
    begin
      topic = find_topic(get_url)
      comment = topic.comments.find(:first, :conditions => ['id = ?', id]) if topic and id
      if comment
        feedback = comment.feedbacks.find(:first, :conditions => ['kind = 1'])
        feedback ||= comment.feedbacks.new 
        if feedback.spam(request.remote_ip)
          Lun::Feedback.transaction do
            feedback.save
            comment.update_attribute(:disabled, true) if feedback.count >= 3
          end
        end
      end
    rescue Exception => ex
      flash[:error] = ex.message
    end

    respond_to do |format|
      format.js {render_json({:flash => flash, :id => id})}
    end
  end

  private


end
