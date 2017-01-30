# rack-access-capture

[English](README.md) | 日本語

rack内でリクエスト、及びレスポンスをキャプチャし任意の出力先に内容を出力できます

以下の特徴があります

* 自動的にリクエスト、及びレスポンスキャプチャを実行することはありません
* キャプチャしたい内容をカスタマイズすることができます
* 本middlewareが持つ出力先以外に、独自の出力先が設定可能です

## 目次 ##

* [使い方](#使い方)
* [出力内容](#出力内容)
* [設定](#設定)
* [カスタマイズ](#カスタマイズ)
* [Contributing](#contributing)
* [License](#license)

## 使い方 ##

インストール直後には、自動的にキャプチャを実行することはありません。  
rack middlewaresの先頭に設定を含めて追加することで、動作するようになります。

### インストール ###

rubygems経由でインストール

```ruby
gem install rack-access-capture
```

Gemfileによるインストール

```ruby
# Gemfile

gem 'rack-access-capture'
```

### Railsの場合 ###

コードによる設定の追加

```ruby
config.middleware.use Rack::Access::Capture::Manager do |config|
  config.collector = { adapter: :fluentd, config: { host: 'localhost', port: 24224, tag: 'mytag', exclude_user_agents: ["exclude_user_agent_1", "exclude_user_agent_2"] } }
  config.watcher = { adapter: 'MyWatcher' }
  config.filter = { params: ['params1', 'params2'] }
end
```

YAMLによる設定の追加

```ruby
config.middleware.use Rack::Access::Capture::Manager, YAML.load_file("#{Rails.root}/config/rack.yml")
```

```yaml
collector:
  adapter: fluentd
  config:
    host: localhost
    port: 24224
    tag: my_tag
    exclude_user_agents:
      - "exclude_user_agent_1"
      - "exclude_user_agent_2"
watcher:
  adapter: MyWatcher
filter:
  params:
    - password
    - email
    - name
    - body
```

## 出力内容 ##

デフォルト設定の場合、以下になります。

```
{"status":200,"path":"/","method":"GET","params":"{}","device":"pc","os":"Mac OSX","browser":"Chrome","browser_ver":"50.0.2661.102","user_agent":"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/50.0.2661.102 Safari/537.36","remote_ip":"::1","time":1466588840,"accessed_at":1466588840,"app_exec_time":3.8547658920288086}
```

* ``status``: ステータスコード
* ``path``: パス
* ``method``: リクエストメソッド
* ``params``: リクエストパラメータ
* ``device``: 端末
* ``os``: 利用OS
* ``browser``: ブラウザ名
* ``browser_ver``: ブラウザバージョン
* ``user_agent``: ユーザーエージェント
* ``remote_ip``: アクセス元IP
* ``time``: キャプチャ実行時間
* ``accessed_at``: アクセス時間
* ``app_exec_time``: Rackアプリケーションの実行時間

## 設定 ##

現時点で変更できるオプションは以下のものです。

### 出力先設定 ###

``collector``に出力先の設定を実施します

* adapter: 出力先の実装クラスを指定します。以下の2種類が存在し、デフォルトは``console``です。
    * 標準出力にキャプチャ内容を出力する``console``
    * fuentdにキャプチャ内容を出力する``fluentd``
    * カスタマイズした出力先実装の場合、クラス名
* config: adapterの設定内容を指定する
    * ``console``: 下記の通り
    * ``fluentd``: [fluent-logger-ruby](https://github.com/fluent/fluent-logger-ruby)の設定値が設定可能

#### console設定

``format``: ``ltsv``を指定するとLTSV形式で出力。``json``を指定するとJson形式で出力する。デフォルトは``json``出力です。


LTSV使用例

```yaml
collector:
  adapter: console
  config:
    format: ltsv
```

### キャプチャ設定 ###

``watcher``にカスタマイズしたキャプチャの設定を実施します。デフォルトは未定義です。

* watcher: カスタマイズしたキャプチャ設定実装の場合、クラス名

### フィルター設定 ###

``filter``を設定することで、キャプチャされたくないリクエストパラメータに対してマスクをかけることができます。
デフォルトは、以下の2つを``[FILTERED]``にします。

* password
* authenticity_token

## カスタマイズ ##

### 独自のキャプチャ実装 ###

設定のwatcherのadapterにクラス名を指定することで、  
独自のキャプチャ実装が利用可能になります。

```ruby
require 'rack-access-capture'

module Rack
  class YourCustomizedWatcher < Rack::Access::Capture::Watcher::BaseAdapter

    def request_capture(env)
      { forwardedfor: env['HTTP_X_FORWARDED_FOR'] }
    end

    def response_capture(env, http_status_code, header)
      { rails_action: env[:rails_action] }
    end
  end
end
```

### 独自の出力先実装 ###

設定のcollectorのadapterにクラス名を指定することで、  
独自の出力先実装が利用可能になります。

```ruby
require 'rack-access-capture'

class YourCustomizedCollectorAdapter < Rack::Access::Capture::Collector::AbstractAdapter

  def initialize(*options)
    @config = options["adapter_config"]
  end

  def collect?(env)
    env["REQUEST_METHOD"] != "GET"
  end

  def collect(log)
    puts log
  end
end

```

### 設定ファイル ###

独自の設定を利用する場合、以下のようにファイルを記載します

```yaml
collector:
  adapter: YourCustomizedCollectorAdapter
  config:
    adapter_config: custom_collector_config
watcher:
  adapter: YourCustomizedWatcher
filter:
  params:
    - password
    - email
    - name
    - body
```

## Contributing ##

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License ##

See [LICENSE.txt](LICENSE.txt) for details.
