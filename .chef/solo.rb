base = File.expand_path("../..", __FILE__)

cookbook_path [File.expand_path("cookbooks", base), File.expand_path("site-cookbooks", base)]
json_attribs  File.expand_path("node.json", base)
role_path     File.expand_path("roles", base)
data_bag_path File.expand_path("data_bags", base)
#encrypted_data_bag_secret "data_bag_key"

