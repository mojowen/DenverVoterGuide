require 'json'
require 'erb'

def mayor_data
    return JSON::parse(File.read('data/mayors.json'))
end
def other_data
    JSON::parse(File.read('data/other.json')).group_by{ |can| can['office'] }
end
def counselor_data
    districts = JSON::parse(File.read('data/districts.json'))
    counselors = JSON::parse(File.read('data/counselors.json'))

    questions = counselors.first.keys.reject{ |k| k[-1] != "?" }.map(&:to_s)
    districts.each do |district|
        district['counselors'] = counselors.select do |counselor|
            counselor['district'] == district['district']
        end
    end
    return districts, questions, counselors
end
def _get_ordinal n
    n = n.to_i
    s = ["th","st","nd","rd"]
    v = n % 100
    "#{n}#{(s[(v-20)%10]||s[v]||s[0])}"
end

class Controller

    def set_meta meta_data=nil
        meta_data ||= {}

        default_description = ("Vote by Tuesday, May 5th in the Denver City "+
                               "Election. Check out our voter guide to see "+
                               "who will be on your ballot.")

        default_title = 'Denver Voter Guide'

        default_image = 'http://www.denvervoterguide.org/images/shareable.png'

        @meta = {
            "title" => meta_data['title'] || default_title,
            "description" => meta_data['description'] || default_description,
            "image" => ("#{meta_data['image'] || default_image}"),
            "url" => (meta_data['url'] || 'http://www.denvervoterguide.org'),
            "twitter_name" => 'neweracoaction',
            "twitter_hashtag" => 'denvervotes',
        }
        render('_meta.erb')
    end

    def filename
        @filename
    end

    def index
        @election_day = 'Tuesday, May 5th'
        @title = '2015 Denver City Election'
        @meta_partial = set_meta

        @other_offices = other_data
        @mayors = mayor_data
        @districts, @questions = counselor_data()
    end

    def mayor mayor
        base = "http://www.denvervoterguide.org"

        @anchor = mayor["name"].downcase.gsub(' ','-').gsub(/[^a-zA-Z0-9\-]/,'')
        @filename = "mayor/#{@anchor}"
        @meta_partial = set_meta({
            'url' => "#{base}/sharing/#{@filename}",
            'image' => "#{base}#{mayor['photo'].gsub(' ','%20')}",
            'title' => "Vote for #{mayor['name']} for Mayor of Denver",
            'description' => ("I'm supporting #{mayor['name']} for Mayor of "+
                              "Denver"),
        })
    end

    def counselor counselor
        base = "http://www.denvervoterguide.org"

        name = counselor['name']
        link = name.downcase.gsub(' ','-').gsub(/[^a-zA-Z0-9\-]/,'')

        office = "City Counselor"

        @anchor =  "@#{counselor['district']}"
        @filename = "counselor/#{counselor['district']}-#{link}"

        @meta_partial = set_meta({
            'url' => "#{base}/sharing/#{@filename}",
            'image' => "#{base}/#{counselor['photo'].gsub(' ','%20')}",
            'title' => "Vote #{name} for #{office}",
            'description' => "Vote #{name} for #{office}",
        })
    end
    def other candidate
        base = "http://www.denvervoterguide.org"

        name = candidate['name']
        link = name.downcase.gsub(' ','-').gsub(/[^a-zA-Z0-9\-]/,'')
        office = candidate['office']

        @anchor =  "@#{candidate['office']}"
        @filename = "other/#{link}"

        @meta_partial = set_meta({
            'url' => "#{base}/sharing/#{@filename}",
            'image' => "#{base}/#{candidate['photo'].gsub(' ','%20')}",
            'title' => "Vote #{name} for #{office}",
            'description' => "Vote #{name} for #{office} - and you should too",
        })
    end

    def render path
        ERB.new(File.read(path)).result(binding)
    end
end
