class Blog < ActiveRecord::Base
  belongs_to :account
  
  has_many :entries, :through => :postings, :order => "created_at DESC"
  
  has_many :postings
  
  acts_as_authorizable
  
  # Returns an array of contributors
  def contributors
    has_contributors
  end
  
end
