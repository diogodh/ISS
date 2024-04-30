"""
Applet: ISS Passes
Summary: Shows visible ISS passes
Description: Displays time, location and magnitude of International Space Station passes
Author: Diogo Ribeiro Machado
"""

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


# Defaults
DEFAULT_LOCATION = """
{
    "lat": 48.8575,
    "lng": 2.3514,
    "locality": "Paris, FR",
    "timezone": "GMT +1"
}
"""

DEFAULT_24_HOUR = True
DEFAULT_ITEMS_TO_DISPLAY = "both"

# Images
issImage = """iVBORw0KGgoAAAANSUhEUgAAAAsAAAAKCAYAAABi8KSDAAAACXBIWXMAAAsTAAALEwEAmpwYAAAGlmlUWHRYTUw6Y29tLmFkb2JlLnhtcAAAAAAAPD94cGFja2V0IGJlZ2luPSLvu78iIGlkPSJXNU0wTXBDZWhpSHpyZVN6TlRjemtjOWQiPz4gPHg6eG1wbWV0YSB4bWxuczp4PSJhZG9iZTpuczptZXRhLyIgeDp4bXB0az0iQWRvYmUgWE1QIENvcmUgOS4wLWMwMDEgNzkuMTRlY2I0MiwgMjAyMi8xMi8wMi0xOToxMjo0NCAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvIiB4bWxuczpkYz0iaHR0cDovL3B1cmwub3JnL2RjL2VsZW1lbnRzLzEuMS8iIHhtbG5zOnhtcE1NPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvbW0vIiB4bWxuczpzdEV2dD0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wL3NUeXBlL1Jlc291cmNlRXZlbnQjIiB4bWxuczpwaG90b3Nob3A9Imh0dHA6Ly9ucy5hZG9iZS5jb20vcGhvdG9zaG9wLzEuMC8iIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIDI0LjIgKFdpbmRvd3MpIiB4bXA6Q3JlYXRlRGF0ZT0iMjAyNC0wNC0zMFQxNjozMjo1MSswMTowMCIgeG1wOk1ldGFkYXRhRGF0ZT0iMjAyNC0wNC0zMFQxNjozNDo1MiswMTowMCIgeG1wOk1vZGlmeURhdGU9IjIwMjQtMDQtMzBUMTY6MzQ6NTIrMDE6MDAiIGRjOmZvcm1hdD0iaW1hZ2UvcG5nIiB4bXBNTTpJbnN0YW5jZUlEPSJ4bXAuaWlkOjQ5OTAzMmMxLTcyN2UtYjE0Zi1iMzJiLWJjYzM5ZDY4ZDM5NCIgeG1wTU06RG9jdW1lbnRJRD0iYWRvYmU6ZG9jaWQ6cGhvdG9zaG9wOjkyNTQzNDhmLTM5MTEtNTU0MS04M2M0LWVmNTcwNDIwYjQ1MSIgeG1wTU06T3JpZ2luYWxEb2N1bWVudElEPSJ4bXAuZGlkOjAxZmE5NzY1LTZmYmQtMTU0NS1iZmU4LTdlMTY5YTRkMzgwZSIgcGhvdG9zaG9wOkNvbG9yTW9kZT0iMyI+IDx4bXBNTTpIaXN0b3J5PiA8cmRmOlNlcT4gPHJkZjpsaSBzdEV2dDphY3Rpb249ImNyZWF0ZWQiIHN0RXZ0Omluc3RhbmNlSUQ9InhtcC5paWQ6MDFmYTk3NjUtNmZiZC0xNTQ1LWJmZTgtN2UxNjlhNGQzODBlIiBzdEV2dDp3aGVuPSIyMDI0LTA0LTMwVDE2OjMyOjUxKzAxOjAwIiBzdEV2dDpzb2Z0d2FyZUFnZW50PSJBZG9iZSBQaG90b3Nob3AgMjQuMiAoV2luZG93cykiLz4gPHJkZjpsaSBzdEV2dDphY3Rpb249InNhdmVkIiBzdEV2dDppbnN0YW5jZUlEPSJ4bXAuaWlkOmFmN2ZhN2Y0LTFkYWMtODA0NS1hYmQwLWU3MDQyZDRiMWE2YiIgc3RFdnQ6d2hlbj0iMjAyNC0wNC0zMFQxNjozMzoxOSswMTowMCIgc3RFdnQ6c29mdHdhcmVBZ2VudD0iQWRvYmUgUGhvdG9zaG9wIDI0LjIgKFdpbmRvd3MpIiBzdEV2dDpjaGFuZ2VkPSIvIi8+IDxyZGY6bGkgc3RFdnQ6YWN0aW9uPSJzYXZlZCIgc3RFdnQ6aW5zdGFuY2VJRD0ieG1wLmlpZDo0OTkwMzJjMS03MjdlLWIxNGYtYjMyYi1iY2MzOWQ2OGQzOTQiIHN0RXZ0OndoZW49IjIwMjQtMDQtMzBUMTY6MzQ6NTIrMDE6MDAiIHN0RXZ0OnNvZnR3YXJlQWdlbnQ9IkFkb2JlIFBob3Rvc2hvcCAyNC4yIChXaW5kb3dzKSIgc3RFdnQ6Y2hhbmdlZD0iLyIvPiA8L3JkZjpTZXE+IDwveG1wTU06SGlzdG9yeT4gPC9yZGY6RGVzY3JpcHRpb24+IDwvcmRmOlJERj4gPC94OnhtcG1ldGE+IDw/eHBhY2tldCBlbmQ9InIiPz7eGhGAAAAByklEQVQYGQXBTWvTYAAH8H/yPLZZl9atZTFNqaxQKsoUuw11B5lexJfOFzYvcwfBi1/Bowh+AR1S8KQnXSfosOAGm+BRL1VkbDSla+m2tvYtSdu0SZ74+8EwTLxNv1q5lhzTHi+nNnf3ClDzeRiGgZ2d75N35uPa7fmEtrHxVaYD04RlW8GQEvALPk/M7JmAF2CMwXGYNyiP+V2Xg8tcQv3iKKJK5JdtuLVRQfwtKzKsbhuE4yBJUo313Tqh1IqET1XIufMXkgelSkwttYNnziaz0bCU+7a9fTO/vz8iT4Rqud2yZDojrVK1PsudjE+5d5dXkIhNYuvzJ/uoWLCfPn8pGO0W1tOrvZnrN4RitcUPmxXw0fAEFh7eg1cUYTsO7fa6gvr3D4bDIRg4H3ieByHgCQH3YW3tar/fj69nMkuXZqazC6nUu+zm1q1xv1ieu3J57/Wb9AtD18NS9PQhXXyw9ONL5v3Qbfy82NdkLTE1vRoKhj76RBHFg7J/0MjdF4iHPXn0LEo7HQ3V5r85T4AoHaM5e1Q5BrMtWJoOtaBGOK+rMM5GR+8q9ITHA54jjcaxrgfGTdWyBgBzQAgFJWRQP2zr4AkIJc5/qLjPpH+ch6sAAAAASUVORK5CYII="""
eyeImage = """iVBORw0KGgoAAAANSUhEUgAAABMAAAAKCAYAAABWiWWfAAAACXBIWXMAAA0SAAANEgG1gDd0AAAFyWlUWHRYTUw6Y29tLmFkb2JlLnhtcAAAAAAAPD94cGFja2V0IGJlZ2luPSLvu78iIGlkPSJXNU0wTXBDZWhpSHpyZVN6TlRjemtjOWQiPz4gPHg6eG1wbWV0YSB4bWxuczp4PSJhZG9iZTpuczptZXRhLyIgeDp4bXB0az0iQWRvYmUgWE1QIENvcmUgOS4wLWMwMDEgNzkuMTRlY2I0MiwgMjAyMi8xMi8wMi0xOToxMjo0NCAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvIiB4bWxuczpkYz0iaHR0cDovL3B1cmwub3JnL2RjL2VsZW1lbnRzLzEuMS8iIHhtbG5zOnBob3Rvc2hvcD0iaHR0cDovL25zLmFkb2JlLmNvbS9waG90b3Nob3AvMS4wLyIgeG1sbnM6eG1wTU09Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9tbS8iIHhtbG5zOnN0RXZ0PSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvc1R5cGUvUmVzb3VyY2VFdmVudCMiIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIDI0LjIgKFdpbmRvd3MpIiB4bXA6Q3JlYXRlRGF0ZT0iMjAyNC0wNC0zMFQxNjozNzoxMCswMTowMCIgeG1wOk1vZGlmeURhdGU9IjIwMjQtMDQtMzBUMTY6Mzc6NTIrMDE6MDAiIHhtcDpNZXRhZGF0YURhdGU9IjIwMjQtMDQtMzBUMTY6Mzc6NTIrMDE6MDAiIGRjOmZvcm1hdD0iaW1hZ2UvcG5nIiBwaG90b3Nob3A6Q29sb3JNb2RlPSIzIiB4bXBNTTpJbnN0YW5jZUlEPSJ4bXAuaWlkOjc3OTMwZDkxLWU0NzgtNWE0My1hMzcyLWViZWI2ZTA3MDM2YiIgeG1wTU06RG9jdW1lbnRJRD0iYWRvYmU6ZG9jaWQ6cGhvdG9zaG9wOjdmM2VmMjkxLTQ3OTYtODM0MC1hYWMyLTZjNDNlNDgxOGUwMCIgeG1wTU06T3JpZ2luYWxEb2N1bWVudElEPSJ4bXAuZGlkOjkxNjJiMTkzLTQzODMtZWM0Ny1iYzhiLTNjNTQ1NTNkNGIyMCI+IDx4bXBNTTpIaXN0b3J5PiA8cmRmOlNlcT4gPHJkZjpsaSBzdEV2dDphY3Rpb249ImNyZWF0ZWQiIHN0RXZ0Omluc3RhbmNlSUQ9InhtcC5paWQ6OTE2MmIxOTMtNDM4My1lYzQ3LWJjOGItM2M1NDU1M2Q0YjIwIiBzdEV2dDp3aGVuPSIyMDI0LTA0LTMwVDE2OjM3OjEwKzAxOjAwIiBzdEV2dDpzb2Z0d2FyZUFnZW50PSJBZG9iZSBQaG90b3Nob3AgMjQuMiAoV2luZG93cykiLz4gPHJkZjpsaSBzdEV2dDphY3Rpb249InNhdmVkIiBzdEV2dDppbnN0YW5jZUlEPSJ4bXAuaWlkOjc3OTMwZDkxLWU0NzgtNWE0My1hMzcyLWViZWI2ZTA3MDM2YiIgc3RFdnQ6d2hlbj0iMjAyNC0wNC0zMFQxNjozNzo1MiswMTowMCIgc3RFdnQ6c29mdHdhcmVBZ2VudD0iQWRvYmUgUGhvdG9zaG9wIDI0LjIgKFdpbmRvd3MpIiBzdEV2dDpjaGFuZ2VkPSIvIi8+IDwvcmRmOlNlcT4gPC94bXBNTTpIaXN0b3J5PiA8L3JkZjpEZXNjcmlwdGlvbj4gPC9yZGY6UkRGPiA8L3g6eG1wbWV0YT4gPD94cGFja2V0IGVuZD0iciI/Pp15LXcAAAKHSURBVCiRXdLbb0txAMDx7+/cejndTldZJ0Vto667sYogexBZRETispBFxBPmwR54EhHzHwhLGIkXiUTcYoiEZCFCMKm5LWKWTctaumm7lq7t6TkeXb7v37eP6OjsBkCSJPL5GYolk0ql2G6rrh0Y81pxeoMoDjdmIc9MJkrmS0Qq5W5mTO2epqq4XE4sywJAAVAUmXgiicPp2rVyge/06K8qP+H9CJ+PkgayDbIDj52j2k6lW62XF/a16lOTkdHU4XQieWlOwI9plpGbVqxlbPwrviqj/+Lpo8eKsqEPqG1ULA9g5y3MZ7eR3t1BmspATT0E3Hwrz2PTEt19pGv7toHHkTXRWPzyLJ/XlqKxhFgUqh3sv352y2xD4+rbHHptPYUEyE/Oc2qrRlPFJMnbx7EfnkGkoKIuyNW3PzEccONK78aGZaGhz7EJh7RsyYIHfb0nwwAvhj4Qn3Hh8YL8I4o19oRbz2LE8w70+S0QfQ7fxtErIVmqYPD1RwDO9Z5sbGlael8SkpCEEPyTBarbwBYyN6/1M5GYRNcAWQFVBwvsvxYhBEISkvR+eKS961DPEEC4eTGznXlyGbB9BqJ5J36PhGN6nPL0d0RjB/ir+TkN1UqOcGMIgIPdPcORV8Pt8rq2dvvT6OcLd+89WrVh/ZqQq5jlaUxGD3gRNSGEfzXCV4do6YSGtdhOSI3G2FOfJhisYe+BEwMfR8baaufPLYiOzm4URWYinsTpcu0OL/SdGflVVWWv6kJ4DKgEVKAEZMHOZWGwj8X6VCbyKXU4m81enDunBtMsI/5HWyiaeNXCZkvz7MAItuCsDCBrTsqlGQrTcdLRN1IxeyNd0vo1VbXd7j9ofwNVxf7qvPPAcAAAAABJRU5ErkJggg=="""
mangifierImage = """iVBORw0KGgoAAAANSUhEUgAAAA0AAAAKCAYAAABv7tTEAAAACXBIWXMAAA7EAAAOxAGVKw4bAAAFyWlUWHRYTUw6Y29tLmFkb2JlLnhtcAAAAAAAPD94cGFja2V0IGJlZ2luPSLvu78iIGlkPSJXNU0wTXBDZWhpSHpyZVN6TlRjemtjOWQiPz4gPHg6eG1wbWV0YSB4bWxuczp4PSJhZG9iZTpuczptZXRhLyIgeDp4bXB0az0iQWRvYmUgWE1QIENvcmUgOS4wLWMwMDEgNzkuMTRlY2I0MiwgMjAyMi8xMi8wMi0xOToxMjo0NCAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvIiB4bWxuczpkYz0iaHR0cDovL3B1cmwub3JnL2RjL2VsZW1lbnRzLzEuMS8iIHhtbG5zOnBob3Rvc2hvcD0iaHR0cDovL25zLmFkb2JlLmNvbS9waG90b3Nob3AvMS4wLyIgeG1sbnM6eG1wTU09Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9tbS8iIHhtbG5zOnN0RXZ0PSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvc1R5cGUvUmVzb3VyY2VFdmVudCMiIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIDI0LjIgKFdpbmRvd3MpIiB4bXA6Q3JlYXRlRGF0ZT0iMjAyNC0wNC0zMFQxNjozOToyNSswMTowMCIgeG1wOk1vZGlmeURhdGU9IjIwMjQtMDQtMzBUMTY6NDA6MzIrMDE6MDAiIHhtcDpNZXRhZGF0YURhdGU9IjIwMjQtMDQtMzBUMTY6NDA6MzIrMDE6MDAiIGRjOmZvcm1hdD0iaW1hZ2UvcG5nIiBwaG90b3Nob3A6Q29sb3JNb2RlPSIzIiB4bXBNTTpJbnN0YW5jZUlEPSJ4bXAuaWlkOjIxZjE0N2EzLWFmZWItOWI0YS1hYTZhLTM2ZmNjMDcwOThiYyIgeG1wTU06RG9jdW1lbnRJRD0iYWRvYmU6ZG9jaWQ6cGhvdG9zaG9wOjFhZDdkMzQ4LTE3MzEtNzU0MC04ZDU0LTgyZDEzYjEzOTY1NiIgeG1wTU06T3JpZ2luYWxEb2N1bWVudElEPSJ4bXAuZGlkOjIwOGIwNmVhLTVmYzMtN2I0OC04NzM1LWFmMDhkY2I4OWU1YSI+IDx4bXBNTTpIaXN0b3J5PiA8cmRmOlNlcT4gPHJkZjpsaSBzdEV2dDphY3Rpb249ImNyZWF0ZWQiIHN0RXZ0Omluc3RhbmNlSUQ9InhtcC5paWQ6MjA4YjA2ZWEtNWZjMy03YjQ4LTg3MzUtYWYwOGRjYjg5ZTVhIiBzdEV2dDp3aGVuPSIyMDI0LTA0LTMwVDE2OjM5OjI1KzAxOjAwIiBzdEV2dDpzb2Z0d2FyZUFnZW50PSJBZG9iZSBQaG90b3Nob3AgMjQuMiAoV2luZG93cykiLz4gPHJkZjpsaSBzdEV2dDphY3Rpb249InNhdmVkIiBzdEV2dDppbnN0YW5jZUlEPSJ4bXAuaWlkOjIxZjE0N2EzLWFmZWItOWI0YS1hYTZhLTM2ZmNjMDcwOThiYyIgc3RFdnQ6d2hlbj0iMjAyNC0wNC0zMFQxNjo0MDozMiswMTowMCIgc3RFdnQ6c29mdHdhcmVBZ2VudD0iQWRvYmUgUGhvdG9zaG9wIDI0LjIgKFdpbmRvd3MpIiBzdEV2dDpjaGFuZ2VkPSIvIi8+IDwvcmRmOlNlcT4gPC94bXBNTTpIaXN0b3J5PiA8L3JkZjpEZXNjcmlwdGlvbj4gPC9yZGY6UkRGPiA8L3g6eG1wbWV0YT4gPD94cGFja2V0IGVuZD0iciI/PtzVB4AAAAHuSURBVCgVBcFPSFNxAMDx7/u9t709fZvTBTppy6W2ZZhOLzGNIBhCF6FLoaQRBCGCkgp1iDoadQgKOnjISsKbh/JUl6KDhxCkEYnJ0rlV0839dW669/p8pEBLCwAAEgbrcQu9/oPhS51/buh2pavO2WDNpJPRyC9t+f1K82x9vVGSfB4vALIwiSZkrvYX5qeu5Uf1jnHUhsv8iGzg81RxFBeZX1iNPlnyhZSqYQKQzsP5tsrNmeu5UbN9jtP9I2gSVOQtthMlVhJBbg9N+opHW2+EoggURZDNyQxeSA2jB2nuHUGTAKAjcIp2r0C1N1F03iLYkg0LEzABq2qwvattUo4R3dgHAKBcPqK17Qz+zrNkdr5QrJCRXQ0uZEVBFYd8XrV86Grdn+pyfVQjez0Ujt2ksoLfsSREH8DfBR69OzmmCCGTTu1yUDbdfd3eobWIWinkvv1s9IQDZV8I1aYRj32nlFzfm1t2P9zcdb2Sam0atTU1V17OLy5ZKzvW6YnJ++vxutkef+miz53uFqJqSRec0a9r9k+SEPlzAQdSX6jv+dNnL8Zz2TTTd2fuxf4lHzfZLWQyx2QPZSRToNkMam3HKLJAd9YhD4QHXucL+YOJsTuD2UzqbVPjCagaKMJA1wUOHWxWwDQACVWz8R/X9rosTo5g/AAAAABJRU5ErkJggg=="""


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

    # Get longditude and latitude from location
    location = json.decode(config.get("location", DEFAULT_LOCATION))
    lat = float(location["lat"])
    lng = float(location["lng"])

    # Get whether to display in 24h format
    display24Hour = config.bool("24_hour", DEFAULT_24_HOUR)
    itemsToDisplay = config.get("items_to_display", DEFAULT_ITEMS_TO_DISPLAY)

    el = 20
    mag = 1
    
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
                    render.Image(src=issImage), render.Text("%s" % utc_time_human_readable, color="#FF0000"),  # Display UTC time in red
                    render.Image(src=eyeImage), render.Text("%s" % start_compass, color="#FFFFFF"),             # Display start compass direction in white
                    render.Image(src=mangifierImage), render.Text("%s" % magnitude, color="#FFFF00"),                 # Display magnitude in yellow
                ],
            ),
        )
    else:
        # No filtered passes found
        return render.Text("No passes found", color="#FF0000")
