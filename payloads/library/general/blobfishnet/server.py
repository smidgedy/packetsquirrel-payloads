# reference: https://stackoverflow.com/questions/25042076/simplehttpserver-add-default-htm-default-html-to-index-files
import os
from SimpleHTTPServer import SimpleHTTPRequestHandler
import BaseHTTPServer

# overload the request handler to only serve files that exist in the payload folder
# or index.html for anything else.
class MyHTTPRequestHandler(SimpleHTTPRequestHandler):
  def translate_path(self,path):
    path = 'files/' + os.path.basename(SimpleHTTPRequestHandler.translate_path(self,path))
    if os.path.exists(path):
      return path
    else:
      return 'files/index.html'

# create the server, bind to any IP / port 80 and run
def run(HandlerClass = MyHTTPRequestHandler, ServerClass = BaseHTTPServer.HTTPServer):
  server_address = ('', 80)
  httpd = ServerClass(server_address, MyHTTPRequestHandler)
  httpd.serve_forever()

# program entry point
if __name__ == '__main__':
  run()