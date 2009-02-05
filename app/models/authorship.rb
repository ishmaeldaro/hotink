#Authorship is a join model for linking Articles and Authors.
#  In addition to carrying the necessary foreign keys, this model also carries 
#  an optional staff_position attribute that can be used to define the relationship 
#  between the author and the article at the time of writing.
#    eg. If when a writer submitted an article they were the "News Editor", this
#    relationship would be preserved regardless of whether that writer eventually
#    became "Arts Editor" or "Editor-in-Chief."
class Authorship < ActiveRecord::Base
  belongs_to :account
  
  #Author and article relationships
  belongs_to :author
  belongs_to :article
  
end
