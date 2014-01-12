# Things we need

- Protect helper

Each service has an app and a model that inherits from service

I think it just can be one thing. We don't need them to sign up for markdownToHTMl they just run it.
So how about do away with the service model and just have a Plan and Conversion jobs models that inherit from Conversion
For example, MarkdownToHTML < Conversion. They then have a price. At the end of the billing cycle we count up any
conversions done since the last billing cycle and charge for them.

## Models

- Account
  - Keys
    - public_key, secret
  - plan
- Plan
  - purchasable
  - price
- Conversiona
  - status: failed, succeeded, running
  - associations
    - key
    - account
  - price_per_conversion
  - source_file (mounted using carrierwave)
  - destination_file (mounted using carrierwave)
- MarkdownToHTML
  - markdown_processor: defaults to kramdown
  - 
Files are processed on server but stored on amazon s3. so will need to work out the temp copying for processing somehow. While running just have source and destination point to temp? Maybe we should have a file model and hack some of the s3 stuff manually?

ThHaving so many conversions will get unwieldy quickly so how do we pass hti soff to seprrate apps and just load up the api/jobs in the ruby app. Then pass off to porcessing in something else? 

What if we just have self-contained sinatra apps (only accessible to us) with an API. It takes a conversion job
job and then processes it? Then the padrino app just needs to be API + dashboard etc. All the handling code
will be contained in the sinatra app + gems. Then we just send an http request with the conversion job, it pulls
the info it needs and runs it.

Oh btw I think our socket app could be a seperate app at another domain. Maybe just a sinatra app too.
Share sessiions using redis.

So yeah what happens is padrino app gets a request. Saves a conversion job and tells sinatra app about it. Just the  j ob no other details.

Splitting up the apps like that makes everything simpler.
Streaming app for updates. psdtocss app for psd2css. The main app is the user facing side only the html/js/css, the admin and the user accessible API.

We can package the models in a gem for easy sharing
 
How are we going to alert users? 
Just use redis.publis and send out the json

Live parts of the dashboard can be SSE powered widgets that just recieve JSON. Idea: we should be a SSE + JSON dashboard app that plugins to various APIs.

File store is simple. Rather than write to the destination file we just pull from carrierwave.

@conversion.destination_file = Kramdown::Document.new(source_file.contents).to_html
Should work without any problems.

## TODOS

[x]: make api_auth return headers (actually unnecessary)
I think all we to do is just use @headers = ApiAuth::Headers.new(@request) a maybe fix up the API a bit there. Timestamps could have issues but the only way to check is try it.

[ ]: Add Proc stuff for job quue using Sidekiq
[ ]: Get Sidkiq status stuff implemented
[ ]: figure out the alert streams

This should be enough to dissect the process http://christopheverbinnen.com/real-time-comments-stream-using-rails-4-server-sent-events-sse-and-redis-pubsub/

Format looks like this

http://www.html5rocks.com/en/tutorials/eventsource/basics/#toc-eventname

Use snippet from the following to format output
http://ngauthier.com/2013/02/rails-4-sse-notify-listen.html

[ ]: Figure out text stream plugin for Ryggrad

[ ]: Frontend JS base
  [ ]: Models
    [ ]: Event

## The Process

[ ]: Go over landbook and dribble for inspiration
[ ]: Figure out api_auth headers api. Make sure we can get the correct http headers out of it. Quick question where is the timestamp added? To a header? Do params all come from an 
[ ]: Document the process api_auth headers takes and the rules it follows. Does it re-roder params alphabetically? Just handle the body?

## The Design

We have three elements;

1. Landing page
2. Users dash
3. Conversion landing pages 

### Landing

It can be modeled after viewflux style design. Big header with log + menu on top
then an illustration + tagline and a call to action. We can simply modify this model for each subdomain as well.
Then below that on subdomains is an example and (or) workflow illustration e.g take your file and here is
how you'll use it.

On the main site we will start with an explanation of what the service does. Then what formats we currently support
a list with and icon for each one (like the viewflux list) that then links to the suboodmain

### Dash

We can model the dash off of mailgun and postmark.

### Conversion Pages

The conversion pages will be basic details + pricing + api example (like doc raptor). When logged in
you get a page with a form and settings. Conversion pages will redirect to the subdomain when not logged in.
Subdomain always acts as the landing page for the type. E.g psdtocss.this2that.io.
 wh
Scratch that only the API lives at the main app at /format/to/format. Everything else is at the subdomain.
Where the type icon to type icon logo illustration usually sits is replace with a form when user is logged in.

## API Design

Conversions are actually transactions. We should be able to POST to conversions to get one. /:format/to/:format
is just decoration. After posting to /:format/to/:format we should get a link header with an ID pointing to
/conversions/:id . GET that and we get the status. we should be able to get with the stream type and get a stream 
back. Conversions app will also handle our streaming API. In fact any endpoint should have a stream type route.


API Driven Development can be written along side this2that. Viola. Viola? Seriously K, learn to spell.

We can ulitilize this API driven development to build a contracting service. Get the API of your app built.
Having someone build the backend and you build the frontend keeps things compartemntalized.

Let's use grape + rabl + frontend seerately using middleman for the book. actionHero.js + brunch or assemble for the js version

The main benefit of using the same language is sharing models is say a gem. This means you can do an initial
server side render so no page load issue. For many apps though enough content is static that users won't be annoyed
by the short wait for loading via API calls.

The biggest thing is how do we handle sessions (another reason to use apps with code. rember grape can    simply be mount d to)

http://stackoverflow.com/questions/10960131/authentication-authorization-and-session-management-in-traditional-web-apps-and