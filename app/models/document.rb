class Document < ActiveRecord::Base
  belongs_to :account
  
  has_many :authorships, :dependent => :destroy
  has_many :authors, :through => :authorships
  
  has_many :printings, :dependent => :destroy
  has_many :issues, :through => :printings
  
  belongs_to :section, :class_name => "Category"
  has_many :sortings, :dependent => :destroy
  has_many :categories, :through => :sortings
  
  has_many :waxings, :dependent => :destroy
  has_many :mediafiles, :through => :waxings
  has_many :images, :through => :waxings, :source=>'mediafile', :conditions => { :type => 'Image'}
  
  acts_as_taggable_on :tags
  
  accepts_nested_attributes_for :mediafiles
  accepts_nested_attributes_for :sortings, :allow_destroy => true     
  accepts_nested_attributes_for :authorships, :allow_destroy => true
  
  
  validates_presence_of :account, :message => "Must have an account"
  validates_associated :account, :message => "Account must be valid"

  define_index do
    indexes title, :sortable => :true
    indexes subtitle
    indexes bodytext
    indexes authors.name, :as => :authors_names
    indexes waxings.caption, :as => :captions
    indexes tags.name, :as => :tags
    indexes published_at, :sortable => :true

    has created_at
    has account_id
    has type
    
    set_property :delta => true
  end

  def self.per_page
      10
  end
  
  def display_title
    if self.title and self.title.strip != ""
      return self.title
    else 
      return "(no headline)"
    end
  end
  
  # This method handles the public availability of a Document
  def publish(status=nil, time = Time.now)
    case status
    when "Published"
      self.status = "Published"
      self.published_at = time
    else
      self.status = nil
    end
  end
  
  # Logical alias used for unpublishing an article
  def unpublish
    publish
  end
  
  # Categories are set in a checkbox style, and that's reflected in this attribute method.
  # 
  # Category attributes should be passed in as a hash with the category id as the key and 
  # a value of 0, "0", or anything ".blank?" to indicate no Sorting for this category and anything else to
  # indicate that a Sorting should exist 
  def categories_attributes=(attributes)
    raise ActiveRecord::AttributeAssignmentError unless attributes.is_a? Hash
    attributes.each do | cat_id, value |
      if value.blank? || value==0 || value=="0"
        begin
          cat = categories.find(cat_id)
          categories.delete(cat)
        rescue ActiveRecord::RecordNotFound # If it's not already a category, do nothing
        end
      else
        if cat = account.categories.find(cat_id)
          categories << cat
        end
      end
    end
  end
  
  # Returns list of article's author names as a readable list, separated by commas and the word "and".
  def authors_list
     case self.authors.length
     when 0
       return nil
     when 1
       return self.authors.first.name
     when 2
       return self.authors.first.name + " and " + self.authors.second.name
     else
      list = String.new
      (0..(self.authors.count - 3)).each{ |i| list += authors[i].name + ", " }
      list += authors[self.authors.length-2].name + " and " + authors[self.authors.length-1].name # last two authors get special formatting
      return list
    end         
  end
  
  #Breaks up a human readable list of authors and creates each one and adds it to self.authors.
  def authors_list=(list)
    if list
      list.split(/, and | and |,/).each do |name| 
        author = Author.find_or_create_by_name_and_account_id(name.strip, self.account.id)
        self.authors << author unless self.authors.member?(author) || author.nil?
      end
    end
  end
  
  def has_attached_media?
    self.mediafiles ? true : false
  end
  
  def to_xml(options = {})
     options[:indent] ||= 2
     xml = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])
     xml.instruct! unless options[:skip_instruct]
     
     xml.article do
       xml.tag!( :published_at, self.published_at.to_formatted_s(:long))
       xml.tag!( :title, self.title )
       xml.tag!( :subtitle, self.subtitle )
       xml.tag!( :authors_list, self.authors_list )
       xml.tag!( :bodytext, self.bodytext )
       xml.tag!( :id, self.id )
       self.section.nil? ? xml.section("") : xml.section(self.section.name)
     end
  end
  
  
end
