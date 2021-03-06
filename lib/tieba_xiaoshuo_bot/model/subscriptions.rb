# coding: utf-8
module TiebaXiaoshuoBot
  class Subscription < Sequel::Model
    plugin :validation_helpers
    many_to_one :user
    many_to_one :fiction
    include BaseModel

    # primary_key :id
    # foreign_key :fiction_id, :fictions
    # foreign_key :user_id, :users
    # foreign_key :check_id, :check_lists
    # TrueClass :active, :default => true
    # Time :created_at
    # Time :updated_at

    def validate
      super
      validates_unique [:user_id, :fiction_id]
      # unique relations btw user and fiction
    end

    # sorry for the misunderstood of check_list
    def last_id
      self.check_id || 0
    end

    def update_last last_id
      self.update(:check_id => last_id)
    end

    alias checked_id last_id

    def active_it
      self.update(:active => true)
      true
    end

    def deactive_it
      if self.active == false
        false
      else
        self.active = false
        self.save
        true
      end
    end

    alias sub_active active_it
    alias sub_deactive deactive_it

    def active?
      active
    end

    def deactive?
      !active
    end

    class << self
      def active_fictions
        self.filter(:active).select(:fiction_id).group(:fiction_id)
      end

      def active_users fiction_id
        self.join(:users, :id=> :user_id).select(:subscriptions__id, :fiction_id,:user_id,:check_id,:subscriptions__active,:users__active___user_active).filter(:users__active, :fiction_id => fiction_id)
      end
    end
  end
  Subscription.set_dataset DB[:subscriptions]
end
