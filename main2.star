'''
Applet: ISS
Summary: Shows visible ISS passes
Description: Displays time, location and magnitude of International Space Station passes
Author: Diogo Ribeiro Machado
'''

# ISS Passes App
#
# Copyright (c) 2024 Diogo Ribeiro Machado
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#
# See comments in the code for further attribution
#

load("encoding/base64.star", "base64")
load("encoding/json.star", "json")
load("render.star", "render")
load("schema.star", "schema")
load("time.star", "time")
load("secret.star", "secret")
load("http.star", "http")
load("cache.star", "cache")


# Defaults
DEFAULT_LOCATION = """
{
    "lat": 38.736946,
    "lng": -9.142685,
    "locality": "Lisbon, PT",
    "timezone": "GMT"
}
"""

DEFAULT_24_HOUR = True

# Constants
MIN_ELEVATION = 10 # minimum elevation is 10º
MIN_MAGNITUDE = 1 # minimum magnitude is 1
ALTITUDE = 0 # location altitude
SAT_ID = '25544' # ISS code
NUM_DAYS = '1' # passes for the next 2 days
MIN_DURATION = '10' # minimum time of visible pass
TTL_TIME = 3600
#API_KEY = 'ACDRCD-Z7US6X-WD9ZXB-58TV'


# Images
ISS_IMG = base64.decode("""
iVBORw0KGgoAAAANSUhEUgAAAAoAAAAJCAYAAAALpr0TAAAACXBIWXMAAAsTAAALEwEAmpwYAAAGlmlUWHRYTUw6Y29tLmFkb2JlLnhtcAAAAAAAPD94cGFja2V0IGJlZ2luPSLvu78iIGlkPSJXNU0wTXBDZWhpSHpyZVN6TlRjemtjOWQiPz4gPHg6eG1wbWV0YSB4bWxuczp4PSJhZG9iZTpuczptZXRhLyIgeDp4bXB0az0iQWRvYmUgWE1QIENvcmUgOS4wLWMwMDEgNzkuMTRlY2I0MiwgMjAyMi8xMi8wMi0xOToxMjo0NCAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvIiB4bWxuczpkYz0iaHR0cDovL3B1cmwub3JnL2RjL2VsZW1lbnRzLzEuMS8iIHhtbG5zOnhtcE1NPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvbW0vIiB4bWxuczpzdEV2dD0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wL3NUeXBlL1Jlc291cmNlRXZlbnQjIiB4bWxuczpwaG90b3Nob3A9Imh0dHA6Ly9ucy5hZG9iZS5jb20vcGhvdG9zaG9wLzEuMC8iIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIDI0LjIgKFdpbmRvd3MpIiB4bXA6Q3JlYXRlRGF0ZT0iMjAyNC0wNC0zMFQxNjozMjo1MSswMTowMCIgeG1wOk1ldGFkYXRhRGF0ZT0iMjAyNC0wNS0wMVQxMzowMjoxNCswMTowMCIgeG1wOk1vZGlmeURhdGU9IjIwMjQtMDUtMDFUMTM6MDI6MTQrMDE6MDAiIGRjOmZvcm1hdD0iaW1hZ2UvcG5nIiB4bXBNTTpJbnN0YW5jZUlEPSJ4bXAuaWlkOjY3YWMxMzJhLTg4ZGEtM2U0Yy04ZDgwLTE0NzI2MjVhMzhkYyIgeG1wTU06RG9jdW1lbnRJRD0iYWRvYmU6ZG9jaWQ6cGhvdG9zaG9wOjE1MDZkMmY3LWNmMDEtN2Q0Ny1iNDhmLWU4OThmZDRhYjljZSIgeG1wTU06T3JpZ2luYWxEb2N1bWVudElEPSJ4bXAuZGlkOjAxZmE5NzY1LTZmYmQtMTU0NS1iZmU4LTdlMTY5YTRkMzgwZSIgcGhvdG9zaG9wOkNvbG9yTW9kZT0iMyI+IDx4bXBNTTpIaXN0b3J5PiA8cmRmOlNlcT4gPHJkZjpsaSBzdEV2dDphY3Rpb249ImNyZWF0ZWQiIHN0RXZ0Omluc3RhbmNlSUQ9InhtcC5paWQ6MDFmYTk3NjUtNmZiZC0xNTQ1LWJmZTgtN2UxNjlhNGQzODBlIiBzdEV2dDp3aGVuPSIyMDI0LTA0LTMwVDE2OjMyOjUxKzAxOjAwIiBzdEV2dDpzb2Z0d2FyZUFnZW50PSJBZG9iZSBQaG90b3Nob3AgMjQuMiAoV2luZG93cykiLz4gPHJkZjpsaSBzdEV2dDphY3Rpb249InNhdmVkIiBzdEV2dDppbnN0YW5jZUlEPSJ4bXAuaWlkOmFmN2ZhN2Y0LTFkYWMtODA0NS1hYmQwLWU3MDQyZDRiMWE2YiIgc3RFdnQ6d2hlbj0iMjAyNC0wNC0zMFQxNjozMzoxOSswMTowMCIgc3RFdnQ6c29mdHdhcmVBZ2VudD0iQWRvYmUgUGhvdG9zaG9wIDI0LjIgKFdpbmRvd3MpIiBzdEV2dDpjaGFuZ2VkPSIvIi8+IDxyZGY6bGkgc3RFdnQ6YWN0aW9uPSJzYXZlZCIgc3RFdnQ6aW5zdGFuY2VJRD0ieG1wLmlpZDo2N2FjMTMyYS04OGRhLTNlNGMtOGQ4MC0xNDcyNjI1YTM4ZGMiIHN0RXZ0OndoZW49IjIwMjQtMDUtMDFUMTM6MDI6MTQrMDE6MDAiIHN0RXZ0OnNvZnR3YXJlQWdlbnQ9IkFkb2JlIFBob3Rvc2hvcCAyNC4yIChXaW5kb3dzKSIgc3RFdnQ6Y2hhbmdlZD0iLyIvPiA8L3JkZjpTZXE+IDwveG1wTU06SGlzdG9yeT4gPC9yZGY6RGVzY3JpcHRpb24+IDwvcmRmOlJERj4gPC94OnhtcG1ldGE+IDw/eHBhY2tldCBlbmQ9InIiPz5NcMzXAAABfElEQVQYGQFxAY7+A5+dmQI4Myd8AvnhvjIyM/JaWVnIio6VAGZnawAF/OW3DAXxo4qNnLECAQIDAAgJBgcMDgMDHB4bGAEDAwDb2toAAQECAA0QCxESFAwB8/Xy9QIhIif+CAMJy/Dr/tRQTVnBUU9XANzU0AAUDgoAFQ8bwwD6CtnX2NkGAwcSFoHo9f5FCxUkBOvr7O/w+vo+ChkeYdvX1hbg7PUd7v8QE/n+/0QADR4l8Y+/yP+AprL/AAIF/zBAQ/+Zztr/HzU8/ztUXf9Keo3/K0tU8QGGj5CKGyUoKb24uxUXDAa4Cw0OBf4GByAYEAzM3N/lLdzk6S8A/vj5AjowMHbw0sSd5MepCU5FQMdPR0Z7+ebhXUY8P48bCfXrBeXHC1hHQmkE4ODbAvsB+TQPEwAus7WoPwoNFbkfJiv+4OXpAOjr3z8ECvYnGBgY9QL9/fwA+Pn9+vTz/fzh4OHo/fr7ACMiIgD9/fsA8O/18Orq9P/5+/oLV8iqWjKC9lsAAAAASUVORK5CYII=
""")

EYE_IMG = base64.decode("""
iVBORw0KGgoAAAANSUhEUgAAABEAAAAJCAYAAADU6McMAAAACXBIWXMAAA0SAAANEgG1gDd0AAAGlmlUWHRYTUw6Y29tLmFkb2JlLnhtcAAAAAAAPD94cGFja2V0IGJlZ2luPSLvu78iIGlkPSJXNU0wTXBDZWhpSHpyZVN6TlRjemtjOWQiPz4gPHg6eG1wbWV0YSB4bWxuczp4PSJhZG9iZTpuczptZXRhLyIgeDp4bXB0az0iQWRvYmUgWE1QIENvcmUgOS4wLWMwMDEgNzkuMTRlY2I0MiwgMjAyMi8xMi8wMi0xOToxMjo0NCAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvIiB4bWxuczpkYz0iaHR0cDovL3B1cmwub3JnL2RjL2VsZW1lbnRzLzEuMS8iIHhtbG5zOnBob3Rvc2hvcD0iaHR0cDovL25zLmFkb2JlLmNvbS9waG90b3Nob3AvMS4wLyIgeG1sbnM6eG1wTU09Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9tbS8iIHhtbG5zOnN0RXZ0PSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvc1R5cGUvUmVzb3VyY2VFdmVudCMiIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIDI0LjIgKFdpbmRvd3MpIiB4bXA6Q3JlYXRlRGF0ZT0iMjAyNC0wNC0zMFQxNjozNzoxMCswMTowMCIgeG1wOk1vZGlmeURhdGU9IjIwMjQtMDUtMDFUMTM6MDE6MTkrMDE6MDAiIHhtcDpNZXRhZGF0YURhdGU9IjIwMjQtMDUtMDFUMTM6MDE6MTkrMDE6MDAiIGRjOmZvcm1hdD0iaW1hZ2UvcG5nIiBwaG90b3Nob3A6Q29sb3JNb2RlPSIzIiB4bXBNTTpJbnN0YW5jZUlEPSJ4bXAuaWlkOjRkYWJmYTRhLWNhN2QtODU0Mi1iN2RlLTc5MWEzZDU5NGQ0ZiIgeG1wTU06RG9jdW1lbnRJRD0iYWRvYmU6ZG9jaWQ6cGhvdG9zaG9wOmRmOGM2NzI0LTViNjYtNDI0OC04Yzk1LTFkNGYyNWQwZDgzMCIgeG1wTU06T3JpZ2luYWxEb2N1bWVudElEPSJ4bXAuZGlkOjkxNjJiMTkzLTQzODMtZWM0Ny1iYzhiLTNjNTQ1NTNkNGIyMCI+IDx4bXBNTTpIaXN0b3J5PiA8cmRmOlNlcT4gPHJkZjpsaSBzdEV2dDphY3Rpb249ImNyZWF0ZWQiIHN0RXZ0Omluc3RhbmNlSUQ9InhtcC5paWQ6OTE2MmIxOTMtNDM4My1lYzQ3LWJjOGItM2M1NDU1M2Q0YjIwIiBzdEV2dDp3aGVuPSIyMDI0LTA0LTMwVDE2OjM3OjEwKzAxOjAwIiBzdEV2dDpzb2Z0d2FyZUFnZW50PSJBZG9iZSBQaG90b3Nob3AgMjQuMiAoV2luZG93cykiLz4gPHJkZjpsaSBzdEV2dDphY3Rpb249InNhdmVkIiBzdEV2dDppbnN0YW5jZUlEPSJ4bXAuaWlkOjc3OTMwZDkxLWU0NzgtNWE0My1hMzcyLWViZWI2ZTA3MDM2YiIgc3RFdnQ6d2hlbj0iMjAyNC0wNC0zMFQxNjozNzo1MiswMTowMCIgc3RFdnQ6c29mdHdhcmVBZ2VudD0iQWRvYmUgUGhvdG9zaG9wIDI0LjIgKFdpbmRvd3MpIiBzdEV2dDpjaGFuZ2VkPSIvIi8+IDxyZGY6bGkgc3RFdnQ6YWN0aW9uPSJzYXZlZCIgc3RFdnQ6aW5zdGFuY2VJRD0ieG1wLmlpZDo0ZGFiZmE0YS1jYTdkLTg1NDItYjdkZS03OTFhM2Q1OTRkNGYiIHN0RXZ0OndoZW49IjIwMjQtMDUtMDFUMTM6MDE6MTkrMDE6MDAiIHN0RXZ0OnNvZnR3YXJlQWdlbnQ9IkFkb2JlIFBob3Rvc2hvcCAyNC4yIChXaW5kb3dzKSIgc3RFdnQ6Y2hhbmdlZD0iLyIvPiA8L3JkZjpTZXE+IDwveG1wTU06SGlzdG9yeT4gPC9yZGY6RGVzY3JpcHRpb24+IDwvcmRmOlJERj4gPC94OnhtcG1ldGE+IDw/eHBhY2tldCBlbmQ9InIiPz7SjSZmAAACT0lEQVQozwXBTUxSAQAH8P/zfSFPUNGBPDAtzSel09nKzDRsq1VmrnR6sLmyS6c2Nw+1Ni+1dezj1K1WF9uyLrl1MZk6o7QPP+JDVynIIL55wAOeyOv3I6znR2E2GeDxhaEvozV8CQRPnBigqoROlBmrQauLsZfOIB7YzQc27bXlhbf+NOGMphUxJ6WRk2VQBEFAkjJgSKKlRah+EEkqfbLlKtimJkTCEooVCVxFJQoEarMO52n43k20mPBxaX33fiiZ+s6yDMgKfT0Ylh28fWtw5nq/9eirHRNih1vB5US0BhdBfnuDuHMdTK0FsSoz5KwaD0eP1RvM5psLSz9/S1Jmg2w73j0yfufGVO9FK/36/QJmJDN4QyXyH55j7ASQTEThsE1DJe+jpLkD7nAKrPcXRoYvkY1C3YDL/cdD9XS3PzvX0wGk/HDsRMEYOHAkIEe38OTlCgq6Q9AdEFAIuFC8B6i0Wri9IiD60NXZhtU1x+Oi+cXlcdvCClBiRGNNObLxJPIsQApnEdrehOSaAylFUNRghawCMjERglkDaE1Y/PwDs3P2CZLhjKufbF/cvEF3ua9ToOY3EgireWjqGqDWHgTNlqFg6QXZdQVBiQQf+YvJ/hrY7Gv79yafjvkDoRdEx5khZLI58EZj66lm06NIChdc/DVoLEegUAAUBQABogCITjca/dPQc8qs3eG/6/X4ViiGBnGyewgMQ4NWcdCpCa1Jo1i24+QwZRDaUao3glGpIOeyEIP/yMjW17wUmwpmihzlpdpEIp6AlM3hP2Tk8qEjjvqdAAAAAElFTkSuQmCC
""")

MAG_IMG = base64.decode("""
iVBORw0KGgoAAAANSUhEUgAAAAwAAAAJCAYAAAAGuM1UAAAACXBIWXMAAA7EAAAOxAGVKw4bAAAGlmlUWHRYTUw6Y29tLmFkb2JlLnhtcAAAAAAAPD94cGFja2V0IGJlZ2luPSLvu78iIGlkPSJXNU0wTXBDZWhpSHpyZVN6TlRjemtjOWQiPz4gPHg6eG1wbWV0YSB4bWxuczp4PSJhZG9iZTpuczptZXRhLyIgeDp4bXB0az0iQWRvYmUgWE1QIENvcmUgOS4wLWMwMDEgNzkuMTRlY2I0MiwgMjAyMi8xMi8wMi0xOToxMjo0NCAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvIiB4bWxuczpkYz0iaHR0cDovL3B1cmwub3JnL2RjL2VsZW1lbnRzLzEuMS8iIHhtbG5zOnBob3Rvc2hvcD0iaHR0cDovL25zLmFkb2JlLmNvbS9waG90b3Nob3AvMS4wLyIgeG1sbnM6eG1wTU09Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9tbS8iIHhtbG5zOnN0RXZ0PSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvc1R5cGUvUmVzb3VyY2VFdmVudCMiIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIDI0LjIgKFdpbmRvd3MpIiB4bXA6Q3JlYXRlRGF0ZT0iMjAyNC0wNC0zMFQxNjozOToyNSswMTowMCIgeG1wOk1vZGlmeURhdGU9IjIwMjQtMDUtMDFUMTM6MDI6NTArMDE6MDAiIHhtcDpNZXRhZGF0YURhdGU9IjIwMjQtMDUtMDFUMTM6MDI6NTArMDE6MDAiIGRjOmZvcm1hdD0iaW1hZ2UvcG5nIiBwaG90b3Nob3A6Q29sb3JNb2RlPSIzIiB4bXBNTTpJbnN0YW5jZUlEPSJ4bXAuaWlkOjYxODEyZTFmLTY2NDAtYWQ0Ni1iNDFiLWI0ODU4YzRhM2U1NyIgeG1wTU06RG9jdW1lbnRJRD0iYWRvYmU6ZG9jaWQ6cGhvdG9zaG9wOjQyYzQ1ZWFjLTZmOTAtZjg0Zi04YzIxLWM0MTUxNjcyYWEwYyIgeG1wTU06T3JpZ2luYWxEb2N1bWVudElEPSJ4bXAuZGlkOjIwOGIwNmVhLTVmYzMtN2I0OC04NzM1LWFmMDhkY2I4OWU1YSI+IDx4bXBNTTpIaXN0b3J5PiA8cmRmOlNlcT4gPHJkZjpsaSBzdEV2dDphY3Rpb249ImNyZWF0ZWQiIHN0RXZ0Omluc3RhbmNlSUQ9InhtcC5paWQ6MjA4YjA2ZWEtNWZjMy03YjQ4LTg3MzUtYWYwOGRjYjg5ZTVhIiBzdEV2dDp3aGVuPSIyMDI0LTA0LTMwVDE2OjM5OjI1KzAxOjAwIiBzdEV2dDpzb2Z0d2FyZUFnZW50PSJBZG9iZSBQaG90b3Nob3AgMjQuMiAoV2luZG93cykiLz4gPHJkZjpsaSBzdEV2dDphY3Rpb249InNhdmVkIiBzdEV2dDppbnN0YW5jZUlEPSJ4bXAuaWlkOjIxZjE0N2EzLWFmZWItOWI0YS1hYTZhLTM2ZmNjMDcwOThiYyIgc3RFdnQ6d2hlbj0iMjAyNC0wNC0zMFQxNjo0MDozMiswMTowMCIgc3RFdnQ6c29mdHdhcmVBZ2VudD0iQWRvYmUgUGhvdG9zaG9wIDI0LjIgKFdpbmRvd3MpIiBzdEV2dDpjaGFuZ2VkPSIvIi8+IDxyZGY6bGkgc3RFdnQ6YWN0aW9uPSJzYXZlZCIgc3RFdnQ6aW5zdGFuY2VJRD0ieG1wLmlpZDo2MTgxMmUxZi02NjQwLWFkNDYtYjQxYi1iNDg1OGM0YTNlNTciIHN0RXZ0OndoZW49IjIwMjQtMDUtMDFUMTM6MDI6NTArMDE6MDAiIHN0RXZ0OnNvZnR3YXJlQWdlbnQ9IkFkb2JlIFBob3Rvc2hvcCAyNC4yIChXaW5kb3dzKSIgc3RFdnQ6Y2hhbmdlZD0iLyIvPiA8L3JkZjpTZXE+IDwveG1wTU06SGlzdG9yeT4gPC9yZGY6RGVzY3JpcHRpb24+IDwvcmRmOlJERj4gPC94OnhtcG1ldGE+IDw/eHBhY2tldCBlbmQ9InIiPz57oqDeAAABvUlEQVQY0wXBTUgUUQAH8P+befveOjO7mZPjsLgNpbC6H7IllBVGl6RLhIc8GOKtox2CwEJP0aVDh6K0OgRFUOAhJAQvBZZEEaZrLlhJwiqyzjqbq87bj5nt9yMnOiMAAM8n0IJ1aEzETL10IxVjFwKKoRN/z87lnPnXs/rDDSe8REVFAgCIqgQK99S13p13l/ovm6HOUfxeLcJ180Yf/xxPWS/7774iA/KZZABNoRo4rern4/ajwaGr6YaTU2hpjkJvseC4R/BpNY3edE05pn7tpj2xIhgL4MCtRCKH0CO0bqiNBACgNDCc7mqEoBacwjkcbX7RKjOtHd9WqvixFs5zVvNSrZsXqdIHT23CvguUEQT3c+Drt/BmJjcrh/QElrOb2LJdcBrtOFzPXhH2Wzi7FaDsYO3nNEqLI5ieWfw49SV6nXQlkrALxbOjY+PP/y5/N7Lzk2NtFn7l9zFwPCrrzj+/sLAizW3vGe/DYbZDDdO8c+/+g9sSlfnTiWc32xQ8EZ6GzB/yoSJKfLccLC+tG55l+mABHzQeTwxnMgvbk48nhoSQ5pIdFJQCmip5iooDT5YQ5D4IqQMg+A+5sqYu0sG3EQAAAABJRU5ErkJggg==
""")

def get_data(url, ttl_time):
    res = http.get(url, ttl_seconds=ttl_time) # cache for 1 hour
    if res.status_code != 200:
        fail("GET %s failed with status %d: %s", url, res.status_code, res.body())
    return res.json()
    

def main(config):
    #api_key = config.get("apiKey", None)
    #api_key = secret.decrypt("AV6+xWcEvzMwMjDopeYhz7Sgvzl61DC1GYYV6/TFcu2g+wlhvXg3QkXOUBGq9GK6rOeQWw1puCSqg45mULja/ZhcrBSoWSWmA6yG+1t50xA5AW+slpSHXut/NYOTNlvFhAk0J8LWFNMsETuS8DlCKYaPkXI9SoGXlC3zHpngfA==")
    display24hour = config.bool("24_hour", DEFAULT_24_HOUR)
    api_key = "ACDRCD-Z7US6X-WD9ZXB-58TV"
    location = json.decode(config.get("location", DEFAULT_LOCATION))
    lat = float(location["lat"])
    lng = float(location["lng"])
    timezone = location["timezone"]
    ttl_time = 3600

    url = 'https://api.n2yo.com/rest/v1/satellite/visualpasses/%s/%s/%s/%s/%s/%s/&apiKey=%s' % (SAT_ID, lat, lng, ALTITUDE, NUM_DAYS, MIN_DURATION, api_key)
        
    data = get_data(url, ttl_time)
        
    filtered_passes = [pass_data for pass_data in data['passes'] if pass_data['maxEl'] > MIN_ELEVATION and pass_data['mag'] < MIN_MAGNITUDE]

    if filtered_passes:  # Check if there are any filtered passes
        # Take information only from the first pass
        first_pass_data = filtered_passes[0]
        utc_time_seconds = int(first_pass_data['startUTC'])  # Convert to integer
        ttl_time =  utc_time_seconds - time.now().unix

        start_compass = first_pass_data['startAzCompass']
        magnitude = first_pass_data['mag']
        
        # Convert UTC time to human-readable format
        utc_time = time.from_timestamp(utc_time_seconds)
        final_time = utc_time.in_location(timezone)


        if display24hour:
            time_human_readable = final_time.format("15:04")  # Adjust format string
        else:
            time_human_readable = final_time.format("3:04 PM")  # Adjust format string

     
        col1 = render.Column(
            expanded= True,
            main_align="space_between",
            cross_align="center",  
            children=[
                render.Image(src=ISS_IMG),
                render.Image(src=MAG_IMG),
                render.Image(src=EYE_IMG),
           ],
        )
        
        col2 = render.Column(
            expanded= True,
            main_align="space_between",
            cross_align="center",  
            children=[
                render.Text("   "),
                render.Text("   "),
                render.Text("   "),
           ],
        )


        col3 = render.Column(
            expanded= True,
            main_align="space_around",
            cross_align="center",  # Center align text vertically
            children=[
                render.Text("%s" % time_human_readable, color="#FF0000", font="tb-8"),
                render.Text("%s" % start_compass, color="#FFFFFF", font= "tb-8"),
                render.Text("%s" % magnitude, color="#FFFF00", font = "tb-8"),

            ],
        )

        return render.Root(
            child=render.Row(
                children=[
                    col1,
                    col2,
                    col3
                ],
            ),
        )


    else:
        # No filtered passes found
        ttl_time = 3600
        return render.Text("No passes found", color="#FF0000")
        


def get_schema():

    return schema.Schema(
        version = "1",
        fields = [
            schema.Location(
                id = "location",
                name = "Location",
                desc = "Location for which to display the ISS passes.",
                icon = "locationDot",
            ),

            schema.Text(
                id = "apiKey",
                name = "N2YO API Key",
                desc = "N2YO API Key",
                icon = "code",
            ),

            schema.Toggle(
                id = "24_hour",
                name = "24 hour clock",
                desc = "Display the time in 24 hour format.",
                icon = "clock",
            ),
        ],
    )


#https://api.n2yo.com/rest/v1/satellite/visualpasses/25544/38.74/-9.14/0/2/10/&apiKey=ACDRCD-Z7US6X-WD9ZXB-58TV
