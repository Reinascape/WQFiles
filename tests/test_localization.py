import json
import plistlib
import re
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ENTRY = re.compile(r'^("(?:\\.|[^"\\])*")\s*=\s*("(?:\\.|[^"\\])*");$')
PLACEHOLDER = re.compile(r'%(?:\d+\$)?(?:lld|llu|lu|ld|[dio@a-zA-Z])')


def read_table(path: Path) -> dict[str, str]:
    entries = {}
    for line_number, line in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
        if not line or line.startswith("/*"):
            continue
        match = ENTRY.match(line)
        if not match:
            raise AssertionError(f"{path.name}:{line_number}: malformed .strings entry")
        key = json.loads(match.group(1))
        value = json.loads(match.group(2))
        if key in entries:
            raise AssertionError(f"{path.name}:{line_number}: duplicate key {key!r}")
        entries[key] = value
    return entries


class LocalizationTests(unittest.TestCase):
    def test_language_tables_have_identical_keys(self):
        english = read_table(ROOT / "en.lproj/Localizable.strings")
        chinese = read_table(ROOT / "zh-Hans.lproj/Localizable.strings")
        self.assertEqual(set(english), set(chinese))
        self.assertGreater(len(chinese), 600)

    def test_placeholders_are_preserved(self):
        chinese = read_table(ROOT / "zh-Hans.lproj/Localizable.strings")
        for key, value in chinese.items():
            self.assertEqual(PLACEHOLDER.findall(key), PLACEHOLDER.findall(value), key)

    def test_critical_ui_terms_are_translated(self):
        chinese = read_table(ROOT / "zh-Hans.lproj/Localizable.strings")
        expected = {
            "App Data": "应用数据",
            "App Groups": "应用组",
            "Signing problem: no App Group": "签名问题：缺少应用组",
            "Cancel": "取消",
            "OK": "好",
            "Restore.FileBackup": "还原文件",
            "Restore.AppBackup": "还原备份",
        }
        for key, value in expected.items():
            self.assertEqual(chinese.get(key), value)

    def test_bundle_and_build_declare_localizations(self):
        info = plistlib.loads((ROOT / "Info.plist").read_bytes())
        self.assertEqual(set(info["CFBundleLocalizations"]), {"en", "zh-Hans"})
        build = (ROOT / "build.sh").read_text(encoding="utf-8")
        self.assertIn('for lproj in "$ROOT"/*.lproj', build)
        self.assertIn('cp -R "$lproj" "$APP/"', build)


if __name__ == "__main__":
    unittest.main()
