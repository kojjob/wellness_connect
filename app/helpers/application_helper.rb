module ApplicationHelper
  # Helper methods for Turbo Stream flash integration
  def turbo_stream_flash(type, message)
    turbo_stream.append "flash-container", partial: "shared/toast", locals: { type: type.to_sym, message: message }
  end

  def render_turbo_flash(type, message)
    render turbo_stream: turbo_stream_flash(type, message)
  end

  def toast_html(type, message)
    render_to_string partial: "shared/toast", locals: { type: type.to_sym, message: message }
  end
end
