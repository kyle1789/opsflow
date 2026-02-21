class PlansController < ApplicationController
  # Esse endpoint deve ser protegido (token válido)
  def from_intent
    intent_id = params[:intent_id]
    text      = params[:text]

    # validação mínima (pra não enfileirar lixo)
    return render json: { error: "intent_id obrigatório" }, status: :bad_request if intent_id.blank?
    return render json: { error: "text obrigatório" }, status: :bad_request if text.blank?

    # Enfileira o job (isso vai pro Redis)
    PlanFromIntentJob.perform_async(intent_id, current_user_id, text, request.headers["Authorization"])
    # 202 = aceito, vou processar em background
    render json: { status: "accepted", intent_id: intent_id }, status: :accepted
  end
end
