class WorkflowsController < ApplicationController
  
    def index
    workflows = Workflow.where(user_id: current_user_id).order(created_at: :desc)
    render json: workflows, status: :ok
    end


    def show
      workflow = Workflow.find_by(id: params[:id], user_id: current_user_id)
      return render json: { error: "Não encontrado" }, status: :not_found if workflow.nil?

      render json: workflow, status: :ok
    end
  
      def create
        workflow = Workflow.new(workflow_params)
        workflow.user_id = current_user_id
        workflow.status = "planned" if workflow.status.blank?
      
        if workflow.save
          render json: workflow, status: :created
        else
          render json: workflow.errors, status: :unprocessable_entity
        end

      end

  private

  def workflow_params
    params.require(:workflow).permit(:intent_id, :title, :status)
  end

end
