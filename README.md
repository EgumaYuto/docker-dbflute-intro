# docker-dbflute-intro

## Supported tags and respective `Dockerfile` links
- [0.3.3, latest (Dockerfile)](https://github.com/EgumaYuto/docker-dbflute-intro/blob/master/Dockerfile)

## クイックリファレンス
- DBFlute Intro Official Page
http://dbflute.seasar.org/ja/manual/function/generator/intro/index.html
- DBFlute Intro Github Repository
https://github.com/dbflute/dbflute-intro


## この Image の使い方

### DBFlute-Intro のみを起動する場合
```
$ docker run  -p 8926:8926 dbflute/dbflute-intro:latest
```
ただし、DBFlute Intro はローカルに存在するファイルを読み込んだり、変更を加える機能が多くあるため、
この方法で起動して使うことはほぼないと思います。

### ローカルの DBFlute Engine を Client をマウントして起動する
もし、以下のようなプロジェクト構成になっていて、`your-project-dir` がカレントディレクトリになっているとします。
```
your-project-dir
|-...
|
|-dbflute_xxx
|  |-dfprop
|  |-log
|  |-...
|
|-mydbflute
  |-dbflute-1.x.x
```

これらの DBFlute が利用するリソースをコンテナ内部から利用するためには、以下のようなコマンドで起動します。
```
$ docker run  -p 8926:8926 -v $(pwd)/dbflute_xxx:/app/dbflute_xxx -v $(pwd)/mydbflute:/app/mydbflute dbflute/dbflute-intro:latest
```

### Docker Compose を利用する場合
DBFlute-Intro経由で動作しているDBFluteは、度々DBアクセスを行うことがあります。
そのため、DBFlute-Introと同時にMySQLなどのDBを同時に起動することになると思います。

docker-compose.yml ファイルは以下のように記述します。
```
version: '2'
services:

  intro: ######################################################### DBflute-Intro 
    image: dbflute/dbflute-intro
    ports:
      - "8926:8926"
    volumes:
        - ./dbflute_xxx:/app/dbflute_maihamadb/:rw
        - ./mydbflute:/app/mydbflute/:rw
        - ./src:/app/src/:ro
    environment:
      DBFLUTE_ENVIRONMENT_TYPE: "docker"
    links:
      - db
    networks:
      - fortress-net
      
  db: ############################################################ MySQL の設定
    container_name: fortress-mysql
    image: mysql
    command: --default-authentication-plugin=mysql_native_password
    restart: always
    environment:
      MYSQL_ALLOW_EMPTY_PASSWORD: "yes"
      MYSQL_DATABASE: "maihamadb"
      MYSQL_USER: "root"
    expose:
      - "3306"
    ports:
      - "3306:3306"
    networks:
      - fortress-net

networks:
  fortress-net:
    driver: bridge
```

また、DockerコンテナからDB接続するための設定を行わなければなりません。
上記の docker-compose.yml では、以下のように環境変数を設定しています。
```
environment:
  DBFLUTE_ENVIRONMENT_TYPE: "docker"
```

これを利用して、以下のようなディレクトリ構成で dfprop ファイルを配置します
```
your-project-dir
|-...
|
|-dbflute_xxx
|  |-dfprop
|  |  |-docker ☆
|  |  |  |-replaceSchemaMap.dfprop ☆
|  |  |  |-databaseInfoMap.dfprop ☆
|  |  |-replaceSchemaMap.dfprop
|  |  |-databaseInfoMap.dfprop
|  |-...
|
|-mydbflute
  |-dbflute-1.x.x
```

dockerディレクトリ内部のそれぞれのファイルの設定は以下のように、Docker固有なものになります。

replaceSchemaMap.dfprop
```
map: {
  ; additionalUserMap = map:{
      ; system = map:{
          ; url = jdbc:mysql://fortress-mysql
          ; user = root
          ; password =
      }
  }
}
```

databaseInfoMap.dfprop
```
map:{
    ; driver   = com.mysql.jdbc.Driver
    ; url      = jdbc:mysql://fortress-mysql/maihamadb
    ; schema   =
    ; user     = root
    ; password =
}
```

### サンプルプロジェクト
https://github.com/lastaflute/lastaflute-test-fortress

以下のコマンドで起動するようになっています。
```
$ cd path/to/lastaflute-test-fortress
$ mvn package
$ docker-compose up
```

