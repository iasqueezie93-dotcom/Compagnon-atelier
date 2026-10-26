#!/usr/bin/env python3
"""Verifies file structure and the read-only network policy; no Android SDK required."""
from pathlib import Path
from xml.etree import ElementTree
root=Path(__file__).resolve().parents[1]
files=['pubspec.yaml','lib/main.dart','lib/atelier_api.dart','lib/app_state.dart','android/app/src/main/AndroidManifest.xml','android/app/src/main/kotlin/fr/compagnon/compagnon_atelier/MainActivity.kt','android/app/src/main/res/xml/network_security_config.xml']
for f in files: assert (root/f).is_file(), f'Missing {f}'
source=(root/'lib/atelier_api.dart').read_text()
assert "identifyStore" in source and "getOrders" in source
assert "_client.get(" in source and all(x not in source for x in ('_client.post(', '_client.put(', '_client.patch(', '_client.delete('))
assert 'rdmstore/store/whoami' in source and 'repair-orders' in source
assert (root/'assets/images/fv-logo.png').exists()
ElementTree.parse(root/'android/app/src/main/AndroidManifest.xml')
ElementTree.parse(root/'android/app/src/main/res/xml/network_security_config.xml')
print('Source checks OK; real network and APK compilation still require device/toolchain.')
