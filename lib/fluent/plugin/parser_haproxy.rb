require "fluent/plugin/parser"
require "base64"

module Fluent
  module Plugin
    class HaproxyParser < Parser
      Plugin.register_parser("haproxy", self)

      REGEXP = /^(?<time>[^ ]*\s*[^ ]* [^ ]*) (?<ps>\w+)\[(?<pid>\d+)\]: ((?<c_ip>[\w\.]+):(?<c_port>\d+) \[(?<hatime>.+)\] (?<f_end>[\w-]+)~ (?<b_end>[\w-.]+)\/(?<b_server>[\w-]+) (?<tq>\d+)\/(?<tw>\d+)\/(?<tc>\d+)\/(?<tr>\d+)\/(?<tt>\d+) (?<status_code>\d+) (?<bytes>\d+) (?<req_cookie>\S+) (?<res_cookie>\S+) (?<t_state>[\w-]+) (?<actconn>\d+)\/(?<feconn>\d+)\/(?<beconn>\d+)\/(?<srv_conn>\d+)\/(?<retries>\d+) (?<srv_queue>\d+)\/(?<backend_queue>\d+) \{?(?<req_headers>[^}]*)\}? ?\{?(?<res_headers>[^}]*)\}? ?"(?<request>[^"]*)"|(?<message>.+))/

      config_param :headers, :array, default: []

      def configure(conf)
        super
      end

      def parse(text)
        m = REGEXP.match(text)
        unless m
          yield nil, nil
          return
        end

        r = {}
        m.names.each do |name|
          if value = m[name]
            r[name] = value
          end
        end

        # request
        if r["request"]
          request = r["request"].split(" ")
          r.delete("request")
          uri = request[1].split("?")
          r["method"] = request[0]
          r["path"] = uri[0]
          r["query_string"] ||= uri[1]
          r["http_version"] = request[2]
        end

        # headers
        if r["req_headers"]
          parsed_headers = r["req_headers"].split("|")
          r.delete("req_headers")
          parsed_headers.each_with_index do |header, index|
            if @headers.empty?
              r["header_#{index}"] = header
            else
              r[@headers[index]] = header
            end
          end
          if r["auth"]
            type = r["auth"].split(" ")[0]
            cred = r["auth"].split(" ")[1]
            r.delete("auth")
            r["auth_type"] = type
            if type == "Basic"
              r["user"] = Base64.decode64(cred).split(":")[0]
            end
          end
        end

        time, record = convert_values(parse_time(r), r)
        yield time, record
      end
    end
  end
end
