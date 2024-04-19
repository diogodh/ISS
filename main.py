import requests
from datetime import datetime, timezone, timedelta

sat = '25544'   # Convert to string
lat = '38.74'   # Convert to string
lng = '-9.14'   # Convert to string
alt = '0'       # Convert to string
days = '1'      # Convert to string
sec = '30'      # Convert to string
el = 20
mag = 0
api = 'ACDRCD-Z7US6X-WD9ZXB-58TV'
url = f'https://api.n2yo.com/rest/v1/satellite/visualpasses/{sat}/{lat}/{lng}/{alt}/{days}/{sec}/&apiKey={api}'  # Using f-string for URL formatting

response = requests.get(url)

if response.status_code == 200:
    data = response.json()
    print("Response:", data)
    
    # Filter passes where maxEl > 15 and mag < 0
    filtered_passes = [pass_data for pass_data in data['passes'] if pass_data['maxEl'] > el and pass_data['mag'] < mag]
    
    print("Filtered Passes:")

    for pass_data in filtered_passes:
        # Convert startUTC to local time (Lisbon timezone)
        utc_time = datetime.fromtimestamp(pass_data['startUTC'], tz=timezone.utc)
        local_offset = timedelta(hours=1)  # Lisbon timezone is UTC+1
        local_time = utc_time + local_offset
        
        # Print startAzCompass and local start time
        print("Start Azimuth Compass:", pass_data['startAzCompass'])
        print("Local Start Time:", local_time.strftime('%Y-%m-%d %H:%M:%S %Z'))  # Format the local time
        print("Magnitude:", pass_data['mag'])  # Added line to print magnitude  
        print()  # Add an empty line for clarity
else:
    print("Error:", response.status_code)
