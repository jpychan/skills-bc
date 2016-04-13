helpers do
  def set_user_location
    if !session["location"]
      session["location"] = {
        lat: '49.246292',
        lng: '-123.116226',
        city: "Vancouver",
        state: "BC"
      }
    end
  end

  def set_search
    @specialties = ["Any", "Python", "JavaScript", "Rails", "React", "Ember", "Angular", "Backbone", "Phonegap", "jQuery", "iOS", "Java", "Ruby", "PHP", "NodeJS", "Linux", "CoffeeScript", "Bash", "SQL", "Vim", "QBasic", "CSS", "Clojure(script)", "UX", "Game development", "LEMP", "HTML", "Sinatra", "Sass", "C/C++", "Meteor", "Lisp", "Beer", "Functional Programming", "NoSQL", "Algorithms", "Mongo", "Devops", "Assembler", "Pascal", "Fortran", "Cobol", "Basic", "Visual Basic", "MongoDB", "Express", "C#", ".Net", "Objective-C", "Swift", "Javascript", "DevOps", ".NET", "Clojure", "Elixir", "Android", "COBOL", "D3", "ThreeJS", "C", "WordPress", "Django", "Spec", "Flask", "Ionic", "Cocoa", "Gulp", "Heroku", "UIKit", "Realm", "Parse", "CoreLocation", "MapKit", "WatchKit", "Spring", "AppKit.", "Matlab"]
    @distances = ['Any', 1, 5, 10, 25, 50]
  end

  def api_call(url)

    http = Net::HTTP.new(url.host, url.port)

    request = Net::HTTP::Get.new(url)
    request["content-type"] = 'application/x-www-form-urlencoded'
    request["accept"] = 'application/json'
    request["cache-control"] = 'no-cache'

    response = http.request(request)

    JSON.parse(response.read_body)

  end

  def to_radians(deg)   
    deg.to_f/180.0 * Math::PI
  end

  def calc_distance(o_lat, o_long, m_lat, m_lng)
    orig_lat = to_radians(o_lat)
    orig_lng = to_radians(o_long)
    dest_lat = to_radians(m_lat)
    dest_lng = to_radians(m_lng)

    lat_diff = dest_lat - orig_lat
    lng_diff = dest_lng - orig_lng

    pt_dist = (Math.sin(lat_diff/2))**2 + Math.cos(orig_lat) * Math.cos(dest_lat) * (Math.sin(lng_diff/2))**2
    central_angle = 2 * Math.atan2(Math.sqrt(pt_dist), Math.sqrt(1-pt_dist))
    6371 * central_angle
  end

  def search_by_name(name_input, mentors)
    mentors.select do |mentor|
      first_name = mentor["first_name"]
      last_name = mentor["last_name"]
      if first_name && last_name
        first_name.downcase == name_input || last_name.downcase == name_input
      elsif first_name
        first_name.downcase == name_input
      elsif last_name
        last_name.downcase == name_input
      end
    end
  end

  def search_by_specialty(specialty, mentors)
    mentors.select do |mentor|
      mentor["specialties"].any? do
        |specialty| specialty == params["specialty"]
      end
    end
  end

  def search_by_distance(distance, mentors, session)
    # byebug
    distance = params["distance"].to_i
    user_lat = session["location"][:lat]
    user_lng = session["location"][:lng]

    mentors = mentors.select do |result|
      dist_km = calc_distance(user_lat, user_lng, result["location"][0], result["location"][1])
      dist_km <= distance
    end
  end

  def get_mentor_details(mentors)
    @details = []
    mentors.each do |mentor|
      url = URI("http://skillsbc.vansortium.com/mentors/#{mentor['_id']}")
      details = api_call(url)
      @details << details
    end

    @details
  end

end

# Homepage (Root path)

#API LINK: http://skillsbc.vansortium.com
#ROUTES:
#1. GET /mentors
#2. GET /mentors/{id}

before do
  set_user_location
  set_search
end

get '/static' do

  erb :search
end

get '/' do

 #Make API call to IP API to set default location

  erb :index
end


get '/search' do

  #process search params

  #make API call to get all mentors, get JSON back

  #process json, filter the array of mentors by user's search param (name, location and specialties)

  #spit that out to the user

  #API CALL

  url = URI("http://skillsbc.vansortium.com/mentors")

  @mentors = api_call(url)

  #Filter @mentors by params
  if params["name"].length > 0
    @mentors = search_by_name(params["name"].downcase, @mentors)
  end

  #FILTER BY SPECIALTY

  if params["specialty"] != 'Any'
    @mentors = search_by_specialty(params["specialty"], @mentors)
  end

  #FILTER BY DISTANCE
  if params["distance"] != 'Any'
    @mentors = search_by_distance(params["distance"], @mentors, session)
  end

  if @mentors.length == 0
    @error = "No mentor matched your search criteria, please try again."
  end

  # byebug

  if @mentors.length > 10
    i = 0
    @mentors_with_details = []
    while i < 10
      @mentors_with_details << @mentors[i]
      i += 1
    end
    @mentors_with_details = get_mentor_details(@mentors_with_details)
  end

  @mentors_with_details = get_mentor_details(@mentors)
  
  # byebug
  
  puts @mentors_with_details

  erb :search

end


get '/mentor' do

  # erb :mentor_details, :layout => false

  #make API request to GET /mentors/{id}

  #render relevant information

end