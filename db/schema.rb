# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 2) do

  create_table "lun_comments", :force => true do |t|
    t.integer  "topic_id",                                     :null => false
    t.integer  "parent_id"
    t.integer  "level",                     :default => 0
    t.integer  "user_id"
    t.string   "email",      :limit => 50
    t.boolean  "disabled",                  :default => false
    t.string   "ip",         :limit => 50
    t.string   "website",    :limit => 100
    t.string   "content",    :limit => 500
    t.datetime "created_on",                                   :null => false
    t.datetime "updated_on",                                   :null => false
    t.string   "created_by", :limit => 50,                     :null => false
    t.string   "updated_by", :limit => 50
  end

  add_index "lun_comments", ["ip"], :name => "index_lun_comments_on_ip"
  add_index "lun_comments", ["parent_id"], :name => "index_lun_comments_on_parent_id"
  add_index "lun_comments", ["topic_id"], :name => "index_lun_comments_on_topic_id"
  add_index "lun_comments", ["user_id"], :name => "index_lun_comments_on_user_id"
  add_index "lun_comments", ["website"], :name => "index_lun_comments_on_website"

  create_table "lun_feedbacks", :force => true do |t|
    t.integer  "comment_id",                              :null => false
    t.integer  "kind",                                    :null => false
    t.integer  "count",                    :default => 0
    t.string   "last_ip",    :limit => 50
    t.datetime "created_on",                              :null => false
    t.datetime "updated_on",                              :null => false
    t.string   "created_by", :limit => 50
    t.string   "updated_by", :limit => 50
  end

  add_index "lun_feedbacks", ["comment_id", "kind"], :name => "index_lun_feedbacks_on_comment_id_and_kind", :unique => true

  create_table "lun_sites", :force => true do |t|
    t.string   "url",         :limit => 500,                :null => false
    t.string   "name",        :limit => 250
    t.integer  "topic_count", :default => 0
    t.datetime "created_on",                                :null => false
    t.datetime "updated_on",                                :null => false
    t.string   "created_by",  :limit => 50
    t.string   "updated_by",  :limit => 50
  end

  add_index "lun_sites", ["url"], :name => "index_lun_sites_on_url", :unique => true

  create_table "lun_links", :force => true do |t|
    t.integer  "site_id",                                     :null => false
    t.string   "url",           :limit => 500,                :null => false
    t.string   "title",         :limit => 250
    t.string   "description",   :limit => 250
    t.string   "keyword",       :limit => 250
    t.integer  "gives", :default => 0
    t.integer  "takes", :default => 0
    t.integer "credits", :default => 0
    t.integer  "links", :default => 0
    t.integer  "clicks", :default => 0
    t.datetime "created_on",                                  :null => false
    t.datetime "updated_on",                                  :null => false
  end


  create_table "lun_link_hits", :force => true do |t|
    t.integer "link_id", :null => false
    t.integer "topic_id", :null => false
    t.integer "kind", :null => false, :default => 1
    t.string "ip", :limit => 50, :null=>true
    t.datetime "created_on", :null => false
  end

  add_index "lun_link_hits", ["link_id","topic_id", "kind"], :name => "index_lun_link_hits_on_link_id_and_topic_id_and_kind"

  create_table "lun_topics", :force => true do |t|
    t.integer  "site_id",                                     :null => false
    t.string   "url",           :limit => 500,                :null => false
    t.string   "title",         :limit => 250
    t.string   "description",   :limit => 250
    t.string   "keyword",       :limit => 250
    t.integer  "comment_count",                :default => 0
    t.datetime "created_on",                                  :null => false
    t.datetime "updated_on",                                  :null => false
    t.string   "created_by",    :limit => 50
    t.string   "updated_by",    :limit => 50
  end

  add_index "lun_topics", ["site_id"], :name => "index_lun_topics_on_site_id"
  add_index "lun_topics", ["url"], :name => "index_lun_topics_on_url", :unique => true

  create_table "open_id_authentication_associations", :force => true do |t|
    t.integer "issued"
    t.integer "lifetime"
    t.string  "handle"
    t.string  "assoc_type"
    t.binary  "server_url"
    t.binary  "secret"
  end

  create_table "open_id_authentication_nonces", :force => true do |t|
    t.integer "timestamp",  :null => false
    t.string  "server_url"
    t.string  "salt",       :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "login",                     :limit => 40
    t.string   "identity_url"
    t.string   "name",                      :limit => 100, :default => ""
    t.string   "email",                     :limit => 100
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token",            :limit => 40
    t.datetime "remember_token_expires_at"
    t.string   "activation_code",           :limit => 40
    t.datetime "activated_at"
    t.string   "state",                                    :default => "passive"
    t.datetime "deleted_at"
  end

  add_index "users", ["login"], :name => "index_users_on_login", :unique => true

end
