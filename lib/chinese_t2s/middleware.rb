module ChineseT2s
  module Middleware
    class TranslationT2s
      def initialize(app)
        @app = app
      end

      def call(env)
        set_lang = env['QUERY_STRING'][/\bset_lang=(\w+)/, 1]

        unless set_lang.nil?
          env['rack.session'].delete('chinese_t2s_lang') if set_lang == 'tw'
          env['rack.session']['chinese_t2s_lang'] = 'cn' if set_lang == 'cn'
        end

        status, headers, bodies = @app.call(env)

        if status == 200 && bodies.present?
          params = env['rack.request.query_hash'] || {}

          if (env['rack.session']['chinese_t2s_lang'] || params['lang']) == 'cn'
            case bodies
            when ActionDispatch::Response # Rails
              body = ChineseT2s::translate(bodies.body)
              bodies.body = body
            when Rack::BodyProxy # Grape
              if defined?(::Rails) && (::Rails::VERSION::MAJOR <= 3) || (::Rails::VERSION::MAJOR == 4 && ::RAILS::VERSION::MINOR == 0)
                body = bodies.body.first
                body.gsub!(/((\\u[0-9a-z]{4})+)/){ $1[2..-1].split('\\u').map{|s| s.to_i(16)}.pack('U*') }
                body = ChineseT2s::translate(body)
                bodies.body = [body]
                headers['Content-Length'] = body.bytesize.to_s
              end
            when Sprockets::ProcessedAsset
            end
          end
        end

        [status, headers, bodies]
      end
    end
  end
end
