import os
import re
import requests
import time

# Configuration (Your token is pre-loaded)
FILE_LIST = "extracted_links.md"
GITHUB_TOKEN = "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"

headers = {'Accept': 'application/vnd.github.v3+json'}
if GITHUB_TOKEN != "YOUR_GITHUB_PERSONAL_ACCESS_TOKEN":
    headers['Authorization'] = f'token {GITHUB_TOKEN}'

def download_repo_files(author, repo):
    folder_name = f"{repo} by {author}"
    os.makedirs(folder_name, exist_ok=True)

    repo_info_url = f"https://api.github.com/repos/{author}/{repo}"
    try:
        repo_resp = requests.get(repo_info_url, headers=headers, timeout=10)
    except requests.exceptions.RequestException as e:
        print(f"  [!] Connection error: {e}")
        return

    if repo_resp.status_code != 200:
        print(f"  [!] Failed: {repo_resp.json().get('message', 'Unknown error')} (Status: {repo_resp.status_code})")
        return

    default_branch = repo_resp.json().get('default_branch', 'main')
    
    tree_url = f"https://api.github.com/repos/{author}/{repo}/git/trees/{default_branch}?recursive=1"
    try:
        tree_resp = requests.get(tree_url, headers=headers, timeout=15)
    except requests.exceptions.RequestException as e:
        print(f"  [!] Connection error fetching file tree: {e}")
        return
    
    if tree_resp.status_code != 200:
        print(f"  [!] Failed to get file tree. Status: {tree_resp.status_code}")
        return

    tree = tree_resp.json().get('tree', [])
    download_count = 0

    for item in tree:
        path = item['path']
        if path.lower().endswith('readme.md') or path.lower().endswith('.lua'):
            raw_url = f"https://raw.githubusercontent.com/{author}/{repo}/{default_branch}/{path}"
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
                
    print(f"  [+] Downloaded {download_count} files into '{folder_name}/'")

def main():
    if not os.path.exists(FILE_LIST):
        print(f"Error: Could not find {FILE_LIST}")
        return

    with open(FILE_LIST, 'r') as f:
        links = f.read().splitlines()

    repo_pattern = re.compile(r'https://github\.com/([^/]+)/([^/]+?)(?:\.git|/)?$')

    for link in links:
        link = link.strip()
        if not link:
            continue

        if 'gist.github.com' in link or 'pinestore.cc' in link or 'gitlab.com' in link:
            print(f"\n[SKIP] Non-GitHub link: {link}")
            continue

        match = repo_pattern.search(link)
        if match:
            author, repo = match.groups()
            repo = repo.split('?')[0].split('#')[0]
            print(f"\n[START] Processing {repo} by {author}...")
            download_repo_files(author, repo)
            time.sleep(0.2) 
        else:
            print(f"\n[SKIP] Unrecognized URL format: {link}")

if __name__ == "__main__":
    main()