#!/usr/bin/env python3
"""Replace Material Icons with TraqIcon(AppAssets.*) where a mapping exists.

Usage:
  python tool/migrate_icons.py --dry-run   # preview (default)
  python tool/migrate_icons.py --apply     # write changes (review diff first!)
"""

from __future__ import annotations

import argparse
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1] / "lib"

# Material icon name (after Icons.) -> AppAssets constant without "AppAssets." prefix.
# Canonical mapping — keep in sync with project icon migration reference.
MAPPING: dict[str, str] = {
    # A
    "account_tree": "iconHierarchy",
    "account_tree_outlined": "iconHierarchy",
    "add": "iconPlus",
    "add_circle": "iconAddCircle",
    "add_circle_outline": "iconAddCircle",
    "add_location": "iconMapPin",
    "analytics": "iconBarChart",
    "analytics_outlined": "iconBarChart",
    "api": "iconApi",
    "arrow_back": "iconChevronL",
    "arrow_back_ios": "iconChevronL",
    "arrow_downward": "iconArrowD",
    "arrow_drop_down": "iconChevronD",
    "arrow_forward": "iconArrowR",
    "arrow_forward_ios": "iconChevronR",
    "arrow_upward": "iconArrowUpR",
    "assignment": "iconClipboard",
    "assignment_outlined": "iconClipboard",
    "auto_awesome_outlined": "iconSparkle",
    "autorenew": "iconRefresh",
    # B
    "block": "iconBlock",
    "bug_report": "iconBug",
    "bug_report_outlined": "iconBug",
    "business": "iconFactory",
    "business_outlined": "iconFactory",
    # C
    "calendar_month": "iconCalendar",
    "calendar_today": "iconCalendar",
    "camera": "iconCamera",
    "camera_alt": "iconCamera",
    "camera_alt_outlined": "iconCamera",
    "camera_alt_rounded": "iconCamera",
    "cancel": "iconXCircle",
    "check": "iconCheck",
    "check_circle": "iconCheckCircle",
    "check_circle_outline": "iconCheckCircle",
    "checklist": "iconChecklist",
    "chevron_left": "iconChevronL",
    "chevron_right": "iconChevronR",
    "circle": "iconCircle",
    "clear_all": "iconFilter",
    "close": "iconX",
    "cloud": "iconCloud",
    "cloud_upload": "iconCloudUpload",
    "code": "iconCode",
    "compress": "iconCompress",
    "computer": "iconComputer",
    "content_copy": "iconCopy",
    "copy": "iconCopy",
    "copy_all_outlined": "iconCopy",
    # D
    "dark_mode": "iconMoon",
    "data_object": "iconBraces",
    "data_usage": "iconBarChart",
    "date_range": "iconCalendar",
    "delete": "iconTrash",
    "delete_forever": "iconTrash",
    "delete_outline": "iconTrash",
    "delete_outline_rounded": "iconTrash",
    "description": "iconDocument",
    "description_outlined": "iconDocument",
    "download": "iconDownload",
    "download_rounded": "iconDownload",
    # E
    "edit": "iconEdit",
    "email": "iconMail",
    "email_outlined": "iconMail",
    "error": "iconXCircle",
    "error_outline": "iconXCircle",
    "event": "iconCalendar",
    "event_busy": "iconCalendar",
    "event_note": "iconCalendar",
    "event_note_outlined": "iconCalendar",
    "expand_less": "iconChevronU",
    "expand_more": "iconChevronD",
    # F
    "factory": "iconFactory",
    "factory_outlined": "iconFactory",
    "file_download": "iconDownload",
    "file_upload": "iconUpload",
    "filter_list": "iconFilter",
    "filter_alt_outlined": "iconFilter",
    "fingerprint": "iconFingerprint",
    "flash_on": "iconFlash",
    "flash_off": "iconFlash",
    "flight_land": "iconAirplaneD",
    "flight_takeoff": "iconAirplaneUp",
    "folder": "iconFolder",
    "folder_off": "iconFolder",
    # G
    "grid_on": "iconGrid",
    "grid_view": "iconGrid",
    "groups": "iconUsers",
    # H
    "healing": "iconMedical",
    "health_and_safety": "iconSecurity",
    "height": "iconSwapVert",
    "help": "iconHelpCircle",
    "help_outline": "iconHelpCircle",
    "history": "iconHistory",
    "history_toggle_off": "iconHistory",
    "hourglass_empty": "iconHourglass",
    "hub": "iconHub",
    # I
    "inbox": "iconInbox",
    "inbox_outlined": "iconInbox",
    "info": "iconInfo",
    "info_outline": "iconInfo",
    "input": "iconArrowR",
    "inventory": "iconBox",
    "inventory_2": "iconBox",
    "inventory_2_outlined": "iconBox",
    # K
    "key": "iconKey",
    "key_off": "iconKey",
    "keyboard": "iconKeyboard",
    "keyboard_alt_outlined": "iconKeyboard",
    "keyboard_outlined": "iconKeyboard",
    "keyboard_arrow_down": "iconChevronD",
    "keyboard_arrow_up": "iconChevronU",
    # L
    "label": "iconTag",
    "label_outline": "iconTag",
    "layers": "iconLayers",
    "layers_outlined": "iconLayers",
    "leak_add": "iconSignal",
    "light_mode": "iconSun",
    "lightbulb": "iconLightbulb",
    "lightbulb_outline": "iconLightbulb",
    "link": "iconLink",
    "list": "iconList",
    "local_florist": "iconSparkle",
    "local_shipping": "iconTruck",
    "local_shipping_outlined": "iconTruck",
    "location_on": "iconMapPin",
    "location_on_outlined": "iconMapPin",
    "location_city_outlined": "iconMapPin",
    "lock": "iconLock",
    "lock_outline": "iconLock",
    "logout": "iconLogout",
    # M
    "map": "iconMap",
    "medical_services": "iconMedical",
    "memory": "iconChip",
    "menu": "iconMenu",
    "monitor": "iconComputer",
    "more_vert": "iconMoreVert",
    # N
    "notes_outlined": "iconDocument",
    "notifications": "iconNotification",
    "notifications_outlined": "iconNotification",
    "numbers": "iconNumbers",
    # O
    "open_in_new": "iconOpenNew",
    "output": "iconArrowD",
    # P
    "password": "iconKey",
    "pause": "iconPause",
    "pause_circle": "iconPause",
    "pending": "iconPending",
    "perm_identity": "iconUser",
    "person": "iconUser",
    "person_search": "iconUser",
    "phone": "iconPhone",
    "picture_as_pdf": "iconPdf",
    "pin_outlined": "iconMapPin",
    "place_outlined": "iconMapPin",
    "play_arrow": "iconPlay",
    "play_circle": "iconPlay",
    "play_circle_outline": "iconPlay",
    "play_circle_fill": "iconPlay",
    "play_circle_filled": "iconPlay",
    "play_for_work": "iconDownload",
    "play_for_work_outlined": "iconDownload",
    "pool": "iconHub",
    "public": "iconGlobe",
    # Q
    "qr_code": "iconQr",
    "qr_code_2": "iconQr",
    "qr_code_2_outlined": "iconQr",
    "qr_code_scanner": "iconQr",
    "query_stats": "iconBarChart",
    # R
    "receipt": "iconReceipt",
    "receipt_long": "iconReceipt",
    "refresh": "iconRefresh",
    "remove": "iconMinus",
    "remove_circle": "iconRemoveCircle",
    "replay": "iconRedo",
    "request_quote": "iconInvoice",
    "request_quote_outlined": "iconInvoice",
    "route": "iconRoute",
    "route_outlined": "iconRoute",
    # S
    "save": "iconSave",
    "science": "iconScience",
    "search": "iconSearch",
    "security": "iconSecurity",
    "sensors": "iconSignal",
    "sensors_off": "iconSignal",
    "settings": "iconSettings",
    "settings_system_daydream": "iconSettings",
    "shopping_cart": "iconCart",
    "smoke_free": "iconBlock",
    "speed": "iconGauge",
    "speed_outlined": "iconGauge",
    "star": "iconStar",
    "star_border": "iconStar",
    "stop_circle": "iconBlock",
    "storage": "iconDatabase",
    "style": "iconTag",
    "summarize": "iconDocument",
    "swap_vert": "iconSwapVert",
    "sync": "iconRefresh",
    # T
    "table_chart": "iconTable",
    "text_fields": "iconText",
    "timer": "iconTimer",
    "today": "iconCalendar",
    "touch_app": "iconTarget",
    "track_changes": "iconTarget",
    "transform": "iconTransform",
    "trending_up": "iconTrendingUp",
    "tune": "iconFilter",
    # U
    "upload": "iconUpload",
    "upload_file": "iconUpload",
    "upload_rounded": "iconUpload",
    "update": "iconRefresh",
    # V
    "verified": "iconVerified",
    "verified_user": "iconVerified",
    "visibility": "iconEye",
    "visibility_off": "iconEyeOff",
    "vpn_key_off": "iconKey",
    # W
    "warehouse": "iconWarehouse",
    "warning": "iconAlert",
    "warning_amber": "iconAlert",
    "warning_amber_outlined": "iconAlert",
    "warning_amber_rounded": "iconAlert",
    "web": "iconGlobe",
    "webhook": "iconWebhook",
    "whatshot": "iconFlame",
    "wifi_tethering": "iconWifi",
    "wifi": "iconWifi",
    # Extended / alias mappings (Step 2)
    "schedule": "iconClock",
    "schedule_outlined": "iconClock",
    "access_time": "iconClock",
    "pause_circle": "iconPause",
    "play_circle_fill": "iconPlay",
    "play_circle_filled": "iconPlay",
    "circle_outlined": "iconCircle",
    "radio_button_checked": "iconCheckCircle",
    "radio_button_unchecked": "iconCircle",
    "cancel_outlined": "iconXCircle",
    "warning_amber_outlined": "iconAlert",
    "analytics_outlined": "iconBarChart",
    "account_tree_outlined": "iconHierarchy",
    "inventory_outlined": "iconBox",
    "camera_alt_outlined": "iconCamera",
    "camera_front": "iconCamera",
    "camera_rear": "iconCamera",
    "keyboard_outlined": "iconKeyboard",
    "keyboard_arrow_up": "iconChevronU",
    "keyboard_arrow_down": "iconChevronD",
    "layers_outlined": "iconLayers",
    "notifications_none": "iconNotification",
    "subscriptions_outlined": "iconNotification",
    "route_outlined": "iconRoute",
    "touch_app_outlined": "iconTarget",
    "filter_list_off": "iconFilter",
    "search_off_outlined": "iconSearch",
    "search_off": "iconSearch",
    "upload_rounded": "iconUpload",
    "download_rounded": "iconDownload",
    "location_off": "iconMapPin",
    "location_off_outlined": "iconMapPin",
    "lock_open": "iconLock",
    "add_circle_outline": "iconAddCircle",
    "vpn_key": "iconKey",
    "admin_panel_settings": "iconSecurity",
    "admin_panel_settings_outlined": "iconSecurity",
    "developer_board": "iconChip",
    "sensors": "iconSignal",
    "sensors_off": "iconSensorsOff",
    "cached": "iconRefresh",
    "move_to_inbox": "iconInbox",
    "folder_special": "iconFolder",
    "file_present": "iconDocument",
    "medical_information_outlined": "iconMedical",
    "local_hospital": "iconMedical",
    "local_fire_department": "iconFlash",
    "delete_sweep": "iconTrash",
    "work_off": "iconX",
    "cleaning_services": "iconSparkle",
    "contact_phone": "iconPhone",
    "batch_prediction": "iconBarChart",
    "pool": "iconHub",
    "ac_unit": "iconSparkle",
    "flash_off": "iconBlock",
    "shield": "iconSecurity",
    "view_module": "iconGrid",
    "place": "iconMapPin",
    "category": "iconCategory",
    "queue": "iconQueue",
    "wifi_off": "iconWifiOff",
    "archive": "iconArchive",
    "dataset": "iconDataset",
    "build": "iconBuild",
    "timeline": "iconTimeline",
    "badge": "iconBadge",
    "store": "iconStore",
    "smoking_rooms": "iconSmokingRooms",
    "precision_manufacturing": "iconPrecisionManufacturing",
    "work": "iconWork",
    "tune": "iconTune",
    "thumb_up": "iconThumbUp",
    "thumb_down": "iconThumbDown",
    "dangerous": "iconDangerous",
    "network_check": "iconNetworkCheck",
    "workspace_premium": "iconWorkspacePremium",
    "crop_free": "iconCropFree",
    "grade": "iconGrade",
    "monetization_on": "iconMonetization",
    "score": "iconScore",
    "sms": "iconSms",
    "broken_image": "iconBrokenImage",
    "architecture": "iconArchitecture",
}

ICON_WIDGET_PATTERN = re.compile(
    r"(?P<const>const\s+)?Icon\(\s*Icons\.(?P<name>\w+)"
    r"(?P<args>(?:\s*,\s*(?:size|color|fontWeight|semanticLabel):[^)]+)*)\s*\)"
)

SKIP_FILES = {
    "traq_icon.dart",
}


def ensure_imports(content: str) -> str:
    needs_traq = "TraqIcon(" in content
    needs_assets = "AppAssets." in content
    if not needs_traq and not needs_assets:
        return content

    traq_import = "import 'package:traqtrace_app/core/widgets/traq_icon.dart';"
    assets_import = "import 'package:traqtrace_app/core/config/app_assets.dart';"

    if needs_traq and traq_import not in content:
        content = _insert_import(content, traq_import)
    if needs_assets and assets_import not in content:
        content = _insert_import(content, assets_import)
    return content


def _insert_import(content: str, imp: str) -> str:
    if imp in content:
        return content
    lines = content.splitlines(keepends=True)
    last_import = 0
    for i, line in enumerate(lines):
        if line.startswith("import "):
            last_import = i
    lines.insert(last_import + 1, imp + "\n")
    return "".join(lines)


def replace_icons(content: str) -> tuple[str, int]:
    count = 0

    def repl(match: re.Match[str]) -> str:
        nonlocal count
        name = match.group("name")
        asset = MAPPING.get(name)
        if asset is None:
            return match.group(0)
        count += 1
        args = match.group("args") or ""
        return f"TraqIcon(AppAssets.{asset}{args})"

    return ICON_WIDGET_PATTERN.sub(repl, content), count


def scan_unmapped() -> dict[str, int]:
    found: dict[str, int] = {}
    icon_ref = re.compile(r"Icons\.(\w+)")
    for path in ROOT.rglob("*.dart"):
        if path.name in SKIP_FILES:
            continue
        for m in icon_ref.finditer(path.read_text(encoding="utf-8")):
            name = m.group(1)
            if name not in MAPPING:
                found[name] = found.get(name, 0) + 1
    return dict(sorted(found.items(), key=lambda x: -x[1]))


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--apply",
        action="store_true",
        help="Write changes to disk (default is dry-run preview only)",
    )
    parser.add_argument(
        "--scan-unmapped",
        action="store_true",
        help="List Icons.* names with no mapping and exit",
    )
    args = parser.parse_args()

    if args.scan_unmapped:
        unmapped = scan_unmapped()
        print(f"Unmapped icon names ({len(unmapped)} unique):")
        for name, count in unmapped.items():
            print(f"  {name}: {count}")
        return

    total = 0
    files_changed = 0
    for path in sorted(ROOT.rglob("*.dart")):
        if path.name in SKIP_FILES:
            continue
        original = path.read_text(encoding="utf-8")
        updated, n = replace_icons(original)
        if n:
            updated = ensure_imports(updated)
            rel = path.relative_to(ROOT.parent)
            if args.apply:
                path.write_text(updated, encoding="utf-8")
                print(f"{rel}: {n} (applied)")
            else:
                print(f"{rel}: {n} (dry-run)")
            files_changed += 1
            total += n

    mode = "applied" if args.apply else "would change"
    print(f"Done. {total} Icon() replacements {mode} in {files_changed} files.")
    if not args.apply and total:
        print("Re-run with --apply to write. Review diffs carefully before applying.")


if __name__ == "__main__":
    main()
