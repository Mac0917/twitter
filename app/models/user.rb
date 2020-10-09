class User < ApplicationRecord
    def self.find_or_create_from_auth(auth)
        provider = auth[:provider]
        uid = auth[:uid]
        nickname = auth[:info][:nickname]
        name = auth[:info][:name]
        image_url = auth[:info][:image]
        description = auth[:info][:description]
        
        self.find_or_create_by(provider: provider, uid: uid) do |user|
          user.nickname = nickname
          user.name = name
          user.image_url = image_url
          user.description = description
        end
    end
end

###find_or_create_byについて

#User.create_or_find_by({name: 'geru') nameが"geru"というデータを作る
# User.create_or_find_by({name: 'geru') nameが"geru"というデータが
# User.count
# => 2


# User.find_or_create_by({name: 'geru') nameが"geru"というデータがないか先にfindしてなかったらcreate
# User.find_or_create_by({name: 'geru')  nameが"geru"というデータがないか先にfindしてあるのでcreateはされない
# User.count
# # => 1


#ハッシュで送られている
# a = { "key1" => "value1", "key2" => "value2" }  取り出し方　a["key1"]
# a = { :key1 => "value1", :key2 => "value2" }               a[:key1]
# a = { key1: "value1", key2: "value2"}                       a[:key1]

# データのときは a.key1でも取れる