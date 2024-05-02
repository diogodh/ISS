load("time.star", "time")
load("render.star", "render")

def main(config):
    print(time.now().unix)

    return render.Root(
            render.Box(
            child = render.Marquee(
            width=64,
            child=render.Text("Ola")
        )))
