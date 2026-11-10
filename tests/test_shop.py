from pathlib import Path
import json
import unittest

ROOT = Path(__file__).resolve().parents[1]

class RepoTests(unittest.TestCase):
    def test_shop_home(self):
        self.assertIn('Keyboard - £49', (ROOT / 'assets/shop/index.html').read_text())
        self.assertIn('Mouse - £25', (ROOT / 'days/day-03-ec2/user-data.sh').read_text())
    def test_health_endpoint(self):
        self.assertIn('/healthz', (ROOT / 'days/day-03-ec2/user-data.sh').read_text())
    def test_cw_groups(self):
        config = json.loads((ROOT / 'days/day-08-monitoring/cloudwatch-agent.json').read_text())
        groups = config['logs']['logs_collected']['files']['collect_list']
        self.assertEqual(len(groups), 2)
        self.assertTrue(all(x['retention_in_days'] == 3 for x in groups))
    def test_day9_template_progression(self):
        directory = ROOT / 'days/day-09-infrastructure-as-code/templates'
        for name in ('01-baseline.yml','02-parameterised.yml','03-suspend-versioning.yml'):
            self.assertTrue((directory / name).is_file())
        self.assertIn('Status: Suspended', (directory / '03-suspend-versioning.yml').read_text())
    def test_inventory_read_only(self):
        s = (ROOT / 'validation/inventory-resources.sh').read_text()
        self.assertNotIn('delete-', s)
        self.assertNotIn('terminate-', s)

if __name__ == '__main__': unittest.main()
