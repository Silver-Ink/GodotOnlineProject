import subprocess
import time
from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse
import requests
import json

class ccolors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKCYAN = '\033[96m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'


app = FastAPI()

STEAM_API_KEY = "4E798DA95554500486D2057A8B7482BB"
APP_ID = "480" 
  
@app.post("/submit_score")
async def submit_score(request: Request):
    body_bytes = await request.body()
    data = json.loads(body_bytes)

    time.sleep(1)
    steam_id = data.get("steam_id")
    ticket_raw = data.get("auth_ticket")["buffer"]
    ticket_size = data.get("ticket_size", 0)

    ticket_list = json.loads(ticket_raw)

    ticket_bytes = bytes(ticket_list[:ticket_size])

    ticket_hex = ticket_bytes.hex()


    print(f"🎮 Requête reçue\n📦 Ticket HEX: {ticket_hex[:60]}... {len(ticket_hex)}")

    params = {
        "key": STEAM_API_KEY,
        "appid": APP_ID,
        "ticket": ticket_hex
    }

    response = requests.get(
        "https://api.steampowered.com/ISteamUserAuth/AuthenticateUserTicket/v1/",
        params=params
    )
    print(f"URL envoyée: {response.url}")
    print(f"Réponse Steam: {response.status_code} {response.json()}")

    try:
        json_result = response.json()
        result = json_result["response"]["params"]["result"]
        if (result != "OK"):
            return JSONResponse(status_code=401, content={"status": "invalid ticket steam side"})
            
    except:
        return JSONResponse(status_code=401, content={"status": "invalid ticket steam side"})

    result = subprocess.run(["../ServerExport/ServerValidator.exe", "--headless", data.get("inputs")], capture_output=True)

    print(ccolors.OKBLUE + "===================")
    print("GODOT SERVER OUTPUT")
    print(str(result.stdout))
    print("===================" + ccolors.ENDC)
    with open(f"replays/{steam_id}.json", "w") as f:
        json.dump(data, f)

    if result.returncode == 0:
        print("Simulation valid")
        return JSONResponse(status_code=200, content={"status": "valid"})
    else:
        return JSONResponse(status_code=200, content={"status": "invalid_simulation"})