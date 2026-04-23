module ItemsHelper
  def shipping_fee_class(payer)
    case payer
    when "seller"
      "text-red-400"
    else
      "text-gray-600"
    end
  end

  ITEM_STATUS_BADGE = {
    "draft" => { text: "下書き", css: "bg-gray-400" },
    "published" => { text: "出品中", css: "bg-cyan-500" },
    "sold" => { text: "購入者決定", css: "bg-red-500" },
    "closed" => { text: "公開終了", css: "bg-gray-400" }
  }.freeze

  ENTRY_STATUS_BADGE = {
    "applied" => { text: "購入希望", css: "bg-cyan-500" },
    "won" => { text: "購入確定", css: "bg-red-500" },
    "lost" => { text: "落選", css: "bg-gray-400" }
  }.freeze

  def item_status_badge(item)
    ITEM_STATUS_BADGE[item.status]
  end

  def entry_status_badge(entry)
    ENTRY_STATUS_BADGE[entry.status]
  end
end
