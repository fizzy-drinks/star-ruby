model(users) {
  id { string { SecureRandom.uuid } }
  username { required string }
  password { required string }
}

model(tokens) {
  value { string { Base64.encode64(SecureRandom.uuid).strip } }
  user_id { required string }
  issued { date { DateTime.now } }
}

model(tasklists) {
  id { string { SecureRandom.uuid } }
  name { required string }
  user_id { required string }
}

model(tasks) {
  id { string { SecureRandom.uuid } }
  title { required string }
  description { string { "" } }
  tasklist_id { required string }
  created_at { date { DateTime.now } }
  modified_at { date { DateTime.now } }
  date_due { date { DateTime.now } }
  closed_at { date }
  deleted_at { date }
}
