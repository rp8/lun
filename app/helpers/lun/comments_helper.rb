module Lun::CommentsHelper
  def name_or_website(comment)
    comment.website.nil? ? comment.created_by : "<a href='#{comment.website}' target='_new'>#{comment.created_by}</a>"
  end

  def render_newline(str)
    str.gsub(/\n/,'<br/>') unless str == nil 
  end

  def no_of_comments(n)
    if n == nil or n == 0
      'comments'
    else
      "#{n} comments"
    end
  end

  def build_threads(comments)
    threads = {}
    unless comments.empty?
      topics = comments.collect {|c| c.topic}.uniq
      topics.each {|t| threads[t.id] = {"topic" => t, "comments" => []}}
      comments.each do |c|
        t = threads[c.topic.id]
        t["comments"] << c if t["comments"].length <= 1
      end
    end
    threads
  end


end
