# fluent-plugin-haproxy
An haproxy log parser

## Usage

This plugins works with default http log format from HAProxy:

```
  log-format "%ci:%cp [%tr] %ft %b/%s %TR/%Tw/%Tc/%Tr/%Ta %ST %B %CC %CS %tsc %ac/%fc/%bc/%sc/%rc %sq/%bq %hr %hs %{+Q}r"
```

## http request

It captures the detail of http request:
 - method
 - path
 - query_string
 - http_version

## headers

If you configured HAProxy to capture headers:

```
  capture request header Authorization len 64
  capture request header Referer len 64
  capture request header User-Agent len 64
```

They will be captured by fluentd as `header_1`, `header_2`, `header_3`.
You can configure the plugin to pass header names:

```
  <parse>
    @type haproxy
    headers ["auth", "referer", "user_agent"]
  </parse>
```

### Special header: auth

If you want to capture `Authorization` header, and it is basic auth, and you want to capture the username, just call it auth like in this example and this pluging will do it for you.

For further explanation, please read the source code.

## Full fluentd configuration

```
<source>
  @type syslog
  port 5140
  bind 0.0.0.0
  <parse>
    @type haproxy
    headers ["auth", "referer", "user_agent"]
  </parse>
  tag haproxy
</source>

#<match **>
#  @type stdout
#</match>

<match **>
  @type elasticsearch
  host elasticsearch
  port 9200
  index_name haproxy-%Y%m%d
  time_format %Y-%m-%dT%H:%M:%S
  include_timestamp true
  flush_interval 10s
  template_name haproxy
  template_file /fluentd/etc/haproxy
  template_overwrite true
</match>
```
