import asyncio
import json
import websockets
import drawer
import multiprocessing as mp
import threading


class WebSocketListener:

    def __init__(self, pipe):
        self.pipe = pipe

    async def listen(self, websocket, path):
        async for message in websocket:
            self.pipe.send(json.loads(message)['skeletons'][0])

    def open_websocket(self):
        loop = asyncio.new_event_loop()
        asyncio.set_event_loop(loop)
        self.start_server = websockets.serve(self.listen, "localhost", 3000)
        print("listening")
        loop.run_until_complete(self.start_server)
        loop.run_forever()


src_pipe, dst_pipe = mp.Pipe()

ws_listener = WebSocketListener(src_pipe)
ws_thread = threading.Thread(target=ws_listener.open_websocket)
ws_thread.daemon = True
ws_thread.start()

plotter = drawer.Drawer()
while True:
    last_data = 0
    # Only care about the most recent item
    while dst_pipe.poll():
        last_data = dst_pipe.recv()

    if not last_data:
        continue

    plotter.update_skeleton(last_data)