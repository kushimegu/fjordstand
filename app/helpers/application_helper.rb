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
      label, path = "連絡ページへ", transaction_messages_path(item)
    else
      label, path = "販売中一覧へ", items_path
    end

    link_to path, class: "mt-4 flex items-center justify-center text-sm text-gray-500 hover:text-gray-700 underline" do
      label
    end
  end
end
