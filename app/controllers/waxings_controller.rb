class WaxingsController < ApplicationController
  before_filter :find_article, :find_mediafile, :find_entry, :find_document
  layout 'hotink'
  
  helper_method :plural_class_name
  
  # GET /waxings
  # GET /waxings.xml
  def index
    @waxings = Waxing.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @waxings }
    end
  end

  # GET /waxings/1
  # GET /waxings/1.xml
  def show
    @waxing = Waxing.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @waxing }
    end
  end

  # GET /waxings/new
  # GET /waxings/new.xml
  def new
    @waxing = @account.waxings.build
    
    @waxing.document = @document

    #@mediafiles = @account.mediafiles.search(@search_query, :page=>(params[:page] || 1), :per_page => (params[:per_page] || 10 ), :order => :date, :sort_mode => :desc, :include => [:authors])
    @mediafiles = @account.mediafiles.paginate(:page=>(params[:page] || 1), :per_page => (params[:per_page] || 10 ), :order => 'date DESC', :include => [:authors])
    @waxing.document.mediafiles.each { |m| @mediafiles.delete(m) } # Scrub out already attached files

    respond_to do |format|
      format.html # new.html.erb
      format.js
      format.xml  { render :xml => @waxing }
    end
  end

  # GET /waxings/1/edit
  def edit
    @waxing = @account.waxings.find(params[:id])
    respond_to do |format|
      format.js
    end
  end

  # POST /waxings
  # POST /waxings.xml
  # This is a split behaviour method, handling create-one and create-many based
  # on which parameters it receives. 
  def create
    if params[:waxing]
      @waxing = @account.waxings.build(params[:waxing])
      respond_to do |format|
        if @waxing.save
          flash[:notice] = 'Media attached'
          format.html { redirect_to(@waxing) }
          format.xml  { render :xml => @waxing, :status => :created, :location => @waxing }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @waxing.errors, :status => :unprocessable_entity }
        end
      end
    elsif params[:mediafile_ids]
      
      
      # Set behaviour based on document type
      if @document.is_a? Article
        redirect_path = edit_account_article_url(@account, @document)
      elsif @document.is_a? Entry
        redirect_path = edit_account_blog_entry_url(@account, @document.blogs.first, @document)
      end
      
      params[:mediafile_ids].each { |k, v| @account.waxings.create(:document_id => @document.id, :mediafile_id => k)  }
      
      respond_to do |format|
        flash[:notice] = "Media attached"
        format.html { redirect_to(redirect_path) }
        format.js
      end
    end
  end

  # PUT /waxings/1
  # PUT /waxings/1.xml
  def update
    @waxing = Waxing.find(params[:id])

    respond_to do |format|
      if @waxing.update_attributes(params[:waxing])
        format.js
        format.html { redirect_to(@waxing) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @waxing.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /waxings/1
  # DELETE /waxings/1.xml
  def destroy
    @waxing = @account.waxings.find(params[:id])
    
    respond_to do |format|
      if @waxing.destroy
        flash[:notice] = "Media detached"
        format.js
        format.xml  { head :ok }
      end
    end
  end
end
