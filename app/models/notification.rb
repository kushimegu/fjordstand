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
      "#{notifiable.item.other_user_for(user).name}さんから「#{notifiable.item.title}」についてメッセージが届きました。"
    when Entry
      entry_notification_message
    when Item
      item_notification_message
    end
  end

  def link
    case notifiable
    when Message
      Rails.application.routes.url_helpers.transaction_messages_path(notifiable.item)
    when Entry
      entry_notification_link
    when Item
      item_notification_link
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
      "「#{notifiable.title}」の抽選が完了し、当選者が決まりました。連絡ページから当選者へご連絡ください。"
    else
      "「#{notifiable.title}」は当選者なしで公開終了しました。"
    end
  end

  def entry_notification_link
    if notifiable.won?
      Rails.application.routes.url_helpers.transaction_messages_path(notifiable.item)
    else
      Rails.application.routes.url_helpers.item_path(notifiable.item)
    end
  end

  def item_notification_link
    if notifiable.sold?
      Rails.application.routes.url_helpers.transaction_messages_path(notifiable)
    else
      Rails.application.routes.url_helpers.item_path(notifiable)
    end
  end
end
