module FlashHelper
  def css_class_for_flash(flash_type)
    case flash_type.to_sym
    when :alert
      "bg-red-100 text-red-600"
    else
      "bg-cyan-100 text-cyan-600"
    end
  end
end
