rails_dir=rails_app

echo "このスクリプトは新規にrailsを作成する場合に使用します"
echo "すでに"$rails_dir"ディレクトリにアプリがある場合はnを入力してください"

read -p "作成しますか? (Y/n): " yn
case "$yn" in [yY]*) ;; *) echo "abort." ; exit ;; esac

if [ ! -d $rails_dir ]; then
	echo "ディレクトリ＜"$rails_dir"＞が存在しません"
	echo "ディレクトリ＜"$rails_dir"＞を作成します"
	mkdir $rails_dir
fi

if [ -n "$(ls $rails_dir)" ]; then
	echo "ディレクトリ＜"$rails_dir"＞にファイルが存在します" 1>&2
	exit 1
fi


echo "Gemfile,Gemfile.lock作成"
cat <<'EOF' > $rails_dir/Gemfile
source 'https://rubygems.org'
gem 'rails', '~>5'
EOF

touch $rails_dir/Gemfile.lock

# image作成（一回目）
echo "イメージ作成"
docker-compose build


# docker内でrails newコマンドを行い、新規railsを作成
echo "railsアプリケーションを作成します"
docker-compose run --rm web rails new . --force --no-deps --database=mysql --skip-bundle


# Gemfileが変わったのでimage作成（二回目回目）
echo "イメージ更新"
docker-compose build

# config/databse.yml変更
echo "database.yml変更"
cd $rails_dir
cat config/database.yml | sed "s/password:$/password: <%= ENV['MYAPP_DATABASE_ROOT_PASS'] %>/" | sed "s/host: localhost/host: <%= ENV['MYAPP_DATABASE_HOST'] %>/" > __tmpfile__
cat __tmpfile__ > config/database.yml
rm __tmpfile__
cd ..


# db作成
echo "DB作成"
docker-compose run --rm web rails db:create

echo "docker-compose up -d"
docker-compose up -d