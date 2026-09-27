import os
import requests
import time
import sys

GITHUB_TOKEN = "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"
headers = {
    'Accept': 'application/vnd.github.v3+json',
    'Authorization': f'token {GITHUB_TOKEN}'
}

failed_repos = [
    ("1lann", "Acidity"), ("1lann", "Consult"), ("1lann", "OrangeBox"), ("1lann", "ecnet"), ("1lann", "luz"),
    ("Alex", "Quartz-Audio-Player"), ("AlexDevs", "Classic-Peripherals"), ("Anavrins", "ChaCha20"),
    ("Anavrins", "MD5"), ("Anavrins", "SHA-1"), ("Anavrins", "SHA-256"), ("Anavrins", "SHA256-HMAC-PBKDF2"),
    ("Anavrins", "ecc.lua"), ("Arkowne", "VBC"), ("ArtJem", "Chess-Game"), ("Axo", "Schematic-builder"),
    ("BigBloke", "BLittle"), ("Cyberbit", "CCMaps"), ("Dragon-Voyageur", "BIM"), ("Ella", "Blockman"),
    ("EmmaKnijn", "Musicify"), ("Fatboychummy", "Tamperer-2.0"), ("Fatboychummy", "Thread"),
    ("GlitchGod42", "iPod-OS"), ("Gopher-M", "modemshark"), ("Intelligence-Modding", "AdvancedPeripherals"),
    ("Kazza", "Shape-AI"), ("Kazza", "SpriteMog"), ("Kazza", "Tetracraft"), ("Kuberow", "Quint"),
    ("L3velDr4in", "Turtle-3D-Printer"), ("Lemmmy", "SwitchCraft-Peripherals"), ("Leveloper", "LevelOS"),
    ("MCJack123", "4th-Dimension"), ("MCJack123", "Consult-Recrafted"), ("MCJack123", "Phoenix"),
    ("MCJack123", "RedRun"), ("MCJack123", "Simple-automatic-turtle-farm"), ("MCJack123", "Taskmaster"),
    ("MCJack123", "UnBIOS"), ("MCJack123", "austream"), ("MCJack123", "netshell"), ("Michiel", "CC-Rubiks-Cube"),
    ("Michiel", "MeowSynthCC"), ("Michiel", "More-Fonts"), ("Michiel", "Samurai-Salad"), ("Michiel", "The-Button"),
    ("Minki", "Forever-Testing"), ("Nightheart", "CC-Zombies-Demo"), ("PG231", "ECNet2"), ("RedTech0", "RedOS"),
    ("Remie", "Racing-Game"), ("RoseIsProot", "More-Peripherals"), ("Sammy", "CC-C-Bridge"), ("Sammy", "Chromy"),
    ("Sammy", "Crazy-Cargo-Crusade"), ("SamsTheNerd", "Ducky-Peripherals"), ("Shadyduck", "V3D"),
    ("Shlomo1412", "Basalt-UI-Designer"), ("Shlomo1412", "PixelCode"), ("Shlomo1412", "PixelUI-Designer"),
    ("Shlomo1412", "PixelUI2"), ("ShreksHellraiser", "Charmap"), ("ShreksHellraiser", "MISC"),
    ("ShreksHellraiser", "Monitor-Size-Calculator"), ("ShreksHellraiser", "Remos"), ("ShreksHellraiser", "Shrekbox"),
    ("ShrekshelleraiserCC", "ShrekPrint"), ("ShrekshelleraiserCC", "shrekflight"), ("Simadude", "Obsi-2"),
    ("Simaton", "Spamtons-Jump"), ("Sir-Will", "gist"), ("SirEdvin", "Cloud-Solutions"),
    ("Sparkwave", "Mine-Clicker"), ("SpartanSf", "Xenon-2D-Engine"), ("SquidDev-CC", "dbprotect"),
    ("SquidDev-CC", "tamperer"), ("SquidDev-CC", "tampl"), ("SquidDev", "CC-Speaks"), ("SquidDev", "Plethora"),
    ("StikyPiston", "sparkOS"), ("TechTastic", "CC-Advanced-Math"), ("ThunderBear", "CC-Androids"),
    ("Tom", "Github-Downloader"), ("Tom", "Minecraft-IRL-Weather"), ("Tom", "Toms-Peripherals"),
    ("WindClan", "Embedded-Computer"), ("Xella3", "CC-Minecraft"), ("Xella3", "CCDoom"), ("Xella3", "FSEncrypt"),
    ("Xella3", "Pine3D"), ("Xella3", "PngLua"), ("Xella3", "Pumpkin-Carver"), ("Xella3", "Watermelon-Game-3D"),
    ("afonya2", "Advanced-Encryption-Standard"), ("afonya2", "Open-Inventory-Library"), ("fashaodesu", "Metaphysics"),
    ("hexelll", "Bombastic-Island"), ("kepler155c", "milo"), ("kivts99", "CIDE"), ("lakehouse", "Lakes-CC-Additions"),
    ("minecraftbossdj", "Finer-Peripherals"), ("monomux", "bigfont"), ("nnilky", "Web-Based-Turtle-Controller"),
    ("piguman3", "Car-Dating-Simulator"), ("piguman3", "Jane-Demo"), ("root", "Trainlib"),
    ("st-sarxzer-XI", "CC-Blockly-Editor"), ("the-can-of-soup", "Create-CC-Better-Recipes"),
    ("tiktop101", "CC-DirectGPU"), ("timuzkas", "Musiclo"), ("tomodachi94", "unicornpkg"),
    ("xeli", "Create-CC-Total-Logistics")
]

def find_real_repo(author, repo_name):
    clean_repo = repo_name.replace('-', ' ')
    
    resp = requests.get(f"https://api.github.com/search/repositories?q={clean_repo}+user:{author}", headers=headers)
    if resp.status_code == 200 and resp.json().get('total_count', 0) > 0:
        return resp.json()['items'][0]['full_name']
    
    time.sleep(2.1)
    
    resp = requests.get(f"https://api.github.com/search/repositories?q={clean_repo}+{author}+computercraft", headers=headers)
    if resp.status_code == 200 and resp.json().get('total_count', 0) > 0:
        return resp.json()['items'][0]['full_name']
        
    time.sleep(2.1)
    
    resp = requests.get(f"https://api.github.com/search/repositories?q={clean_repo}+computercraft", headers=headers)
    if resp.status_code == 200 and resp.json().get('total_count', 0) > 0:
        return resp.json()['items'][0]['full_name']

    return None

def download_repo_files(original_author, original_repo, full_repo_path):
    folder_name = f"{original_repo} by {original_author}"
    os.makedirs(folder_name, exist_ok=True)

    repo_info_url = f"https://api.github.com/repos/{full_repo_path}"
    try:
        repo_resp = requests.get(repo_info_url, headers=headers, timeout=10)
    except requests.exceptions.RequestException:
        return False

    if repo_resp.status_code != 200:
        return False

    default_branch = repo_resp.json().get('default_branch', 'main')
    
    tree_url = f"https://api.github.com/repos/{full_repo_path}/git/trees/{default_branch}?recursive=1"
    try:
        tree_resp = requests.get(tree_url, headers=headers, timeout=15)
    except requests.exceptions.RequestException:
        return False
    
    if tree_resp.status_code != 200:
        return False

    tree = tree_resp.json().get('tree', [])
    
    # Pre-calculate files to download so we know the total for the progress bar
    target_files = [item for item in tree if item['path'].lower().endswith('readme.md') or item['path'].lower().endswith('.lua')]
    total_files = len(target_files)
    
    if total_files == 0:
        print("  [-] No .lua or readme.md files found.")
        return True

    download_count = 0
    bar_length = 30 # Visual length of the progress bar

    for i, item in enumerate(target_files, 1):
        path = item['path']
        
        # --- Draw the Progress Bar ---
        filled_len = int(bar_length * i // total_files)
        bar = '█' * filled_len + '-' * (bar_length - filled_len)
        
        # Truncate the filename if it's too long so it doesn't break the terminal line
        display_path = path if len(path) < 35 else "..." + path[-32:]
        
        # \r overwrites the current line instead of printing a new one
        sys.stdout.write(f"\r  [>] [{bar}] {i}/{total_files} | {display_path}".ljust(90))
        sys.stdout.flush()
        # -----------------------------

        raw_url = f"https://raw.githubusercontent.com/{full_repo_path}/{default_branch}/{path}"
        try:
            file_resp = requests.get(raw_url, headers=headers, timeout=10)
            if file_resp.status_code == 200:
                local_path = os.path.join(folder_name, path)
                os.makedirs(os.path.dirname(local_path), exist_ok=True)
                with open(local_path, 'wb') as f:
                    f.write(file_resp.content)
                download_count += 1
        except requests.exceptions.RequestException:
            pass
            
    # Print a final newline when the progress bar is done
    print(f"\n  [+] Successfully downloaded {download_count}/{total_files} files into '{folder_name}/'")
    return True

def main():
    print(f"Starting recovery for {len(failed_repos)} failed repositories...")
    
    for author, repo in failed_repos:
        print(f"\n[SEARCHING] Finding actual path for {repo} by {author}...")
        real_path = find_real_repo(author, repo)
        
        if real_path:
            print(f"  [>] Found actual repository: {real_path}")
            success = download_repo_files(author, repo, real_path)
            if not success:
                print("  [!] Download failed despite finding repository.")
        else:
            print(f"  [!] Could not locate repository via GitHub Search.")
            
        time.sleep(2.1) 

if __name__ == "__main__":
    main()