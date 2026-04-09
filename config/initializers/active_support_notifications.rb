Rails.application.reloader.to_prepare do
  ActiveSupport::Notifications.subscribe "comment.created" do |*args|
    event = ActiveSupport::Notifications::Event.new(*args)
    comment = event.payload[:comment]
    item = comment.item
    recipients = item.watchers.where.not(id: comment.user_id)
    next if recipients.empty?
    DiscordWebhook.new.notify_new_comment(recipients, item)
    recipients.each do |recipient|
      Notification.create!(user: recipient, notifiable: comment)
    end
  end

  ActiveSupport::Notifications.subscribe "message.created" do |*args|
    event = ActiveSupport::Notifications::Event.new(*args)
    message = event.payload[:message]
    item = message.item
    recipient = item.other_user_for(message.user)
    next if recipient.nil?
    DiscordWebhook.new.notify_new_message(recipient, item)
    Notification.create!(user: recipient, notifiable: message)
  end

  ActiveSupport::Notifications.subscribe "item.published" do |*args|
    event = ActiveSupport::Notifications::Event.new(*args)
    item = event.payload[:item]
    DiscordWebhook.new.notify_item_published(item)
  end

  ActiveSupport::Notifications.subscribe "item.deadline_extended" do |*args|
    event = ActiveSupport::Notifications::Event.new(*args)
    item = event.payload[:item]
    DiscordWebhook.new.notify_item_deadline_extended(item.applicants, item)
  end

  ActiveSupport::Notifications.subscribe "item.closed" do |*args|
    event = ActiveSupport::Notifications::Event.new(*args)
    item = event.payload[:item]
    reason = event.payload[:reason]
    applicants = item.applicants
    case reason
    when :user_action
      DiscordWebhook.new.notify_item_closed(applicants, item)
      applicants.each do |applicant|
        Notification.create!(user: applicant, notifiable: item)
      end
    when :no_applicants
      DiscordWebhook.new.notify_lottery_skipped(item.user, item)
      Notification.create!(user: item.user, notifiable: item)
    end
  end

  ActiveSupport::Notifications.subscribe "lottery.completed" do |*args|
    event = ActiveSupport::Notifications::Event.new(*args)
    item = event.payload[:item]
    seller = item.user
    recipients = item.applicants + [ seller ]
    DiscordWebhook.new.notify_lottery_completed(recipients, item)
    item.entries.each do |entry|
      Notification.create!(user: entry.user, notifiable: entry)
    end
    Notification.create!(user: seller, notifiable: item)
  end
end
