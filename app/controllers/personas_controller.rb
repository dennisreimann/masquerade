class PersonasController < ApplicationController
	
	before_filter :login_required
	before_filter :find_account
	before_filter :find_persona, :only => [:show, :edit, :update, :destroy]
	before_filter :store_return_url, :only => [:new, :edit]
	
	def index
		@personas = @account.personas.find(:all)

		respond_to do |format|
			format.html
		end
	end
	
	def new
		@persona = @account.personas.new

		respond_to do |format|
			format.html
		end
	end
	
	def create	
		@persona = @account.personas.new(params[:persona])

		respond_to do |format|
			begin
				@persona.save!
				flash[:notice] = t(:persona_successfully_created)
				format.html { redirect_back_or_default account_personas_path }
			rescue ActiveRecord::RecordInvalid
				format.html { render :action => "new" }
			end
		end
	end
	
	def update
		respond_to do |format|
			begin
				@persona.update_attributes(params[:persona])
				flash[:notice] = t(:persona_updated)
				format.html { redirect_back_or_default account_personas_path }
			rescue ActiveRecord::RecordInvalid, ActiveRecord::MultiparameterAssignmentErrors
				format.html { render :action => "edit" }
			end
		end
	end
	
	def destroy
		respond_to do |format|
			begin
				@persona.destroy
			rescue Persona::NotDeletable
				flash[:error] = t(:persona_cannot_be_deleted)
			end
			format.html { redirect_to account_personas_path }
		end
	end
	
	private
	
	def find_persona
		@persona = @account.personas.find(params[:id])
	end
	
	def redirect_back_or_default(default)
		case session[:return_to]
		when decide_path then redirect_to decide_path(:persona_id => @persona.id)
	  else super(default)
    end
	end
	
  def store_return_url
    store_location(params[:return]) unless params[:return].blank?
  end
	
end
