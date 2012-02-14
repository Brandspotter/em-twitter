require 'uri'
require 'simple_oauth'
require 'em-twitter/decoders/base_decoder'
require 'em-twitter/decoders/gzip_decoder'


module EventMachine
  module Twitter
    class Request

      attr_reader :proxy, :options

      def initialize(options = {})
        @options = options
        @proxy = Proxy.new(@options.delete(:proxy)) if @options[:proxy]
      end

      def to_s
        content = query

        data = []
        data << "#{@options[:method]} #{request_uri} HTTP/1.1"
        data << "Host: #{@options[:host]}"
        data << 'Accept: */*' unless gzip?
        data << 'Accept-Encoding: gzip' if gzip?
        data << "User-Agent: #{@options[:user_agent]}" if @options[:user_agent]
        if put_or_post?
          data << "Content-type: #{@options[:content_type]}"
          data << "Content-length: #{content.length}"
        end
        data << "Authorization: #{oauth_header}"
        data << "Proxy-Authorization: Basic #{proxy.header}" if proxy?

        @options[:headers].each do |name, value|
          data << "#{name}: #{value}"
        end

        data << "\r\n"
        data = data.join("\r\n")
        data << content if post? || put?
        data
      end

      def proxy?
        @proxy
      end

      def decoder
        gzip? ? GzipDecoder.new : BaseDecoder.new
      end

      private

      def get?
        @options[:method].upcase == 'GET'
      end

      def post?
        @options[:method].upcase == 'POST'
      end

      def put?
        @options[:method].upcase == 'PUT'
      end

      def put_or_post?
        put? || post?
      end

      def gzip?
        @options[:encoding] && @options[:encoding] == 'gzip'
      end

      def params
        flat = {}
        @options[:params].each do |param, val|
          next if val.to_s.empty? || (val.respond_to?(:empty?) && val.empty?)
          val = val.join(",") if val.respond_to?(:join)
          flat[param.to_s] = val.to_s
        end
        flat
      end

      def query
        params.map do |param, value|
          [param, SimpleOAuth::Header.encode(value)].join("=")
        end.sort.join("&")
      end

      def oauth_header
        SimpleOAuth::Header.new(@options[:method], full_uri, params, @options[:oauth])
      end

      def proxy_uri
        "#{uri_base}:#{@options[:port]}#{path}"
      end

      def request_uri
        proxy? ? proxy_uri : path
      end

      def path
        get? ? "#{@options[:path]}?#{query}" : @options[:path]
      end

      def uri_base
        "#{protocol}://#{@options[:host]}"
      end

      def protocol
        @options[:ssl] ? 'https' : 'http'
      end

      def full_uri
        proxy? ? proxy_uri : "#{uri_base}#{request_uri}"
      end
    end
  end
end