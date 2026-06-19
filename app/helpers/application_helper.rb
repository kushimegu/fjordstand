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
    return false if request.path.start_with?("/conversations")
    return false if @item&.user == current_user

    [ items_path, watches_path ].any? { |path| current_page?(path) } || params[:from].in?(%w[watches items notifications])
  end

  def active_entries_tab?
    current_page?(entries_path) || params[:from] == "entries"
  end

  def active_listings_tab?
    if controller_name == "items" && action_name.in?(%w[show edit]) && params[:from] != "messages"
      return @item&.user == current_user
    end

    [ new_item_path, listings_path ].any? { |path| current_page?(path) } || params[:from] == "listings"
  end

  def active_conversations_tab?
    request.path.start_with?("/conversations") || params[:from] == "messages"
  end
end
