class SitesController < ApplicationController
  
  before_filter :login_required
  before_filter :find_account
  before_filter :find_site, :only => [:edit, :update, :destroy]
  before_filter :find_persona, :only => [:edit, :update, :destroy]
  before_filter :find_personas, :only => [:create, :edit, :update]
  
  def index
    @sites = @account.sites.find(:all, :include => :persona, :order => :url)

    respond_to do |format|
      format.html
    end
  end
  
  def edit
    @site.persona = @account.personas.find(params[:persona_id]) if params[:persona_id]
  end
  
  def update
    respond_to do |format|
      if @site.update_attributes(params[:site])
        flash[:notice] = 'The release policy for this site has been updated.'
        format.html { redirect_to edit_account_site_path(@site) }
      else
        format.html { render :action => 'edit' }
      end
    end
  end
  
  def destroy
    @site.destroy

    respond_to do |format|
      format.html { redirect_to account_sites_path }
    end
  end
  
  private
  
  def find_site
    @site = @account.sites.find(params[:id])
  end
  
  def find_persona
    @persona = @site.persona
  end
  
  def find_personas
    @personas = @account.personas.find(:all, :order => 'title')
  end
  
end
