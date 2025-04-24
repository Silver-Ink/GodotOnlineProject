import subprocess
import time
from fastapi import FastAPI, Request, Query
from fastapi.responses import JSONResponse
import requests
import json
import db_manager as db
import steam_api_key

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

GHOST_NUMBER = 4

STEAM_API_KEY = steam_api_key.key
APP_ID = "480" 
level = 0
level_count = 1
def daily_level(): return level % level_count

db.init_db()
db.print_whole_db()

def check_steam_ticket(steam_id, auth_ticket) -> JSONResponse | None:
    time.sleep(1)
    ticket_raw = auth_ticket["buffer"]

    ticket_list = json.loads(ticket_raw)

    ticket_size = auth_ticket["size"]

    ticket_bytes = bytes(ticket_list[:ticket_size])

    ticket_hex = ticket_bytes.hex()

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
    return None

@app.post("/connect")
async def connect(request: Request):
    body_bytes = await request.body()
    data = json.loads(body_bytes)

    steam_id = data.get("steam_id")
    ticket = data.get("auth_ticket")

    error = check_steam_ticket(steam_id, ticket)
    if (error):
        return error
    return JSONResponse(status_code=200, content={"status": "connected"})

@app.post("/submit_score")
async def submit_score(request: Request):
    body_bytes = await request.body()
    data = json.loads(body_bytes)

    steam_id = data.get("steam_id")
    ticket = data.get("auth_ticket")
    print(ticket)

    error = check_steam_ticket(steam_id, ticket)
    if (error):
        return error

    print(str(data.get("time")))
    result = subprocess.run(["../ServerExport/ServerValidator.exe", "--headless", data.get("inputs"), str(data.get("time"))], capture_output=True)

    corrected_time : float = 99

    godot_output = result.stdout.decode()

    print(ccolors.WARNING + "===================")
    print("GODOT SERVER ERRORS")
    print(result.stderr.decode())
    print("===================" + ccolors.ENDC)
    print(ccolors.OKBLUE + "===================")
    print("GODOT SERVER OUTPUT")
    print(godot_output)
    print("===================" + ccolors.ENDC)

    if (result.returncode == 0):

        key = "corrected time:"
        start = godot_output.find(key) + len(key)
        if (start != -1):
            end = start + 1
            while (godot_output[end] != ';'):
                end += 1
            str_time = godot_output[start:end]
            corrected_time = float(str_time)

        db.add_replay_to_database(steam_id, level, data.get("inputs"), corrected_time)
        # db.print_whole_db()

    with open(f"replays/{steam_id}.json", "w") as f:
        json.dump(data, f)

    if result.returncode == 0:
        print("Simulation valid")
        return JSONResponse(status_code=200, content={"status": "valid"})
    else:
        return JSONResponse(status_code=200, content={"status": "invalid_simulation"})
    

@app.get("/daily_level")
async def get_daily_level():
    print("daily level requested")
    return {"daily_level": daily_level()}

@app.get("/daily_ranking")
async def get_daily_ranking(
    claimed_time: str = Query(..., description="Temps effectué")):
    print("daily level requested")
    return {"ranking": db.get_ranking(claimed_time, level)}

@app.get("/nearby_ghosts")
async def get_nearby_ghosts(
    claimed_time: str = Query(..., description="Temps effectué")):
    ghosts = db.get_nearest_ghosts(GHOST_NUMBER, claimed_time, level)
    return ghosts

@app.get("/best_time")
async def get_best_time(
    steam_id : int = Query(..., description="Id du joueur steam"),
    level: int = Query(..., description="Id du level (commence a 0)")):
    return {"best_time": db.get_best_time(steam_id, level)}