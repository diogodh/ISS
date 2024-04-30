load("render.star", "render")
load("http.star", "http")
load("time.star", "time") 
load("schema.star", "schema")

def get_schema():
    return schema.Schema(
        version = "1",
        fields = [
            schema.Text(
                id = "who",
                name = "Who?",
                desc = "Who to say hello to.",
                icon = "user",
            ),
            schema.Toggle(
                id = "small",
                name = "Display small text",
                desc = "A toggle to display smaller text.",
                icon = "compress",
                default = False,
            ),
        ],
    )


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
    url = 'https://api.n2yo.com/rest/v1/satellite/visualpasses/%s/%s/%s/%s/%s/%s/&apiKey=%s' % (sat, lat, lng, alt, days, sec, api)
    
    response = http.get(url)
    
    if response.status_code != 200:
        fail("API request failed with status %d" % response.status_code)
    
    data = response.json()
    return data
    
def filter_pass(data, el, mag):
    filtered_passes = [pass_data for pass_data in data['passes'] if pass_data['maxEl'] > el and pass_data['mag'] < mag]
    return filtered_passes

    
def main(config):
    el = 20
    mag = 0
    
    data = get_request()
    filtered_passes = filter_pass(data, el, mag)
    
    if filtered_passes:  # Check if there are any filtered passes
        # Take information only from the first pass
        first_pass_data = filtered_passes[0]
        utc_time_seconds = int(first_pass_data['startUTC'])  # Convert to integer
        start_compass = first_pass_data['startAzCompass']
        magnitude = first_pass_data['mag']
        
        # Convert UTC time to human-readable format
        utc_time = time.from_timestamp(utc_time_seconds)
        utc_time_human_readable = utc_time.format("02-01 15:04")  # Adjust format string
        
        # Build the render tree
        return render.Root(
            child = render.Column(
                cross_align="center",
                children = [
                    render.Text("%s" % utc_time_human_readable, color="#FF0000"),  # Display UTC time in red
                    render.Text("%s" % start_compass, color="#FFFFFF"),             # Display start compass direction in white
                    render.Text("%s" % magnitude, color="#FFFF00"),                 # Display magnitude in yellow
                ],
            ),
        )
    else:
        # No filtered passes found
        return render.Text("No passes found", color="#FF0000")
