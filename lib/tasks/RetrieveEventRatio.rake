desc "Retrieve the female to male ratio of the Facebook events from the current user and friends"
task :retrieve_event_ratio => :environment do
  require 'rubygems'
  require 'koala'
  require 'certified'

  # oauth_token = ENV["OATH_TOKEN"]
  graph = Koala::Facebook::API.new("CAACEdEose0cBAF3sFDmOWZCCVljauEtVxdz7jZAQlvYXR29B9LMLK1h4hgpZCwt9bougeuGFDxkRiXDKEPWbeuwn7LpulO0sNx1ZAWsN2KiszoZAGdbqrxVXtte0FZByRYR9YJJuZBGmAJ8lnkmk6YLeKjIK9KTa9niu2ZC6YoZBZB4gZDZD")

  all_events = graph.get_object("me?fields=id,name,events,friends.fields(events.limit(14).fields(id))")
  #puts all_events

  all_event_ids = []

  all_events["friends"]["data"].each do |friend|
    # next if gaat naar de volgende itteratie binnen de array
    next if friend["events"] == nil
    friend["events"]["data"].each do |event|
      all_event_ids << event["id"]
    end
  end

  top_events = []
  # De array all_event_ids worden de duplicaten uit gegooid en daarna in de loop each gesmeten 
  all_event_ids.uniq.each do |id|
    event_count = graph.fql_query("SELECT attending_count<200 FROM event WHERE eid ="+id+"")
    # the key 'anon' is op positie nul (0) in de array uit event_count
    next if event_count[0]["anon"] == false
    all_invited_people = graph.get_object("/"+id+"/attending?fields=name,id,rsvp_status,gender")
    # add event_id
    all_invited_people_with_event_id = all_invited_people.unshift(id)
    all_genders = all_invited_people_with_event_id.map {|h| h["gender"] }
    x = all_genders.count("female").to_f / all_genders.count("male").to_f
    top_events = x.round(1)
    p top_events
  end
  puts "completed"
end