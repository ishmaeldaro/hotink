class UserActivationsController < ApplicationController
  
  skip_before_filter :find_account, :except => [:create]
  before_filter :load_user_using_perishable_token, :only => [:edit, :update]
  before_filter :check_user_qualifications, :only => [:edit, :update]
  
  permit "admin or manager of account", :only => [:create, :destroy]
  
  def create 
    begin
      raise ArgumentError unless params[:user_activation] && params[:user_activation][:email] && params[:user_activation][:email].strip.match(/^[A-Z0-9._%+-]+@(?:[A-Z0-9-]+\.)+(?:[A-Z]{2}|com|org|net|gov|mil|biz|info|mobi|name|aero|jobs|museum)$/i)
      @user = User.find_by_email!(params[:user_activation][:email])
      @account.accepts_role "staff", @user
      flash[:user_activation_notice] = "#{@user.name} is officially a staff member."
    rescue ArgumentError
      flash[:user_activation_notice] = "Sorry, can't work with that, it's not an email address"  
    rescue ActiveRecord::RecordNotFound => new_account_user # Catch brand new users, raised by User.find_by_email!
      @user = User.new(params[:user_activation]) 
      @user.account = @account # attr_protected means we must make this explicit 
      if @user.save_as_inactive(false)
        @user.deliver_user_activation_instructions!
        flash[:user_activation_notice] = "Account invitation emailed"
      else
        flash[:user_activation_notice] = "Error sending email"
      end
    ensure
      @user_activations = User.find(:all, :conditions => "account_id=#{@account.id} AND created_at = updated_at") 
      render :partial => 'accounts/users_window'
    end
  end 
   
   def edit 
     @account = @user.account # find_account filter is skipped for this controller 
     render :layout => 'login' 
   end  
   
   def update
     begin
       @user.update_attributes!(params[:user])
     rescue ActiveRecord::RecordInvalid => invalid
        render :action=>"edit", :layout=>'login'
     else
       @user.account.accepts_role "staff", @user
       flash[:notice] = "Welcome to Hot Ink!"
       redirect_to account_articles_url(@user.account)
     end
   end
   
   # A no complaints ajax destroy function
   def destroy
     begin     
       @user = User.find(params[:id])
       @user.destroy
       flash[:notice] = "Invitation revoked"
     rescue
       flash[:notice] = "Error: Invitation NOT revoked"
     ensure
       @account = find_account
       @user_activations = User.find(:all, :conditions => "account_id=#{@account.id} AND created_at = updated_at") 
       render :partial => 'accounts/users_window'
     end
   end
   
   
   private 
   
   def load_user_using_perishable_token  
     # Make user activation url valid for 1 full day.
     @user = User.find_using_perishable_token(params[:id], 1.day)  
     unless @user  
       flash[:notice] = "We're sorry, but we could not locate your account. " +  
       "If you are having issues try copying and pasting the URL " +  
       "from your email into your browser or restarting the " +  
       "process."  
       redirect_to root_url  
     end
   end
   
   #Catch sneaky new-account-activation users who want access to this account.
   def check_user_qualifications
     redirect_to edit_account_activation_url(@user.perishable_token) and return unless @user.account
   end
   
end
