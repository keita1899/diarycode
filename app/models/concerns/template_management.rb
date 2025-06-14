module TemplateManagement
  extend ActiveSupport::Concern

  def assign_default_template(template)
    return unless templates.include?(template)

    update!(default_template: template)
  end

  def clear_default_template
    update!(default_template: nil)
  end

  def has_default_template?
    default_template.present?
  end
end
