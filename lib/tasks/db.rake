namespace :db do
  desc "import the old Playtime database"
  task :import => :environment do
    data = {}
    File.open("tmp/all.json", "r") { |f| data = ActiveSupport::JSON.decode f.read.strip }
    
    jesters = {}
    Jester.destroy_all
    password = ENV["PASSWORD"] || "password"
    data["jesters"].each do |jester|
      jesters[jester["id"]] = Jester.factory({
        type:                  jester["type"],
        email:                 jester["email"],
        name:                  jester["name"] || "#{jester["first_name"]} #{jester["last_name"][0,1]}.",
        slug:                  jester["slug"],
        active:                jester["active"],
        password:              password,
        password_confirmation: password
      })
      jesters[jester["id"]].save!
    end
    
    notes = {}
    data["notes"].each do |note|
      note = note["note"]
      (notes[note["notable_id"]] ||= []) << Note.new(
        author_id:  jesters[note["author_id"]].id,
        created_at: DateTime.parse(note["updated_at"]),
        updated_at: DateTime.parse(note["updated_at"]),
        content:    note["content"].gsub(/\r/, "")
      )
    end
    
    Show.destroy_all
    shows = {}
    data["shows"].each do |show|
      show = show["show"]
      shows[show["id"]] = Show.date Date.civil(*show["date"].split("-").map { |i| i.to_i(10) })
      shows[show["id"]].notes = notes[show["id"]] || []
    end

    data["players"].each do |player|
      player = player["player"]
      show = shows[player["show_id"]]
      jester = jesters[player["jester_id"]]
      role = player["role"]
      role = "available" if role.blank?
      show.cast[jester.id.to_s] = role
    end
    
    shows.values.each &:save!
    
  end

end
