import sqlite3

def init_db():
	conn = sqlite3.connect("replays.db")
	cursor = conn.cursor()

	cursor.execute("DROP TABLE replays")
	cursor.execute("""
    CREATE TABLE IF NOT EXISTS replays (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        steam_id TEXT NOT NULL,
        inputs TEXT NOT NULL,
        time REAL NOT NULL,
        level INTEGER NOT NULL
	)
	""")
	conn.commit()
	conn.close()
    
def add_replay_to_database(steam_id : str, level : int, inputs : str, time : float):
	conn = sqlite3.connect("replays.db")
	cursor = conn.cursor()
	cursor.execute(
	"INSERT INTO replays (steam_id, time, inputs, level) VALUES (?, ?, ?, ?)",
	(steam_id, time, inputs, level)
    )
	conn.commit()
	conn.close()

def get_ranking(claimed_time : float, level : int):
	conn = sqlite3.connect("replays.db")
	cursor = conn.cursor()
	cursor.execute("""
        SELECT steam_id, inputs, time FROM replays
		WHERE level == ?
        ORDER BY time ASC
    """, (level, ))
	rows = cursor.fetchall()
	rank = 1
	for r in rows:
		if (claimed_time <= r[0]):
			break
		rank+=1
	return rank

def get_nearest_ghosts(max_ghost : int, claimed_time : float, level : int):
	conn = sqlite3.connect("replays.db")
	cursor = conn.cursor()
	cursor.execute("""
        SELECT steam_id, inputs, time FROM replays
		WHERE level = ?
        ORDER BY ABS(time - ?) ASC
        LIMIT ?
    """, (level, claimed_time, max_ghost))
    
	rows = cursor.fetchall()
	return {"ghosts": [
        {"steam_id": r[0], "inputs": r[1], "time": r[2]} for r in rows
    ]}

def get_best_time(steam_id : int , level : int):
	conn = sqlite3.connect("replays.db")
	cursor = conn.cursor()
	cursor.execute("""
        SELECT time FROM replays
		WHERE level = ?
		AND steam_id = ?
    """, (level, steam_id))
    
	rows = cursor.fetchall()
	return rows[0, 0]

def print_whole_db():
    
	conn = sqlite3.connect("replays.db")
	cursor = conn.cursor()
	cursor.execute("""
	SELECT * FROM replays
	""")
	results = cursor.fetchall()
	print(results)
	conn.close()