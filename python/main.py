import json
import random
import requests
from datetime import datetime, timezone

reviewer_file = '../reviewers.json'
with open(reviewer_file) as f:
  reviewer_list = json.loads(f.read())

with open('../config.json') as f:
  slack_webhook_url = json.loads(f.read())['SLACK_WEBHOOK_URL']
print(slack_webhook_url)

available = [elem for elem in reviewer_list if elem['reviewing'] == True ]
if not available:
  for val in reviewer_list:
    val['reviewing'] = True
  available = [elem for elem in reviewer_list if elem['reviewing'] == True ]

selection = random.choice(available)
selection['reviewing'] = False
selection['last_selection'] = datetime.now(timezone.utc).isoformat(timespec='milliseconds')

print(selection)
requests.post(slack_webhook_url, data=json.dumps({'text':f"Python says: {selection['name']}", 'channel':'#ehco'}))

with open(reviewer_file, mode='w') as f:
  f.write(json.dumps(reviewer_list, sort_keys=False, ensure_ascii=False, indent=2))
