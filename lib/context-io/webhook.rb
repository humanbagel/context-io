require 'context-io/resource'

module ContextIO
  # A webhook.
  
  class Webhook < ContextIO::Resource
    
    attr_reader :account_id, :webhook_id, :sync_period, :active, :callback_url, :failure_notif_url, :filter_to, :filter_from,
    :filter_cc, :filter_subject, :filter_thread, :filter_new_important, :filter_file_name, :filter_file_revisions,
    :filter_folder_added, :filter_folder_removed, :sync_period
    
    def self.all(account)
      return [] if account.nil?

      account_id = account.is_a?(Account) ? account.id : account.to_s
      get("/2.0/accounts/#{account_id}/webhooks").map do |msg|
        Webhook.from_json(account_id, msg)
      end
    end
    
    def self.from_json(account_id, json_msg)
      raise ArgumentError if account_id.to_s.empty?
      webhook = new
      webhook.instance_eval do
        @webhook_id = json_msg['webhook_id']
        @account_id = account_id.to_s
        @callback_url = json_msg['callback_url']
        @failure_notif_url = json_msg['failure_notif_url']
        @active = json_msg['active']
        @sync_period = json_msg['sync_period']
        @filter_to = json_msg['filter_to']
        @filter_from = json_msg['filter_from']
        @filter_cc = json_msg['filter_cc']
        @filter_subject = json_msg['filter_subject']
        @filter_thread = json_msg['filter_thread']
        @filter_new_important = json_msg['filter_new_important']
        @filter_file_name = json_msg['filter_file_name']
        @filter_file_revisions = json_msg['filter_file_revisions']
        @filter_folder_added = json_msg['filter_folder_added']
        @filter_folder_removed = json_msg['filter_folder_removed']
      end

      webhook
    end
    
    def self.find(account, webhook_id)
      return nil if account.nil? or message_id.nil?
      account_id = account.is_a?(Account) ? account.id : account.to_s

      Webhook.from_json(account_id, get("/2.0/accounts/#{account_id}/webhooks/#{webhook_id}"))
    end
    
    def set_active(active)
      return nil if account_id.nil?

      response = post("/2.0/accounts/#{account_id}/webhooks/#{webhook_id}", {:active => active})
      success = response['success']
      if success
        @active = active
      end
      success
    end
    
    def create
      unless self.callback_url && self.failure_notif_url
        raise ArgumentError.new('You must specify callback and failure urls')
      end
      
      attributes = { :callback_url => self.callback_url, :failure_notif_url => self.failure_notif_url }
      attributes[:filter_to] = self.filter_to if self.filter_to
      attributes[:filter_from] = self.filter_from if self.filter_from
      attributes[:filter_cc] = self.filter_cc if self.filter_cc
      attributes[:filter_subject] = self.filter_subject if self.filter_subject
      attributes[:filter_thread] = self.filter_thread if self.filter_thread
      attributes[:filter_new_important] = self.filter_new_important if self.filter_new_important
      attributes[:filter_file_name] = self.filter_file_name if self.filter_file_name
      attributes[:filter_file_revisions] = self.filter_file_revisions if self.filter_file_revisions
      attributes[:filter_folder_added] = self.filter_folder_added if self.filter_folder_added
      attributes[:filter_folder_removed] = self.filter_folder_removed if self.filter_folder_removed
      attributes[:sync_period] = self.sync_period if self.sync_period
      

      response = post("/2.0/accounts/#{account_id}/webhooks", attributes)
      @webhook_id = response['webhook_id']

      @saved = response['success']
    end
  end
  
  private :create
  
  def save
    create
  end
  
  def destroy
    return false if @webhook_id.to_s.empty?

    response = delete("/2.0/accounts/#{@account_id}/webhooks/#{@webhook_id}")
    @webhook_id = '' if response['success']

    response['success']
  end
  
  def initialize(attributes={})
    @callback_url = attributes[:callback_url]
    @failure_notif_url = attributes[:failure_notif_url]
    @filter_to = attributes[:filter_to]
    @filter_from = attributes[:filter_from]
    @filter_cc = attributes[:filter_cc]
    @filter_subject = attributes[:filter_subject]
    @filter_thread = attributes[:filter_thread]
    @filter_new_important = attributes[:filter_new_important]
    @filter_file_name = attributes[:filter_file_name]
    @filter_file_revisions = attributes[:filter_file_revisions]
    @filter_folder_added = attributes[:filter_folder_added]
    @filter_folder_removed = attributes[:filter_folder_removed]
    @sync_period = attributes[:sync_period]
  end
end