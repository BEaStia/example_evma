require 'sinatra'
require 'async_sinatra'

class AsyncSinatraApp < Sinatra::Base
  register Sinatra::Async

  aget '/' do
    query = DB.query_defer("SELECT * FROM entries")
    query.callback{|result|
      answer = ERB.new("<html><head><title>Statistics</title><body><h1>Content</h1><table>").result
        if result.num_tuples>0
          result.first.each{|key, value|
            answer+="<td>#{key}</td>"
          }
        end
        result.each{|entry|
          answer += "<tr>"
          entry.each{|key, value|
            answer += "<td>#{value}</td>"
          }
          answer += "</tr>"
        }
      answer += ERB.new("</table></body>").result
      body answer
    }
    query.errback{|result|
      body "Error happened"
    }

  end

  aget '/statistics' do
    body "statistics"
  end
end
