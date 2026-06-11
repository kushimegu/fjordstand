module ApplicationHelper
  def page_title(page_title = "")
    base_title = "FjordStand"

    page_title.empty? ? base_title : "#{page_title} | #{base_title}"
  end

  def back_link_for_item(item)
    case params[:from]
    when "watches"
      label, path = "Watch中一覧へ", watches_path
    when "entries"
      label, path = "希望商品一覧へ", entries_path
    when "listings"
      label, path = "自分の出品一覧へ", listings_path
    when "messages"
      label, path = "連絡ページへ", conversation_messages_path(item)
    else
      label, path = "販売中一覧へ", items_path
    end

    link_to path, class: "mt-4 flex items-center justify-center text-sm text-gray-500 hover:text-gray-700 underline" do
      label
    end
  end

  def active_items_tab?
    return true if [ items_path, watches_path ].any? { |path| current_page?(path) }

    %w[from=watches from=items from=notifications].any? { |param| request.fullpath.include?(param) }
  end

  def active_entries_tab?
    current_page?(entries_path) || request.fullpath.include?("from=entries")
  end

  def active_listings_tab?
    return true if [ new_item_path, listings_path ].any? { |path| current_page?(path) }
    return true if request.path.match?(%r{\A/items/\d+/edit\z})

    request.fullpath.include?("from=listings")
  end

  def active_conversations_tab?
    [ conversations_path, conversation_messages_path ].any? { |path| current_page?(path) } || request.fullpath.include?("from=messages")
  end
end
