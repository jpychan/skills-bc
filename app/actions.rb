# Homepage (Root path)

#API LINK: http://skillsbc.vansortium.com
#ROUTES:
#1. GET /mentors
#2. GET /mentors/{id}

get '/' do

 #Make API call to IP API to set default location

  @specialties = ["Python", "JavaScript", "Rails", "React", "Ember", "Angular", "Backbone", "Phonegap", "jQuery", "iOS", "Java", "Ruby", "PHP", "NodeJS", "Linux", "CoffeeScript", "Bash", "SQL", "Vim", "QBasic", "CSS", "Clojure(script)", "UX", "Game development", "LEMP", "HTML", "Sinatra", "Sass", "C/C++", "Meteor", "Lisp", "Beer", "Functional Programming", "NoSQL", "Algorithms", "Mongo", "Devops", "Assembler", "Pascal", "Fortran", "Cobol", "Basic", "Visual Basic", "MongoDB", "Express", "C#", ".Net", "Objective-C", "Swift", "Javascript", "DevOps", ".NET", "Clojure", "Elixir", "Android", "COBOL", "D3", "ThreeJS", "C", "WordPress", "Django", "Spec", "Flask", "Ionic", "Cocoa", "Gulp", "Heroku", "UIKit", "Realm", "Parse", "CoreLocation", "MapKit", "WatchKit", "Spring", "AppKit.", "Matlab"]
  erb :index
end


get '/search' do
  
  #process search params



  #make API call to get all mentors, get JSON back

  #process json, filter the array of mentors by user's search param (name, location and specialties)

  #spit that out to the user

  url = URI("http://skillsbc.vansortium.com/mentors")

  http = Net::HTTP.new(url.host, url.port)

  request = Net::HTTP::Get.new(url)
  request["content-type"] = 'application/x-www-form-urlencoded'
  request["accept"] = 'application/json'
  request["cache-control"] = 'no-cache'

  response = http.request(request)

  mentors = response.read_body

  mentors = JSON.parse(mentors)

  @results = mentors.select do |mentor|
    mentor["specialties"].any? do
      |specialty| specialty == params["specialty"]
    end
  end

  @results
  erb :search
  end


get '/mentor' do

  #make API request to GET /mentors/{id}

  #render relevant information

end