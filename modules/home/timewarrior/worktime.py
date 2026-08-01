#!/usr/bin/env python3
"""Timewarrior report extension: per-day voluntary/regular/off/overtime split.

Usage: timew worktime :day | :week | :month | <range>
Work before shift start (worktime.shift_start) is voluntary overtime.
Post-shift presence (work + off) beyond worktime.threshold hours is overtime.
Off-tagged time is informational; excess over worktime.off_allowance is flagged.
Voluntary/overtime under worktime.min_extra minutes per day folds into regular.
"""
import json
import sys
from datetime import datetime, timedelta, timezone

DEFAULT_THRESHOLD_HOURS = 9
DEFAULT_SHIFT_START = "08:00"
DEFAULT_OFF_ALLOWANCE_HOURS = 1
DEFAULT_MIN_EXTRA_MINUTES = 15
OFF_TAG = "off"


def parse_ts(s):
    return datetime.strptime(s, "%Y%m%dT%H%M%SZ").replace(tzinfo=timezone.utc).astimezone()


def fmt(td):
    minutes = int(td.total_seconds()) // 60
    h, m = divmod(minutes, 60)
    return f"{h}:{m:02d}"


def main():
    # Header: "key: value" lines until a blank line, then a JSON interval array.
    config = {}
    for line in sys.stdin:
        line = line.strip()
        if not line:
            break
        key, _, value = line.partition(":")
        config[key.strip()] = value.strip()
    intervals = json.load(sys.stdin)

    threshold = timedelta(
        hours=float(config.get("worktime.threshold", DEFAULT_THRESHOLD_HOURS))
    )
    allowance = timedelta(
        hours=float(config.get("worktime.off_allowance", DEFAULT_OFF_ALLOWANCE_HOURS))
    )
    min_extra = timedelta(
        minutes=float(config.get("worktime.min_extra", DEFAULT_MIN_EXTRA_MINUTES))
    )
    shift_h, shift_m = map(
        int, config.get("worktime.shift_start", DEFAULT_SHIFT_START).split(":")
    )

    now = datetime.now().astimezone()
    days = {}  # date -> [work_pre, work_post, off_pre, off_post]
    for iv in intervals:
        base = 2 if OFF_TAG in iv.get("tags", []) else 0
        start = parse_ts(iv["start"])
        end = parse_ts(iv["end"]) if iv.get("end") else now
        cur = start
        while cur < end:
            midnight = (cur + timedelta(days=1)).replace(
                hour=0, minute=0, second=0, microsecond=0
            )
            seg_end = min(end, midnight)
            shift = cur.replace(hour=shift_h, minute=shift_m, second=0, microsecond=0)
            buckets = days.setdefault(cur.date(), [timedelta()] * 4)
            buckets[base] += min(seg_end, shift) - min(cur, shift)
            buckets[base + 1] += max(seg_end, shift) - max(cur, shift)
            cur = seg_end

    if not days:
        print("No tracked time in range.")
        return

    cols = "{:<12} {:>7} {:>9} {:>8} {:>13} {:>9}"
    rule = cols.format("-" * 10, "-" * 5, "-" * 9, "-" * 7, "-" * 12, "-" * 8)
    print(cols.format("Date", "Total", "Voluntary", "Regular", "Off", "Overtime"))
    print(rule)
    sums = [timedelta()] * 5  # total, voluntary, regular, off, overtime
    excess_sum = timedelta()
    for day in sorted(days):
        work_pre, work_post, off_pre, off_post = days[day]
        off = off_pre + off_post
        presence = work_post + off_post
        regular = min(presence, threshold)
        overtime = presence - regular
        total = work_pre + work_post + off
        # sub-min_extra amounts are unintentional (shift-end chit-chat,
        # arriving a few minutes early) — fold them into regular
        if overtime and overtime < min_extra:
            regular += overtime
            overtime = timedelta()
        if work_pre and work_pre < min_extra:
            regular += work_pre
            work_pre = timedelta()
        excess = max(timedelta(), off - allowance)
        excess_sum += excess
        for i, v in enumerate((total, work_pre, regular, off, overtime)):
            sums[i] += v
        off_cell = fmt(off) + (f" (+{fmt(excess)})" if excess else "")
        print(cols.format(
            day.isoformat(), fmt(total), fmt(work_pre), fmt(regular), off_cell,
            fmt(overtime),
        ))
    print(rule)
    off_sum_cell = fmt(sums[3]) + (f" (+{fmt(excess_sum)})" if excess_sum else "")
    print(cols.format(
        "Sum", fmt(sums[0]), fmt(sums[1]), fmt(sums[2]), off_sum_cell, fmt(sums[4])
    ))


if __name__ == "__main__":
    main()
