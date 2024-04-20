# Import the required libraries
load("render.star", "render")
load("http.star", "http")
#from datetime import datetime, timezone, timedelta

# Import the required libraries

def get_request():
    sat = '25544'
    lat = '38.74'
    lng = '-9.14'
    alt = '0'
    days = '1'
    sec = '30'
    el = 20
    mag = 0
    api = 'ACDRCD-Z7US6X-WD9ZXB-58TV'
    url = f'https://api.n2yo.com/rest/v1/satellite/visualpasses/{sat}/{lat}/{lng}/{alt}/{days}/{sec}/&apiKey={api}'
    
    response = http.get(url)
    
    if response.status_code != 200:
        fail("API request failed with status %d" % response.status_code)
    
    data = response.json()
    return data

def filter_pass(data, el, mag):
    filtered_passes = [pass_data for pass_data in data['passes'] if pass_data['maxEl'] > el and pass_data['mag'] < mag]
    return filtered_passes

def print_pass(filtered_passes):
    print("Filtered Passes:")
    for pass_data in filtered_passes:
        utc_time = datetime.fromtimestamp(pass_data['startUTC'], tz=timezone.utc)
        local_offset = timedelta(hours=1)
        local_time = utc_time + local_offset
        print("Start Azimuth Compass:", pass_data['startAzCompass'])
        print("Local Start Time:", local_time.strftime('%Y-%m-%d %H:%M:%S %Z'))
        print("Magnitude:", pass_data['mag']) 
        print()

def main(config):
    el = 20
    mag = 0
    data = get_request()
    filtered_passes = filter_pass(data, el, mag)
    print_pass(filtered_passes)

    # Get font from config or default to "tb-8"
    font = config.get("font", "tb-8")
    print("Using font: '{}'".format(font)) # Debug print the font being used

    # Build the render tree
    return render.Root(
        child = render.Column(
            cross_align="center",
            children = [
                # Create a horizontal colored box
                render.Box(
                    width = 64,
                    height = 1,
                    color = "#78DECC",
                    padding = 10
                ),
                # Display the greeting text
                render.Text("%s" % greeting["greeting"], font = font, color = "#FF0000"),
                # Another horizontal colored box
                render.Box(
                    width = 64,
                    height = 1,
                    color = "#78DECC",
                ),
                # Scrolling marquee text to display the greeting in its native language
                render.Marquee(
                    width = 64,
                    child = render.Text("Good Morning in %s" % greeting["language"], font = font)
                ),
                # Final horizontal colored box
                render.Box(
                    width = 64,
                    height = 1,
                    color = "#78DECC",
                ),
            ],
        ),
    )
