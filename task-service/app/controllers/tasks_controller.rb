class TasksController < ApplicationController
  def index
    tasks = Task.where(user_id: current_user_id).order(created_at: :desc)
    render json: tasks, status: :ok
  end

  def show
    task = Task.find_by(id: params[:id], user_id: current_user_id)
    return render json: { error: "Não encontrado" }, status: :not_found if task.nil?

    render json: task, status: :ok
  end

  def create
    task = Task.new(task_params)
    task.user_id = current_user_id
    task.status = "done" if task.status.blank?  

    if task.save
      render json: task, status: :created
    else
      render json: task.errors, status: :unprocessable_entity
    end
  end

  private

  def task_params
    params.require(:task).permit(:workflow_id, :title, :status)
  end
end