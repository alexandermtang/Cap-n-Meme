require 'open-uri'
require 'sinatra'
require 'meme_captain'
require 'twilio-ruby'
require 'aws/s3'
require 'rubygems'

AWS::S3::Base.establish_connection!(
    :access_key_id     => 'AKIAIF6ZOMLKMRB4Z4CQ',
    :secret_access_key => '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'
)

@account_sid = 'AC1e5f6361a7ea53bc429b1918a5df43b4'
@auth_token = '5669d66439fb05d78d20f0da3b7146f3'

client = Twilio::REST::Client.new(@account_sid, @auth_token)

post '/' do
  ready_to_go = false
  str = ''
  to = ''
  while(!ready_to_go)
    str = params["Body"].to_s.chomp.split(',')
    if(str != '')
      ready_to_go = true
    else
      sleep(1)
    end
  end
  to = params["From"].to_s
	link = ('http://memecaptain.com/' + str[0].downcase + '.jpg')
  AWS::S3::Bucket.delete('memehackny', :force => true)
  AWS::S3::Bucket.create('memehackny', :access => :public_read_write)
	open(link, 'rb') do |pic|
  	  i = MemeCaptain.meme_top_bottom(pic, str[1], str[2])
   	  i.write('meme.jpg')
      AWS::S3::S3Object.store('meme.jpg',open('meme.jpg'),'memehackny', :access => :public_read)
  end
  @account = client.account
  @message = @account.sms.messages.create({:from => '+19082147050', :to => to,  :body => 'Your meme! : http://s3.amazonaws.com/memehackny/meme.jpg'})
end

get '/' do
	content_type 'image/jpg'
	return open('meme.jpg')
end

