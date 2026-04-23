module FlashHelper
  def css_class_for_flash(flash_type)
    case flash_type.to_sym
    when :alert
      "bg-red-50 text-red-700 border-red-200"
    else
      "bg-cyan-50 text-cyan-700 border-cyan-200"
    end
  end
end
