class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :notifiable, polymorphic: true

  scope :unread, -> { where(read: false) }
  scope :by_target, ->(target) {
  if target == "unread"
    where(read: false)
  else
    all
  end
  }

  def message
    case notifiable
    when Message
      "#{notifiable.item.other_user_for(user).name}さんからメッセージが届きました。"
    when Entry
      entry_notification_message
    when Item
      item_notification_message
    end
  end

  def url
    case notifiable
    when Message
      Rails.application.routes.url_helpers.transaction_messages_path(notifiable.item)
    when Entry
      Rails.application.routes.url_helpers.transaction_messages_path(notifiable.item)
    when Item
      if notifiable.sold?
        Rails.application.routes.url_helpers.transaction_messages_path(notifiable)
      else
        Rails.application.routes.url_helpers.item_path(notifiable)
      end
    end
  end

  private

  def entry_notification_message
    if notifiable.won?
      "「#{notifiable.item.title}」の抽選に当選しました！連絡ページから出品者へご連絡ください。"
    else
      "「#{notifiable.item.title}」の抽選に落選しました。"
    end
  end

  def item_notification_message
    if notifiable.sold?
      "「#{notifiable.title}」の抽選が完了し、当選者が決まりました。"
    else
      "「#{notifiable.title}」に購入希望者がいなかったため当選者なしで公開終了しました。"
    end
  end
end
