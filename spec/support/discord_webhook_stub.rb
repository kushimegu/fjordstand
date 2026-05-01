module DiscordWebhookStub
  def stub_discord_webhook
    stub_request(:post, /discord\.com\/api\/webhooks/).to_return(status: 200)

    webhook = instance_double(DiscordWebhook)

    [
    :notify_item_published,
    :notify_item_closed,
    :notify_item_deadline_extended,
    :notify_lottery_completed,
    :notify_lottery_skipped,
    :notify_new_comment,
    :notify_new_message
    ].each do |method|
      allow(webhook).to receive(method)
    end

    allow(DiscordWebhook).to receive(:new).and_return(webhook)

    webhook
  end
end
