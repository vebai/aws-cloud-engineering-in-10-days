#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
echo 'Checking shell syntax...'
while IFS= read -r -d '' f; do bash -n "$f"; done < <(find . -type f -name '*.sh' -print0)
echo 'Checking JSON...'
python3 - <<'PYCODE'
import json
from pathlib import Path
for p in Path('.').rglob('*.json'):
    json.loads(p.read_text())
    print('PASS JSON',p)
PYCODE
echo 'Checking essential paths...'
for f in README.md LICENSE assets/shop/index.html days/day-03-ec2/user-data.sh days/day-08-monitoring/cloudwatch-agent.json days/day-09-infrastructure-as-code/shop-network.yaml validation/inventory-resources.sh; do test -f "$f" || { echo "Missing $f" >&2; exit 1; }; done
echo 'Checking day guides and local Markdown links...'
python3 - <<'PYLINKS'
from pathlib import Path
import re
root=Path('.')
for day in range(1,11):
    matches=list((root/'days').glob(f'day-{day:02d}-*/README.md'))
    if len(matches)!=1:
        raise SystemExit(f'Expected one README for day {day:02d}, found {matches}')
for path in [root/'README.md',*root.glob('days/*/README.md'),*root.glob('docs/*.md')]:
    for target in re.findall(r'(?<!! )\[[^\]]+\]\(([^)]+)\)',path.read_text()):
        link=target.split('#',1)[0]
        if not link or '://' in link or link.startswith('mailto:'):continue
        if not (path.parent/link).exists():
            raise SystemExit(f'Broken Markdown link: {path} -> {target}')
print('PASS 10 day guides and local Markdown links')
PYLINKS
echo 'Checking CloudFormation YAML syntax...' 
if command -v ruby >/dev/null; then
  ruby -e 'require "yaml"; ARGV.each { |f| YAML.parse_file(f); puts "PASS YAML #{f}" }' days/day-09-infrastructure-as-code/*.yaml days/day-09-infrastructure-as-code/templates/*.yml
else echo 'Ruby unavailable: YAML syntax check skipped (use cfn-lint for full CloudFormation validation)'; fi
if command -v nginx >/dev/null; then echo 'Nginx installed; test application config on a target Linux host as appropriate'; fi
echo 'PASS offline validation; no AWS calls were made.'
