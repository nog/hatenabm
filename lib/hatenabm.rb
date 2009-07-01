require 'net/http'
require 'time'
require 'digest/sha1'
require 'base64'

# if using ruby 1.8.3 earlier, define HTTP DELETE Method
if RUBY_VERSION < '1.8.3'
  module Net
    class HTTP
      class Delete < HTTPRequest
        METHOD = 'DELETE'
        REQUEST_HAS_BODY  = false
        RESPONSE_HAS_BODY = true
      end
      def delete(path,initheader = nil)
        res = request(Delete.new(path,initheader))
        res.value unless @newimpl
        res
      end 
    end
  end 
end

class HatenaBM

  HATENA_URL = "b.hatena.ne.jp"
  FEED_PATH = "/atom/feed"
  POST_PATH = "/atom/post"
  EDIT_PATH = "/atom/edit/"

  attr_accessor :user_agent
  DEFAULT_USER_AGENT = "HatenaBM(http://hatenabm.rubyforge.org/)"

  def initialize(options)
    user = options[:user]
    pass = options[:pass]
    @wsse = get_wsse(user, pass)
  end

  def default_header
    {
      "X-Wsse" => @wsse,
      "User-Agent" => user_agent
    }
  end

  def user_agent
    @user_agent || DEFAULT_USER_AGENT
  end

  # Post new bookmark
  def post(options)
    title = options[:title]
    link = options[:link]
    summary = options[:summary] || nil 
    tags = options[:tags] || nil
    header = default_header.merge({
      "Content-Type" => 'application/x.atom+xml; charset="utf-8"', 
    })
    tags = "[#{tags.split(/\s/).join('][')}]" unless tags.nil?

    data =<<-EOF
<?xml version="1.0"?>
<entry xmlns="http://purl.org/atom/ns#">
  <title>#{title}</title>
  <link rel="related" type="text/html" href="#{link}" />
  <summary type="text/plain">#{tags}#{summary}</summary>
</entry>
    EOF

    Net::HTTP.version_1_2
    Net::HTTP.start(HATENA_URL){|http|
      response = http.post(POST_PATH, toutf8(data), header)
      raise "Post Error : #{response.code} - #{response.message}" unless response.code == "201"
      return true
    }
  end

  # Get recent bookmarks
  def recent(option = "")
    header = default_header
    Net::HTTP.version_1_2
    Net::HTTP.start(HATENA_URL){|http|
      response = http.get(FEED_PATH + option, header)
      return response.body
    }
  end

  # Get specified bookmark
  def get(options)
    eid = options[:eid] || nil
    raise "Get Error : Invalid eid" if eid.nil?
    api_path = EDIT_PATH + eid
    header = default_header

    Net::HTTP.version_1_2
    Net::HTTP.start(HATENA_URL){|http|
      response = http.get(api_path, header)
      return response.body
    }
  end

  # Modify specified bookmark
  def modify(options)
    eid = options[:eid] || nil
    title = options[:title] || nil
    tags = options[:tags] || nil
    summary = options[:summary] || nil

    raise "Edit Error : need eid" if eid.nil?

    api_path = EDIT_PATH + eid
    header = default_header.merge({
      "Content-Type" => 'application/x.atom+xml; charset="utf-8"', 
    })
    tags = "[#{tags.split(/\s/).join('][')}]" unless tags.nil?

    data  = "<?xml version=\"1.0\"?>"
    data << "<entry xmlns=\"http://purl.org/atom/ns#\">"
    data << "<title>#{title}</title>" unless title.nil?
    data << "<summary type=\"text/plain\">#{tags}#{summary}</summary>" unless summary.nil?
    data << "</entry>"

    Net::HTTP.version_1_2
    Net::HTTP.start(HATENA_URL){|http|
      response = http.put(api_path, toutf8(data), header)
      raise "Edit Error : #{response.code} - #{response.message}" unless response.code == "200"
      return true
    }

  end

  # Delete specified bookmark
  def delete(options)
    eid = options[:eid] || nil
    raise "Delete Error : Invalid eid" if eid.nil?
    api_path = EDIT_PATH + eid
    header = default_header

    Net::HTTP.version_1_2
    Net::HTTP.start(HATENA_URL){|http|
      response = http.delete(api_path, header)
      raise "Delete Error : #{response.code} - #{response.message}" unless response.code == "200"
      return true
    }
  end

  # Calculate WSSE Header method
  private
  def get_wsse(user, pass)
    created = Time.now.iso8601
    nonce = ''
    20.times do 
      nonce << rand(256).chr
    end
    passdigest = Digest::SHA1.digest(nonce + created + pass)
    %Q|UsernameToken Username="#{user}", PasswordDigest="#{Base64.encode64(passdigest).chomp}", Nonce="#{Base64.encode64(nonce).chomp}", Created="#{created}"|
  end

  def toutf8(str)
    Kconv.toutf8(str)
  end
end
