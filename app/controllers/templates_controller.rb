class TemplatesController < ApplicationController
  before_action :authenticate_user!

  def new
    @template = current_user.templates.build
  end

  def create
    @template = current_user.templates.build(template_params)

    if @template.save
      redirect_to calendar_path, notice: t("flash.templates.create.notice")
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

    def template_params
      params.require(:template).permit(:title, :body)
    end
end
