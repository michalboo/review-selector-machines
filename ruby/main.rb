require "oj"
require "httparty"
require "time"

def reset_list(reviewers)
  reviewers.each { |reviewer| reviewer["reviewing"] = true }
  return reviewers
end

def random_active(list)
  return list.select { |reviewer| reviewer["reviewing"] == true }.sample
end

reviewer_path = "../reviewers.json"
reviewers = Oj.load(File.read(reviewer_path))
config = Oj.load(File.read("../config.json"))

selected = random_active(reviewers) || random_active(reset_list(reviewers))

selected["reviewing"] = false
selected["last_selection"] = Time.now.utc.iso8601
puts selected

HTTParty.post(config["SLACK_WEBHOOK_URL"],
  body: Oj.dump({
    "text" => "Ruby says: #{selected["name"]}",
    "channel" => "#ehco"
  }),
  headers: { "Content-Type" => "application/json" }
)

File.open(reviewer_path, 'w') { |file| file.write(Oj.dump(reviewers, indent: 2))}
