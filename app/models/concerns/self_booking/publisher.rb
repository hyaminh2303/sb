module SelfBooking
  module Publisher
    extend ActiveSupport::Concern

    included do
      def publish(event)
        targets = listeners[event]
        if targets
          targets.each do |target|
            target.call(self)
          end
        end
      end

      def on(event, &blk)
        listeners[event] ||= []
        listeners[event] << blk
      end

      def listeners
        @listeners ||= {}
      end
    end
  end
end