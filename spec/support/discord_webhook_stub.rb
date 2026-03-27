module DiscordWebhookStub
  def stub_discord_webhook
    webhook = instance_double(DiscordWebhook)
    allow(webhook).to receive(:notify_item_published)
    allow(webhook).to receive(:notify_item_closed)
    allow(webhook).to receive(:notify_item_deadline_extended)
    allow(webhook).to receive(:notify_lottery_completed)
    allow(webhook).to receive(:notify_lottery_skipped)
    allow(webhook).to receive(:notify_new_comment)
    allow(webhook).to receive(:notify_new_message)

    allow(DiscordWebhook).to receive(:new).and_return(webhook)
  end
end
