# CodeTime Plugin

A simple Neovim plugin to track your coding time with goals and streaks.

## Features

✨ **Automatic Time Tracking**
- Tracks active coding time (not idle time)
- Saves when you lose focus or stop typing
- Time stored in minutes with human-readable format (e.g., "2h 15m")

📊 **Statistics**
- Total coding time across all sessions
- Today's coding time
- Per-language/filetype tracking

🎯 **Daily Goals & Streaks**
- Set a daily coding goal (in minutes)
- Track your current streak of consecutive days meeting your goal
- See total days you've hit your goal
- Weekly activity grid showing last 4 weeks (28 days)
- Grid refreshes automatically every 4 weeks

## Commands

- `:CodeTime` - Show detailed statistics in a floating window
- `:CodeTimeGoal <minutes>` - Set your daily goal (e.g., `:CodeTimeGoal 60` for 1 hour)

## Usage

1. The plugin tracks automatically! Just code normally.
2. Set your daily goal: `:CodeTimeGoal 120` (for 2 hours)
3. Check your stats with `:CodeTime`
4. Press `q` or `Esc` to close the statistics window.

## Data Location

Statistics are stored in: `~/.local/share/nvim/codetime.json`

## Example Statistics View

```
╔════════════════════════════════════════════════╗
║            CodeTime Statistics                ║
╚════════════════════════════════════════════════╝

📊 Overall
  Total coding time: 42h 30m

📅 Today
  Coding time: 1h 15m
  Daily goal: 2h
  Progress: 62%

🔥 Streaks
  Current streak: 7 days
  Total days met goal: 45

Activity (last 4 weeks):

     M T W T F S S
W36  ■ ■ ■ □ □ ■ ■ 
W37  ■ ■ □ ■ ■ ■ ■ 
W38  □ □ ■ ■ ■ ■ □ 
W39  ■ ■ ■ ■ ■ □ □ 

  Legend: □ = goal not met, ■ = goal met

💻 Top Languages
  c: 15h 30m (36%)
  lua: 12h 20m (29%)
  python: 10h 45m (25%)
  ...
```
