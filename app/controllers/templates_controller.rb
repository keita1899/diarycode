class TemplatesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_template, only: [:edit, :update, :destroy]

  def index
    @templates = current_user.templates.order(created_at: :desc)
  end

  def new
    @template = current_user.templates.build
  end

  def create
    @template = current_user.templates.build(template_params)

    if @template.save
      redirect_to templates_path, notice: t("flash.templates.create.notice")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @template.update(template_params)
      redirect_to templates_path, notice: t("flash.templates.update.notice")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @template.destroy!
    redirect_to templates_path, notice: t("flash.templates.destroy.notice")
  end

  private

    def set_template
      @template = current_user.templates.find(params[:id])
    end

    def template_params
      params.require(:template).permit(:title, :body)
    end
end
