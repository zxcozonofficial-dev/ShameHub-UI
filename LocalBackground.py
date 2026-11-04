# Python | LocalBackground.py | Windows local image picker for ShameHub
from http.server import BaseHTTPRequestHandler, HTTPServer
from pathlib import Path
import tkinter as tk
from tkinter import filedialog

LIMIT = 12 * 1024 * 1024

class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path != '/pick' or self.headers.get('X-ShameHub-Local') != '1':
            self.send_error(403)
            return
        root = tk.Tk()
        root.withdraw()
        root.attributes('-topmost', True)
        try:
            selected = filedialog.askopenfilename(
                parent=root, title='ShameHub — choose background',
                filetypes=[('Images', '*.png *.jpg *.jpeg *.webp')])
        finally:
            root.destroy()
        if not selected:
            self.send_response(204)
            self.end_headers()
            return
        try:
            path = Path(selected)
            if path.stat().st_size > LIMIT:
                self.send_error(413, 'Image exceeds 12 MB')
                return
            data = path.read_bytes()
            valid = data.startswith(b'\x89PNG\r\n\x1a\n') or data.startswith(b'\xff\xd8') or (data[:4] == b'RIFF' and data[8:12] == b'WEBP')
            if not valid:
                self.send_error(415, 'PNG, JPG or WebP required')
                return
            self.send_response(200)
            self.send_header('Content-Type', 'application/octet-stream')
            self.send_header('Content-Length', str(len(data)))
            self.send_header('Cache-Control', 'no-store')
            self.end_headers()
            self.wfile.write(data)
        except OSError:
            self.send_error(500, 'Unable to read selected image')

    def log_message(self, *_):
        pass

if __name__ == '__main__':
    try:
        server = HTTPServer(('127.0.0.1', 8767), Handler)
        print('ShameHub local image picker ready. Close this process to stop.')
        server.serve_forever()
    except KeyboardInterrupt:
        pass
    except OSError as error:
        print(f'Cannot start local picker: {error}')
