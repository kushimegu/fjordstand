module NotificationsHelper
  class Strategy
    include Rails.application.routes.url_helpers

    def initialize(notification)
      @notification = notification
    end

    def notifiable
      @notification.notifiable
    end

    def self.resolve_redirect_path(notification)
      build_strategy(notification).redirect_path
    end

    def self.resolve_message(notification)
      build_strategy(notification).message
    end

    class << self
      private

      def build_strategy(notification)
        klass =
          case notification.notifiable
          in Comment
            CommentStrategy
          in Entry
            EntryStrategy
          in Item
            ItemStrategy
          in Message
            MessageStrategy
          end
        klass.new(notification)
      end
    end

    class CommentStrategy < Strategy
      def message
        "#{notifiable.user.name}さんが「#{notifiable.item.title}」についてコメントしました。"
      end

      def redirect_path
        item_path(notifiable.item)
      end
    end

    class EntryStrategy < Strategy
      def message
        if notifiable.won?
          "「#{notifiable.item.title}」の購入が確定しました！連絡ページから出品者へご連絡ください。"
        else
          "「#{notifiable.item.title}」の抽選に落選しました。"
        end
      end

      def redirect_path
        if notifiable.won?
          conversation_messages_path(notifiable.item)
        else
          item_path(notifiable.item)
        end
      end
    end

    class ItemStrategy < Strategy
      def message
        if notifiable.sold?
          "「#{notifiable.title}」の購入者が決まりました。連絡ページから購入者へご連絡ください。"
        else
          "「#{notifiable.title}」は当選者なしで公開終了しました。"
        end
      end

      def redirect_path
        if notifiable.sold?
          conversation_messages_path(notifiable)
        else
          item_path(notifiable)
        end
      end
    end

    class MessageStrategy < Strategy
      def message
        "#{notifiable.user.name}さんから「#{notifiable.item.title}」についてメッセージが届きました。"
      end

      def redirect_path
        conversation_messages_path(notifiable.item)
      end
    end
  end
end
