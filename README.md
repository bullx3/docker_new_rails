docker_new_rails

##Description

docker-composeを使ってrails + mariadb(mysql)環境を新規に作る為のスクリプト。
railsのアプリ名は"myapp"で固定化される
対象のrailsバージョンは5の最新版

$ ./create_rails.sh

を実行すると"rails_app"が作成され、rubyイメージをベースとしたrailsイメージが作成される。railsアプリはホスト(./rails_app)とコンテナ(/myapp)がリンクされる。
実行権限がない場合は権限を付与すること

$ sudo chmod +x create_rails.sh

実際の使用時には以下の内容は変更して使うことを推奨

docker-compose.yml
  web:
    image: local/rails
    restart: always
    container_name: rails

   environment:
      MYAPP_DATABASE_PASSWORD: myappPass  # rails指定するproduct用
      MYAPP_DATABASE_ROOT_PASS: root_pass

 db:
    environment:
      MYSQL_ROOT_PASSWORD: root_pass # mandatory
      MYSQL_PASSWORD: myappPass #optionl
